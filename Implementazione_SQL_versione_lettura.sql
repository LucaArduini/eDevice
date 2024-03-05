/* 
1 Trigger
2 Business Rule
3 Event
4 Query
5 Procedure
6 Data Analytics
*/


/**************************************************************** TRIGGER *********************************************************************************/
DELIMITER $$

DROP TRIGGER IF EXISTS accettazione_reso $$
CREATE TRIGGER accettazione_reso
AFTER UPDATE ON Reso
FOR EACH ROW
	BEGIN
		declare MagazzinoTarget int default 0;
        declare AreaTarget int default 0;
        declare ProdottoTarget varchar(10) default '';
        
        IF new.Approvato = 1 THEN
			select UV.Prodotto into ProdottoTarget
            from UnitaVendute UV
			where UV.UID = new.UnitaVendute;
        
			select distinct IFNULL(UR.Magazzino, 0) into MagazzinoTarget
            from UnitaRese UR natural join UnitaVendute UV
            where UV.Prodotto = ProdottoTarget;
            
            select distinct IFNULL(UR.Area, 0) into AreaTarget
            from UnitaRese UR natural join UnitaVendute UV
            where UV.Prodotto = ProdottoTarget;
            
			IF MagazzinoTarget = 0 THEN
                select Magazzino, Area into MagazzinoTarget, AreaTarget
                from ( select Magazzino, Area, CapienzaDisponibile
					   from AreaMagazzino
					   where Predisposizione = (
											 select Categoria
											 from Prodotto
											 where CodProdotto = ProdottoTarget) ) AS MagazziniTarget
                where CapienzaDisponibile = (
										 select MAX(M2.CapienzaDisponibile)
                                         from MagazziniTarget M2
                                         )
				limit 1;
			END IF;
                    
			INSERT INTO UnitaRese
			SELECT UV.UID, new.Codice, MagazzinoTarget, AreaTarget
            FROM UnitaVendute UV
            WHERE UV.UID = new.UnitaVendute;
		 END IF;
END $$

DROP TRIGGER IF EXISTS ordine_pendente_piuVecchio_soddisfattibile $$
CREATE TRIGGER ordine_pendente_piuVecchio_soddisfattibile
AFTER INSERT ON unitadisponibili
FOR EACH ROW
BEGIN
	DECLARE codiceOrdine INT;
    DECLARE accountUtente VARCHAR(30) DEFAULT NULL;
    DECLARE garanzia VARCHAR(45) DEFAULT NULL;
    DECLARE unitaNONdisponibili INT;
    
    DECLARE cursore CURSOR FOR
    SELECT OV.CodOrdine, OV.Account as Utente, C.Garanzia
    FROM ordinevendita OV INNER JOIN carrello C on OV.CodOrdine = C.OrdineVendita
    WHERE C.Prodotto = NEW.Prodotto AND C.Variante = NEW.Variante AND
          C.Stato = 0 and OV.DataOrdine = 
          (select MIN(OV1.DataOrdine)
           FROM ordinevendita OV1 INNER JOIN carrello C1 on OV1.CodOrdine = C1.OrdineVendita
           WHERE C1.Prodotto = NEW.Prodotto AND C1.Variante = NEW.Variante AND
                 C1.Stato = 0)    /* Carello.Stato = 0 -> Unità non disponibile*/
	LIMIT 1;
    
	OPEN cursore;
	FETCH cursore INTO codiceOrdine, accountUtente, garanzia;
	UPDATE carrello C SET C.Stato = 1 
	WHERE C.Prodotto = NEW.Prodotto AND
		  C.Variante = NEW.Variante AND
		  C.OrdineVendita = codiceOrdine AND
		  C.Garanzia = garanzia;
	CLOSE cursore;

	SELECT COUNT(*) INTO unitaNONdisponibili
	FROM carrello 
	WHERE OrdineVendita = codiceOrdine AND
		  Stato = 0;
      
	IF unitaNONdisponibili = 0 THEN
		UPDATE ordinevendita SET Stato = 'In Processazione'
		WHERE CodOrdine = codiceOrdine;
	END IF;
    
END $$

DROP TRIGGER IF EXISTS Richiesta_Assistenza_Fisica $$
CREATE TRIGGER Richiesta_Assistenza_Fisica 
AFTER UPDATE ON AssistenzaVirtualeNoCodErrore
FOR EACH ROW
BEGIN

IF(NEW.Riuscita = 0 AND OLD.Riuscita IS NULL) THEN
	INSERT INTO AssistenzaFisica
    VALUES (NEW.CodiceAssistenza, CURRENT_DATE, 1, NEW.UnitaVendute);
END IF;
END $$

DROP TRIGGER IF EXISTS attivazione_assistenza_fisica $$
CREATE TRIGGER attivazione_assistenza_fisica
AFTER UPDATE ON assistenzavirtualenocoderrore
FOR EACH ROW
BEGIN

DECLARE flag INT;

SELECT Riuscita INTO flag
FROM assistenzavirtualenocoderrore
WHERE CodiceAssistenza = NEW.CodiceAssistenza;

IF flag = 0 THEN 
	INSERT INTO assistenzafisica 
    SELECT CodiceAssistenza, 
          (SELECT MAX(Ticket) + 1
		   FROM assistenzafisica),
           CURRENT_DATE(),
           NULL,
           Utente, 
           UnitaVendute
	 FROM assistenzavirtualenocoderrore
     WHERE CodAssistenza = NEW.CodiceAssistenza;
END IF;
    
END $$

DROP TRIGGER IF EXISTS Controllo_Soglia_Smaltimento $$
CREATE TRIGGER Controllo_Soglia_Smaltimento 
AFTER INSERT ON ControlloGenerale FOR EACH ROW
BEGIN

DECLARE Prodotto VARCHAR(20) DEFAULT '';
DECLARE Variante VARCHAR(100) DEFAULT '';
DECLARE Soglia INTEGER DEFAULT 0;
DECLARE SommaAttuale INTEGER DEFAULT 0;

     SELECT UV.Prodotto, UV.Variante INTO Prodotto, Variante
     FROM UnitaVendute UV
     WHERE UV.UID = NEW.UnitaResa;
SET Soglia =
	(
     SELECT IV.PercentualeRicondizionamento
     FROM InfoVarianza IV
     WHERE IV.CodProdotto = Prodotto AND IV.CodVariante = Variante
     );

SET SommaAttuale =
	(
     SELECT SUM(Importanza)
     FROM ControlloGenerale INNER JOIN Test ON Test = Codice
     WHERE UnitaResa = NEW.UnitaResa AND Superato = 0
     );

IF(SommaAttuale >= Soglia) THEN
	SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Somma importanza dei test troppo alta! Unita da smaltire!';
    
    INSERT INTO UnitaEndOfLife
    VALUES (NEW.UnitaResa, SommaAttuale, NULL, Prodotto, Variante);
    
    DELETE FROM UnitaRicondizionate
    WHERE UID = NEW.UnitaResa;
    
END IF;

END $$

DROP TRIGGER IF EXISTS AggiornaDaPagare $$
CREATE TRIGGER AggiornaDaPagare 
BEFORE UPDATE ON OrdineVendita
FOR EACH ROW
BEGIN
DECLARE daPagare INTEGER DEFAULT 0;

SET daPagare = (
	SELECT SUM(IF(C.Categoria <> 'A', (IV.Prezzo - IV.Prezzo * (5 * C.Categoria / 100)) * C.Quantita, IV.Prezzo * C.Quantita)) AS TotDaPagare
    FROM Carrello C INNER JOIN Varianza IV ON IV.Prodotto = C.Prodotto AND IV.Variante = C.Variante
    WHERE C.OrdineVendita = NEW.CodOrdine
    );

IF(NEW.Stato = 'InProcessazione') THEN
	SET NEW.TotDaPagare = daPagare;
END IF;

END $$

DROP TRIGGER IF EXISTS PrimaProduzione $$
CREATE TRIGGER PrimaProduzione 
BEFORE UPDATE ON LottoProduzione 
FOR EACH ROW
BEGIN
	
	IF(OLD.UnitaEffettive = 0 AND NEW.UnitaEffettive <> 0)
	THEN
		UPDATE LottoProduzione
        SET PrimaProduzione = NEW.UnitaEffettive
        WHERE CodLotto = NEW.CodLotto;
	END IF;
END $$

DROP TRIGGER IF EXISTS Verifica_Spedizione $$
CREATE TRIGGER Verifica_Spedizione 
BEFORE UPDATE ON Spedizione
FOR EACH ROW
BEGIN

	DECLARE Provincia VARCHAR(50) DEFAULT '';
    
    SET Provincia =
    (
     SELECT U.Provincia
     FROM Utente U INNER JOIN Account A ON A.Utente = U.CodFiscale
			INNER JOIN Spedizione S ON S.AccountConsegna = A.NomeUtente
     WHERE S.Codice = NEW.Codice
     );
     
     IF(NEW.HubAttuale = Provincia) THEN
        SET NEW.Stato = 'InConsegna';
	 END IF;
END $$

DROP TRIGGER IF EXISTS  calcola_TotaleNetto $$ 
CREATE TRIGGER calcola_TotaleNetto
BEFORE INSERT ON fattura FOR EACH ROW
    BEGIN
        DECLARE ore FLOAT DEFAULT 0;
        DECLARE costoPartiRicambio FLOAT DEFAULT 0;

        SELECT ifnull(OreLavoro,0) INTO ore
        FROM interventofisico
        WHERE ticket= NEW.InterventoFisico;

        WITH
        partiTarget AS (
        SELECT R.Parte
        FROM ricambio R
        WHERE R.ordineParti = (
                                SELECT O.Codice
                                FROM ordineparti O
                                WHERE O.InterventoFisico = NEW.InterventoFisico
                               )
        )
        SELECT ifnull(sum(prezzo),0) INTO costoPartiRicambio
        FROM partiTarget PT INNER JOIN parte P ON PT.parte=p.codParte;

        SET NEW.totaleNetto = ore*10 + costoPartiRicambio;
    END $$

/**************************************************************** BUSINESS RULE *********************************************************************************/

DROP TRIGGER IF EXISTS check_disponibilita_unita_carrello $$

CREATE TRIGGER check_disponibilita_unita_carrello
BEFORE INSERT ON Carrello 
FOR EACH ROW 
BEGIN
	DECLARE flag INT DEFAULT 0;
	SELECT COUNT(*) INTO flag 
    FROM unitadisponibili UD
    WHERE UD.Prodotto = NEW.Prodotto AND
          UD.Variante = NEW.Variante;
          
	IF flag = 0 THEN 
	SET NEW.Stato = 0;
	UPDATE ordinevendita
	SET Stato = 'Pendente'
	WHERE CodOrdine = NEW.OrdineVendita;
	END IF;
END $$

DROP TRIGGER IF EXISTS test_okay $$

CREATE TRIGGER test_okay
BEFORE INSERT ON test
FOR EACH ROW
BEGIN

DECLARE livelloPADRE INT;
SELECT Livello INTO livelloPADRE
FROM Test 
WHERE Codice = NEW.TestPadre;

IF (NEW.Livello - livelloPADRE) <> 1 THEN 
	SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Test non conforme alle politiche di precedenza dei livelli padre-figlio';
END IF;
    
END $$

DROP TRIGGER IF EXISTS Valuta_Test_Padre $$

CREATE TRIGGER Valuta_Test_Padre BEFORE INSERT ON ControlloGenerale
FOR EACH ROW
BEGIN

DECLARE controllo INTEGER DEFAULT 0;
DECLARE esito INTEGER DEFAULT 0;

	SET @TestPadre =
    (
     SELECT TestPadre
     FROM Test
     WHERE Codice = NEW.Test
     );
     
      SELECT COUNT(*) INTO controllo
      FROM ControlloGenerale
      WHERE UnitaResa = NEW.UnitaResa AND Test = @TestPadre;
      
      SELECT Superato INTO esito
      FROM ControlloGenerale
      WHERE UnitaResa = NEW.UnitaResa AND Test = @TestPadre;


IF(controllo = 0) THEN
	SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Test Padre mai effettuato! Test non valido.';
END IF;

IF(esito = 1) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Test padre già riuscito, test privo di senso!';
END IF;

END $$

DROP TRIGGER IF EXISTS UnitaPerseProduzione_BEFORE_DELETE $$

CREATE TRIGGER UnitaPerseProduzione_BEFORE_DELETE 
BEFORE DELETE ON UnitaPerseProduzione 
FOR EACH ROW
BEGIN
	DECLARE lottoRiferimento INTEGER DEFAULT 0;
	DECLARE stazioneRiferimento INTEGER DEFAULT 0;
    
    SET lottoRiferimento = OLD.Lotto;
    SET stazioneRiferimento = OLD.StazioneProduzione;
    
    IF(stazioneRiferimento) =
	(
     SELECT MAX(CodStazione)
     FROM StazioneProduzione
     WHERE Linea = ( SELECT Linea FROM LottoProduzione WHERE CodLotto = lottoRiferimento )
     ) THEN
    
    UPDATE LottoProduzione
    SET UnitaEffettive = UnitaEffettive + 1
    WHERE CodLotto = lottoRiferimento;
END IF;
END $$

/**************************************************************** EVENT *********************************************************************************/

DROP EVENT IF EXISTS monitora_resi $$

CREATE EVENT monitora_resi
ON SCHEDULE EVERY 1 DAY STARTS '2020-08-15 01:00:00' DO
	BEGIN
		CREATE TEMPORARY TABLE ProdottiTarget(
			CodProdotto varchar(15) NOT NULL,
            PRIMARY KEY(CodProdotto)
		);
        
        INSERT INTO ProdottiTarget
        SELECT CodProdotto
        FROM ( SELECT UV.Prodotto AS CodProdotto, COUNT(*) AS NumUnita
                FROM UnitaRese UR NATURAL JOIN UnitaVendute UV
                GROUP BY UV.Prodotto ) AS CU NATURAL JOIN InfoVarianza IV
        WHERE CU.NumUnita >= IV.MunMinimoUnitaRicond;
        
        INSERT INTO UnitaRicondizionate
        SELECT UR.UID, NULL, UV.Prodotto, UV.Variante, 0
        FROM UnitaRese UR NATURAL JOIN UnitaVendute UV
        WHERE UV.CodProdotto IN (
								 SELECT CodProdotto
                                 FROM ProdottiTarget
                                 );
                                 
		DELETE FROM UnitaRese
        WHERE UID in (
					  SELECT UID
                      FROM UnitaRicondizionate
                      );
	END $$

DELIMITER ;

/**************************************************************** QUERY *********************************************************************************/

/* Operazione 1
   Ricavare la descrizione di una operazione, la/le parte/i coinvolta/e, ed 
   elemento di giunzione utilizzato (con relativa descrizione della stessa)   */
   
SELECT O.ID,
	   A.Base as 'Parte base', 
       PB.Nome as 'Nome Parte BASE', 
	   IFNULL(A.Applicata, ' - ') as 'Parte applicata', 
       IFNULL(PA.Nome, ' - ') as 'Nome Parte APPLICATA',
       IFNULL(O.Giunzione, 'Saldatura') as 'Elemento di giunzione',
       O.Descrizione
FROM azione A INNER JOIN operazione O ON A.Operazione = O.ID 
			  INNER JOIN parte PB ON PB.CodParte = A.Base 
              INNER JOIN parte PA ON PA.CodParte = A.Applicata
WHERE O.ID = @input;

/* Operazione 2
	Scontare del 10% i prodotti usciti in commercio più di un anno fa (si tiene sotto commento per evitare effetti indesiderati) 

UPDATE	Varianza V
		NATURAL JOIN
        (
		SELECT V.*
        FROM Varianza V INNER JOIN Prodotto P ON P.CodProdotto = V.Prodotto
        WHERE YEAR(P.DataCommercio) < YEAR(CURRENT_DATE)
        ) AS D
SET V.Prezzo = V.Prezzo - (V.Prezzo * 10/100);

*/

/* Operazione 3
   Considerato un Unità Resa, si ricavi la richiesta di reso di riferimento, 
   indicandone motivazione e codice fiscale, nome e cognome del cliente che 
   ha fatto richiesta */
   
  SELECT UR.UID, 
         UR.Reso, 
		RR.Commento, 
        U.CodFiscale as 'Codice fiscale',
        U.Nome,
        U.Cognome
  FROM unitarese UR 
			INNER JOIN 
	   reso R 
			ON UR.Reso = R.Codice
            INNER JOIN 
		richiestareso RR
			ON RR.Reso = R.Codice
            INNER JOIN 
		account A
            ON A.NomeUtente = RR.Account
            INNER JOIN 
		utente U 
			ON A.Utente = U.CodFiscale
	WHERE UR.UID = @input;

/* Operazione 4
   Considerato un cliente, si ricavi quanto ha speso nell'ultimo ordine effettuato */
   
-- Nell'esempio si sceglie il cliente aaa1 
	
SELECT OV.TotDaPagare
FROM Utente U 
	 INNER JOIN Account ACC ON ACC.Utente = U.CodFiscale
     INNER JOIN OrdineVendita OV ON OV.Account = ACC.NomeUtente
WHERE U.CodFiscale = 'aaa1' AND OV.DataOrdine =
												(
                                                 SELECT MAX(OV2.DataOrdine)
                                                 FROM OrdineVendita OV2 INNER JOIN Account ACC2 ON ACC2.NomeUtente = OV2.Account
														INNER JOIN Utente U2 ON U2.CodFiscale = ACC2.Utente
												 WHERE U.CodFiscale = 'aaa1'
                                                 );

/* Operazione 6
   Considerato un Tecnico, ricavare gli Interventi Fisici programmati per la giornata. */

SELECT T.CodiceFiscale AS Tecnico,
INF.Data as Giorno,
I.InterventoFisico as 'Intervento Fisico'
FROM Tecnico T
INNER JOIN
incarico I
ON T.CodiceFiscale = I.Tecnico
INNER JOIN
interventofisico INF
ON INF.Ticket = I.InterventoFisico
INNER JOIN
assistenzafisica A
ON A.CodiceAssistenza = INF.AssistenzaFisica
WHERE INF.Data = '2020-05-06'
AND INF.Stato <> 'Finito';


/* Operazione 8 */
/* Si prende come esempio il prodotto 'AIph2017' */


WITH MaterialiRecuperati AS (
SELECT DISTINCT RM.Materiale
FROM recuperomateriale RM 
		INNER JOIN 
	 unitaendoflife U
		ON RM.UnitaEndOfLife = U.UID
		INNER JOIN 
	prodotto P 
		ON P.CodProdotto = U.Prodotto
WHERE P.CodProdotto = 'AIph2017'
)
SELECT GROUP_CONCAT(CONCAT('TRUNCATE(SUM(IF(RM.Materiale = ''', A.Materiale, ''', RM.Quantita, 0)), 4) AS''', A.Materiale, ' (grammi)', ''''))
FROM MaterialiRecuperati A 
INTO @pivot_query;

SET @pivot_query = CONCAT('SELECT U.Prodotto, ', @pivot_query, 'FROM recuperomateriale RM INNER JOIN UnitaEndOfLife U ON RM.UnitaEndOfLife = U.UID WHERE U.Prodotto = ''', 'AIph2017', '''');

PREPARE sql_statement FROM @pivot_query;
EXECUTE sql_statement;


/* Operazione 9
   Visualizzare la Capienza Disponibile di un magazzino (nell'esempio il magazzino 3001) 
   */
   
   SELECT SUM(AM.CapienzaDisponibile) AS CapienzaDisponibile
   FROM Magazzino M INNER JOIN AreaMagazzino AM ON AM.Magazzino = M.CodMagazzino
   WHERE M.CodMagazzino = '3001';

/* Operazione 11
	Restituire quante unità si stanno perdendo al momento per un certo Lotto fornito da utente 
*/

-- Nell'esempio è il lotto 801

SELECT UnitaPreviste - UnitaEffettive AS PerditaAdOggi
FROM LottoProduzione
WHERE CodLotto = '801';

/* Operazione 12
   Stampare il ricavo netto (inteso come la somma dei fatturati al netto di IVA) della data odierna
   */
   
SELECT SUM(TotaleNetto)
FROM Fattura
WHERE DataRilascio = CURRENT_DATE;


/**************************************************************** PROCEDURE *********************************************************************************/
DELIMITER $$



DROP PROCEDURE IF EXISTS CreaSequenza $$
CREATE PROCEDURE CreaSequenza (IN _prodotto VARCHAR(50), IN _variante VARCHAR(50), IN _newSeq INT, IN _scelta CHAR(1))
BEGIN

DECLARE quantiLivelli INTEGER DEFAULT 0;
DECLARE livelloAttuale INTEGER DEFAULT 1;
DECLARE nuova BOOLEAN DEFAULT FALSE;
DECLARE ordineOperazioni INTEGER DEFAULT 0;
DECLARE quanteInQuelLivello INTEGER DEFAULT 0;
DECLARE contatorePerLivello INTEGER DEFAULT 0;
DECLARE firstOfLevel INTEGER DEFAULT 1;
DECLARE lastOfLevel INTEGER DEFAULT 0;
DECLARE ripetizioni INTEGER DEFAULT 0; -- Condizione di uscita forzata in caso di loop da RAND

-- Operazione, Prodotto, Variante, Sequenza, NumOperazione
DROP TEMPORARY TABLE IF EXISTS DatiTemporanei;
CREATE TEMPORARY TABLE DatiTemporanei LIKE DatiSequenza;

DROP TEMPORARY TABLE IF EXISTS Assegnate;
CREATE TEMPORARY TABLE Assegnate(
ID INTEGER NOT NULL
);


-- Il numero massimo di livelli impiegato per fare quella varianza
SET quantiLivelli = 
		(
         SELECT MAX(O.Livello)
         FROM Operazione O
         WHERE O.Prodotto = _prodotto AND O.Variante = _variante AND O.Tipo = 'M'
         );

WHILE nuova = false AND ripetizioni <= 200 DO
BEGIN
	TRUNCATE TABLE DatiTemporanei;
    TRUNCATE TABLE Assegnate;
    
     SET firstOFLevel =
			(
             SELECT MIN(O.ID) AS FirstOfLevel
             FROM Operazione O
             WHERE O.Prodotto = _prodotto AND O.Variante = _variante AND O.Livello = livelloAttuale AND O.Tipo = 'M'
             );
	WHILE livelloAttuale <= quantiLivelli DO
    
		-- PRIMO CICLO
		SELECT COUNT(*) INTO quanteInQuelLivello -- Quante Operazioni ci sono in quel livello per quella varianza
        FROM Operazione O
        WHERE O.Prodotto = _prodotto AND O.Variante = _variante AND O.Livello = livelloAttuale AND O.Tipo = 'M';
        
		SET contatorePerLivello = 0;
       
             
        SET lastOfLevel = firstOfLevel + quanteInQuelLivello - 1;
        scanner : LOOP
			-- [FIRST, LAST]    [1, 0]
            SET @var = FLOOR(firstOfLevel + RAND() * (lastOfLevel - firstOfLevel + 1)); -- TROVAVA UN ID CHE ERA SEMPRE TRA GLI ID IN QUEL LIVELLO
          
            IF(@var) NOT IN
					(
                     SELECT *
                     FROM Assegnate
                     ) THEN
			SET ordineOperazioni = ordineOperazioni + 1;
            INSERT INTO DatiTemporanei VALUES (@var, _prodotto, _variante, _newSeq, ordineOperazioni);
            
				IF NOT EXISTS
					(
					  SELECT *
                      FROM DatiSequenza DS
                      WHERE DS.Prodotto = _prodotto AND DS.Variante = _variante AND DS.Operazione = @var AND DS.NumOperazione = ordineOperazioni
                      ) THEN
					
				SET nuova = true;
                END IF;
                
            INSERT INTO Assegnate VALUES (@var);
            SET contatorePerLivello = contatorePerLivello + 1;
			END IF;
            
            IF( contatorePerLivello = quanteInQuelLivello ) THEN
				LEAVE Scanner;
			END IF;
        END LOOP;
	
		SET firstOfLevel = lastOfLevel + 1;
    	SET livelloAttuale = livelloAttuale + 1;
    END WHILE;
END ;

SET ripetizioni = ripetizioni + 1;
END WHILE;

	IF(ripetizioni > 200) THEN
    SELECT "Prova a rilanciarmi, timeout!";
    ELSE
	IF(_scelta = 's') THEN
		INSERT INTO Sequenza VALUES(_prodotto, _variante, _newSeq);
        
        INSERT INTO DatiSequenza(
			SELECT *
            FROM DatiTemporanei);
		
        SELECT 'Sequenza memorizzata visualizzabile in DatiSequenza';
	ELSE
        SELECT *
        FROM DatiTemporanei;
	END IF;
    END IF;

END $$



DROP PROCEDURE IF EXISTS MostraOrario $$
CREATE PROCEDURE MostraOrario (IN _utente VARCHAR(20))
BEGIN

	DECLARE provincia VARCHAR(30) DEFAULT '';
    
    SET provincia =
		(
         SELECT U.Provincia
         FROM Utente U
         WHERE CodFiscale = _utente
         );
	
    SELECT DISTINCT T.FasciaOraria, COUNT(*) AS TecniciDisponibili
    FROM Tecnico T NATURAL JOIN DatiAnagraficiTecnico DT
    WHERE DT.Citta = provincia
    GROUP BY T.FasciaOraria;
END $$



DROP PROCEDURE IF EXISTS AssegnaOperatore $$
CREATE PROCEDURE AssegnaOperatore(IN _stazione VARCHAR(30))
BEGIN

DECLARE Classe VARCHAR(20) DEFAULT '';
DECLARE Operatore_ VARCHAR(30) DEFAULT '';

-- Acquisisco quale classe campione è maggiormente presente nella stazione
SET Classe = (
		SELECT ClasseCampione
        FROM StazioneProduzione
        WHERE CodStazione = _stazione
        );

-- Trovo, tra i dipendenti liberi, quello più veloce per operazioni simili a quel set

SELECT D.CodiceFiscale INTO Operatore_
FROM(
	SELECT MIN(V.TempoImpiegato) AS Minimo
	FROM Operatore O INNER JOIN Valutazione V ON O.CodiceFiscale = V.Dipendente
	WHERE O.StazioneProduzione IS NULL AND O.StazioneSmaltimento IS NULL
			AND V.ClasseCampione = Classe
            ) AS T
	 CROSS JOIN
	(
     SELECT O2.CodiceFiscale, V2.TempoImpiegato
     FROM Operatore O2 INNER JOIN Valutazione V2 ON O2.CodiceFiscale = V2.Dipendente
     WHERE O2.StazioneProduzione IS NULL AND O2.StazioneSmaltimento IS NULL
			AND V2.ClasseCampione = Classe
	) AS D
WHERE D.TempoImpiegato = T.Minimo
LIMIT 1;

UPDATE Operatore
SET StazioneProduzione = _stazione
WHERE CodiceFiscale = Operatore_;

END $$



DROP PROCEDURE IF EXISTS TempoLinea $$
CREATE PROCEDURE TempoLinea(IN _linea VARCHAR(20))
BEGIN

DECLARE stazioneCorrente VARCHAR(20) DEFAULT '';
DECLARE classeCorrente VARCHAR(20) DEFAULT '';
DECLARE quantiOperatori INTEGER DEFAULT 0;
DECLARE tempoLinea INTEGER DEFAULT 0;
DECLARE finito INTEGER DEFAULT 0;

DECLARE ScannerStazione CURSOR FOR
	SELECT CodStazione, ClasseCampione
    FROM StazioneProduzione
    WHERE Linea = _linea;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;

-- Scorrendo stazione per stazione, ho bisogno di accedere al tempo massimo di ogni operatore che vi lavora
OPEN ScannerStazione;

scanner : LOOP
	FETCH ScannerStazione INTO stazioneCorrente, classeCorrente;
    
    IF( finito = 1 )
		THEN LEAVE scanner;
	END IF;
    
    -- Della stazione corrente, verifico quanti operatori ci lavorino
    SELECT COUNT(*) INTO quantiOperatori
    FROM Operatore O
    WHERE O.StazioneProduzione = stazioneCorrente;
    
    -- Se ce n'è solo uno, è semplice
    IF( quantiOperatori = 1 ) THEN
		UPDATE StazioneProduzione
        SET TempoPrevisto = 
				(
                 SELECT ROUND(V.TempoImpiegato)
                 FROM Valutazione V INNER JOIN Operatore O ON V.Dipendente = O.CodiceFiscale
                 WHERE O.StazioneProduzione = StazioneCorrente AND V.ClasseCampione = ClasseCorrente
                 )
		WHERE CodStazione = StazioneCorrente;
        
	ELSE
	-- Fare caso al fatto che quando si calcola il tempo della linea le sazioni sono tutte riempite di operatori. Fare ELSE significa dunque chiedere quantiOperatori > 1 !
    SET @tempo = 
		(
         SELECT ROUND(MAX(V.TempoImpiegato) * 1.5)
         FROM Valutazione V INNER JOIN Operatore O ON V.Dipendente = O.CodiceFiscale
         WHERE O.StazioneProduzione = StazioneCorrente AND V.ClasseCampione = ClasseCorrente
         );
	
    UPDATE StazioneProduzione
    SET TempoPrevisto = @tempo
    WHERE CodStazione = StazioneCorrente;
    
    END IF;
END LOOP;

-- Quando ho finito, calcolo il tempo della linea
SET tempoLinea =
	(
     SELECT MAX(TempoPrevisto)
     FROM StazioneProduzione
     WHERE Linea = _linea
     );

UPDATE Linea
SET Tempo = tempoLinea
WHERE CodLinea = _linea;

END $$

DELIMITER $$

DROP PROCEDURE IF EXISTS AssegnaTecnico $$
CREATE PROCEDURE AssegnaTecnico(IN _tecnico VARCHAR(20), IN _incarichi INT)
BEGIN
	
    DECLARE contaIncarichi INTEGER DEFAULT 0;
    DECLARE ProvinciaTecnico VARCHAR(30) DEFAULT '';
    DECLARE interventoAttuale VARCHAR(10) DEFAULT '';
    DECLARE quantiAssegnatiAttualmente INTEGER DEFAULT 0;
    DECLARE quantiDaAssegnareAttualmente INTEGER DEFAULT 0;
    DECLARE prioritaAttuale INTEGER DEFAULT 1;
    DECLARE finito INTEGER DEFAULT 0;
    DECLARE assistenza VARCHAR(20) DEFAULT 'ciao';
    
    DECLARE Scanner CURSOR FOR
		SELECT IT.Ticket, IT.QuantiAssegnati, AF.TecniciRichiesti, ROW_NUMBER() OVER(ORDER BY AF.DataRichiesta) AS Priorita
        FROM InterventoFisico IT INNER JOIN AssistenzaFisica AF ON IT.AssistenzaFisica = AF.CodiceAssistenza
			 INNER JOIN UnitaVendute UV ON UV.UID = AF.UnitaVendute INNER JOIN OrdineVendita OO ON OO.CodOrdine = UV.OrdineVendita
             INNER JOIN Account ACC ON ACC.NomeUtente = OO.Account
             INNER JOIN utente U ON ACC.Utente = U.CodFiscale
			 WHERE IT.QuantiAssegnati < AF.TecniciRichiesti AND U.Provincia = (SELECT Citta FROM DatiAnagraficiTecnico WHERE CodiceFiscale = _tecnico) ;
	
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
        
    IF( _incarichi > 3) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Impossibile assegnare più di 3 incarichi, rilanciare la procedura';
	END IF;
    
    SET ProvinciaTecnico =
				(
                 SELECT T.CentroAssistenza
                 FROM Tecnico T
                 WHERE T.CodiceFiscale = _tecnico
                 );
                 
	OPEN Scanner;

    assegna : LOOP
		IF( contaIncarichi >= _incarichi ) THEN
			LEAVE assegna;
		END IF;
        
		FETCH Scanner INTO interventoAttuale, quantiAssegnatiAttualmente, quantiDaAssegnareAttualmente, prioritaAttuale;
            
        IF( finito <> 1 ) THEN
            
            INSERT INTO Incarico
            VALUES (_tecnico, interventoAttuale);
            
            SET contaIncarichi = contaIncarichi + 1;
            
            UPDATE InterventoFisico
            SET QuantiAssegnati = QuantiAssegnati + 1
            WHERE Ticket = interventoAttuale;
            
            SET @controllo =
					(
                     SELECT IF(QuantiAssegnati = TecniciRichiesti, 1, 0)
                     FROM InterventoFisico INNER JOIN AssistenzaFisica ON CodiceAssistenza = AssistenzaFisica
                     WHERE Ticket = interventoAttuale
                     );
                     
			IF(@controllo = 1) THEN
            
				UPDATE InterventoFisico
                SET Stato = 'Assegnato'
                WHERE Ticket= interventoAttuale;
                
			END IF;
            
            ITERATE assegna;
        
          ELSE
          
			-- Se si entra in questo else significa che non ci sono più interventi "parzialmente assegnati" e bisogna iniziare a crearne di nuovi basandoci sulle richieste d'assistenza
                 SELECT AF.CodiceAssistenza, AF.TecniciRichiesti INTO assistenza, @richiesti
                 FROM AssistenzaFisica AF INNER JOIN UnitaVendute UV ON UV.UID = AF.UnitaVendute 
					  INNER JOIN OrdineVendita OO ON OO.CodOrdine = UV.OrdineVendita
					  INNER JOIN Account ACC ON ACC.NomeUtente = OO.Account
                      INNER JOIN Utente U ON U.CodFiscale = ACC.Utente
                 WHERE U.Provincia = ProvinciaTecnico 
							AND NOT EXISTS
										(
                                         SELECT *
                                         FROM InterventoFisico II
                                         WHERE II.AssistenzaFisica = AF.CodiceAssistenza
                                         )
				ORDER BY AF.DataRichiesta
                LIMIT 1;
                
			SET @maxcurrentTicket =
					(
                     SELECT MAX(Ticket)
                     FROM InterventoFisico
                     );
            IF(assistenza <> 'ciao') THEN         
            INSERT INTO InterventoFisico VALUES ( @maxcurrentTicket + 1, assistenza, 1, IF(@richiesti = 1, 'Assegnato', 'InAssegnazione'));
            SET contaIncarichi = contaIncarichi + 1;
            
            INSERT INTO Incarico VALUES(_tecnico, @maxcurrentTicket + 1);
            
            ELSE
            
			SELECT 'Incarichi non disponibili!';
			LEAVE assegna;
            END IF;
			
          END IF;
            
		
    END LOOP;
	
END $$

/**************************************************************** DATA ANALYTICS *********************************************************************************/

/****** ANALYTICS 1 ******/

DROP PROCEDURE IF EXISTS Retrieve $$

CREATE PROCEDURE Retrieve( IN _assistenzaFisica VARCHAR(20) )
BEGIN
    WITH
    RetrieveTable AS (
        SELECT C.AIM,
               C.Guasto AS GuastoProbabile, 
               COUNT(*)*100/(SELECT COUNT(*) FROM SintomiAccusati WHERE AssistenzaFisica = _assistenzaFisica) AS Compatibilita
        FROM Conoscenza C INNER JOIN SintomiMemorizzati SM ON SM.Conoscenza = C.AIM
        WHERE SM.Sintomo IN (
                              SELECT Sintomo
                              FROM SintomiAccusati
                              WHERE AssistenzaFisica = _assistenzaFisica
                              )
        GROUP BY C.AIM
        HAVING COUNT(*) >= (((SELECT COUNT(*) FROM SintomiAccusati WHERE AssistenzaFisica = _assistenzaFisica) * 66) / 100)
        ORDER BY C.DataRisoluzione
    ),
    RimediDaConsiderare AS (
        SELECT RU.CodRimedio, RU.Conoscenza
        FROM RimediUtilizzati RU
        WHERE RU.Conoscenza IN (SELECT AIM FROM RetrieveTable)
    ),
    Fase_Reuse AS (
        SELECT RC.CodRimedio, SUM(IF( R.Compatibilita BETWEEN 66 AND 79, 
									  5*(10/(
											SELECT COUNT(*) 
											FROM RimediDaConsiderare RC2 NATURAL JOIN RetrieveTable R2 
											WHERE RC2.CodRimedio = RC.CodRimedio)), 
                                      3*(10/(
                                             SELECT COUNT(*) 
                                             FROM RimediDaConsiderare RC2 NATURAL JOIN RetrieveTable R2 
                                             WHERE RC2.CodRimedio = RC.CodRimedio))
								)) AS PartialScore1
        FROM RimediDaConsiderare RC NATURAL JOIN RetrieveTable R
        GROUP BY RC.CodRimedio
    ),
    Fase_Reuse_2 AS (
        SELECT RC.CodRimedio, COUNT(*) AS PartialScore2
        FROM RimediDaConsiderare RC NATURAL JOIN RetrieveTable R
        GROUP BY RC.CodRimedio
    ),
    Final_Phase AS (
        SELECT CodRimedio, PartialScore1+PartialScore2 AS Score 
        FROM Fase_Reuse NATURAL JOIN Fase_Reuse_2 
    )
    SELECT *
    FROM Final_Phase
    ORDER BY Score DESC;
 
END $$



/****** ANALYTICS 2 ******/

-- Creazione e inizializzazione Tabella
DROP TABLE IF EXISTS ValutazioneLinee $$
CREATE TABLE ValutazioneLinee(
Linea VARCHAR(50) NOT NULL,
LottoRiferimentoPrecedente INTEGER DEFAULT 0,
NumeroLottiProdotti INTEGER DEFAULT 0,
ValutazioneAttuale VARCHAR(20) DEFAULT NULL,
PRIMARY KEY (Linea)
) ENGINE = InnoDB DEFAULT CHAR SET latin1 $$

-- Primo Riempimento: inseriamo solo linee che hanno prodotto lotti INTERI (ovvero recuperando tutte le unità perse per quel lotto
INSERT INTO ValutazioneLinee
SELECT L.CodLinea, 0, COUNT(*), NULL
FROM Linea L INNER JOIN LottoProduzione LP ON L.CodLinea = LP.Linea
WHERE LP.UnitaEffettive = LP.UnitaPreviste
GROUP BY L.CodLinea $$



DROP PROCEDURE IF EXISTS PerformanceLinea $$
CREATE PROCEDURE PerformanceLinea()
BEGIN

DECLARE lineaCorrente VARCHAR(20) DEFAULT '';
DECLARE ultimaValutazione VARCHAR(30) DEFAULT '';
DECLARE ultimoLotto INTEGER DEFAULT 0;
DECLARE unitaPrevisteMediamente INTEGER DEFAULT 0;
DECLARE perditaMedia INTEGER DEFAULT 0;
DECLARE finito INTEGER DEFAULT 0;

-- Stabilisco le linee di cui fare la valutazione 
DECLARE linee CURSOR FOR
SELECT VL.Linea, VL.ValutazioneAttuale
FROM ValutazioneLinee VL
WHERE (VL.LottoRiferimentoPrecedente = 0 AND VL.NumeroLottiProdotti - VL.LottoRiferimentoPrecedente >= 5)
		OR(VL.LottoRiferimentoPrecedente <> 0 AND (
			SELECT COUNT(*)
            FROM LottoProduzione
            WHERE Linea = VL.Linea AND DataProduzione > (
													      SELECT LP2.DataProduzione
                                                          FROM LottoProduzione LP2
                                                          WHERE LP2.CodLotto = VL.LottoRiferimentoPrecedente
                                                          )) >= 5);
                                                          
DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
INSERT INTO ValutazioneLinee
SELECT L.CodLinea, 0, COUNT(*), NULL
FROM Linea L INNER JOIN LottoProduzione LP ON L.CodLinea = LP.Linea
WHERE LP.UnitaEffettive = LP.UnitaPreviste AND L.CodLinea NOT IN ( SELECT VL2.Linea FROM ValutazioneLinee VL2)
GROUP BY L.CodLinea;

OPEN linee;

scanner : LOOP
	FETCH linee INTO lineaCorrente, ultimaValutazione;
    IF( finito = 1 ) THEN 
		LEAVE scanner;
	END IF;
         
     SET ultimoLotto =
		(
         SELECT IF(LottoRiferimentoPrecedente = 0, (SELECT LP.CodLotto
													FROM LottoProduzione LP 
													WHERE LP.Linea = lineaCorrente
															AND LP.DataProduzione =  (
																					  SELECT MIN(LP2.DataProduzione)
																					  FROM LottoProduzione LP2
																					  WHERE LP2.Linea = lineaCorrente)), LottoRiferimentoPrecedente)
                                          
         FROM ValutazioneLinee
         WHERE Linea = lineaCorrente
         );
    
    
    SET unitaPrevisteMediamente =
		(
         SELECT AVG(UnitaPreviste)
         FROM Linea L INNER JOIN LottoProduzione LP ON Linea = CodLinea
         WHERE LP.Linea = lineaCorrente AND LP.DataProduzione > (
								SELECT DataProduzione
                                FROM LottoProduzione
                                WHERE CodLotto = ultimoLotto
		));
   
    -- Nel valutare la linea corrente, abbiamo bisogno anzitutto della media unità perse nei lotti che vanno dal primo non considerato al corrente
    SELECT AVG(LP.UnitaPreviste - LP.PrimaProduzione) INTO @mediaPerse
    FROM Linea L INNER JOIN LottoProduzione LP ON LP.Linea = L.CodLinea
			-- NATURAL JOIN ValutazioneLinee VL  -- Deve essere una linea valutata!
    WHERE LP.Linea = lineaCorrente AND LP.DataProduzione > (
								SELECT DataProduzione
                                FROM LottoProduzione
                                WHERE CodLotto = ultimoLotto
                                );
	SET @lottoNuovo =(
		SELECT LP.CodLotto
        FROM LottoProduzione LP 
        WHERE LP.Linea = lineaCorrente AND LP.DataProduzione >= ALL
																	(
                                                                     SELECT DataProduzione
                                                                     FROM LottoProduzione
                                                                     WHERE Linea = lineaCorrente
                                                                     ));
                                                                     
    SET perditaMedia = @mediaPerse/unitaPrevisteMediamente * 100;
    IF(perditaMedia< 10 AND ultimaValutazione IS NULL)  THEN
			UPDATE ValutazioneLinee
            SET ValutazioneAttuale = 'Ottima', LottoRiferimentoPrecedente = @lottoNuovo
            WHERE Linea = lineaCorrente;
	END IF;
	IF(perditaMedia < 10 AND ultimaValutazione IS NOT NULL) THEN
			UPDATE ValutazioneLinee
            SET ValutazioneAttuale = 'Ottimizzata', LottoRiferimentoPrecedente = @lottoNuovo
            WHERE Linea = lineaCorrente;
	END IF;
    IF(perditaMedia BETWEEN 10 AND 49) THEN
			UPDATE ValutazioneLinee
            SET ValutazioneAttuale = 'InValutazione', LottoRiferimentoPrecedente = @lottoNuovo
            WHERE Linea = lineaCorrente;
            
            UPDATE Linea
            SET Tempo = Tempo + 3
            WHERE CodLinea = lineaCorrente;
	END IF;
    IF (perditaMedia > 49 AND ultimaValutazione = 'InChiusura') THEN
			UPDATE ValutazioneLinee
            SET ValutazioneAttuale = 'Chiusa', LottoRiferimentoPrecedente = @lottoNuovo
            WHERE Linea = lineaCorrente;
    END IF;
    
    IF(perditaMedia > 49 AND ultimaValutazione <> 'InChiusura' AND ultimaValutazione <> 'Chiusa') THEN
			UPDATE ValutazioneLinee
            SET ValutazioneAttuale = 'InChiusura', LottoRiferimentoPrecedente = @lottoNuovo
            WHERE Linea = lineaCorrente;
            
            
            UPDATE Linea
            SET Tempo = Tempo + 5
            WHERE CodLinea = lineaCorrente;
    END IF;

END LOOP;
CLOSE linee;

END $$


/****** ANALYTICS 3 ******/

DROP TABLE IF EXISTS DatiVendita $$
DROP TABLE IF EXISTS Score $$
DROP TABLE IF EXISTS LOG_Unita $$

CREATE TABLE DatiVendita (
	Prodotto VARCHAR(10),
    Variante VARCHAR(15),
    Anno INT,
    Trimestre INT,
    GNPU FLOAT DEFAULT 0,
    CP FLOAT DEFAULT 0, 
    CMP FLOAT DEFAULT 0,
    PPR FLOAT DEFAULT 0,
    CMM FLOAT DEFAULT 0,
    CMS FLOAT DEFAULT 0,
    PMR FLOAT DEFAULT 0,
    UP FLOAT DEFAULT 0,
    UV FLOAT DEFAULT 0,
    US FLOAT DEFAULT 0,
    UR FLOAT DEFAULT 0, 
    USM FLOAT DEFAULT 0,
    PRIMARY KEY (Prodotto, Variante, Anno, Trimestre)
);

CREATE TABLE Score (
	Prodotto VARCHAR(10) NOT NULL,
    Variante VARCHAR(15) NOT NULL,
	Anno INT NOT NULL,
    Trimestre INT NOT NULL, 
    Punteggio FLOAT,
    PRIMARY KEY (Prodotto, Variante, Anno, Trimestre)
);

CREATE TABLE LOG_Unita (
	DataAggiornamento DATE NOT NULL, 
    Prodotto VARCHAR(10) NOT NULL,
	Variante VARCHAR(15) NOT NULL,
    UP INT DEFAULT 0,
    UV INT DEFAULT 0,
    US INT DEFAULT 0,
    UR INT DEFAULT 0,
    USM INT DEFAULT 0,
    PRIMARY KEY (DataAggiornamento, Prodotto, Variante)
);

DROP PROCEDURE IF EXISTS BuildScore $$


CREATE PROCEDURE BuildScore(IN _Prodotto VARCHAR(10), IN _Variante VARCHAR(15))
BEGIN
	DECLARE GuadagnoVendita INT DEFAULT 0;
    DECLARE GuadagnoSospeso INT DEFAULT 0;
    DECLARE Trime_stre INT;
    DECLARE An_no INT;
    DECLARE Score INT DEFAULT 0;
    
    IF MONTH(CURRENT_DATE()) <= 3 THEN
		SET Trime_stre = 1;
	ELSEIF (MONTH(CURRENT_DATE()) > 3 AND MONTH(CURRENT_DATE()) <= 6) THEN
		SET Trime_stre = 2;
	ELSEIF(MONTH(CURRENT_DATE()) > 6 AND MONTH(CURRENT_DATE()) <= 9) THEN
		SET Trime_stre = 3;
	ELSEIF (MONTH(CURRENT_DATE()) > 9) THEN
		SET Trime_stre = 4;
	END IF;
    
    SET GuadagnoVendita = (SELECT GNPU*(UV - UP) + USM*(CMP*PPR + CMM*PMR*CMS)
							FROM DatiVendita DV
                            WHERE DV.Prodotto = _Prodotto AND
								  DV.Variante = _Variante AND
                                  DV.Anno = YEAR(CURRENT_DATE()) AND
                                  MONTH(CURRENT_DATE()) <= DV.Trimestre*3 AND
                                  MONTH(CURRENT_DATE()) > DV.Trimestre*3 - 3);
                                  
	SET GuadagnoSospeso = (SELECT UR*(GNPU*0.25) + US*(GNPU*0.75)
                           FROM DatiVendita DV
						   WHERE DV.Prodotto = _Prodotto AND
								  DV.Variante = _Variante AND
                                  DV.Anno = YEAR(CURRENT_DATE()) AND
                                  MONTH(CURRENT_DATE()) <= DV.Trimestre*3 AND
                                  MONTH(CURRENT_DATE()) > DV.Trimestre*3 - 3);
                                  
	SET Score = GuadagnoVendita - GuadagnoSospeso;
    SET An_no = YEAR(current_date());
    
    INSERT INTO Score(Prodotto, Variante, Anno, Trimestre, Punteggio)
    VALUES (_Prodotto, _Variante, An_no, Trime_stre, Score);
    
END $$



DROP TRIGGER IF EXISTS Aggiorna_LOG_UnitaPerse $$


CREATE TRIGGER Aggiorna_LOG_UnitaPerse
AFTER INSERT ON unitaperseproduzione
FOR EACH ROW 
BEGIN 
	DECLARE unita INT;
    DECLARE prodo_tto VARCHAR(10);
    DECLARE varia_nte VARCHAR(15);
    DECLARE flag INT DEFAULT 0;
    
    SET unita = NEW.Quante;
    
    SELECT UD.Prodotto INTO prodo_tto
    FROM unitaperseproduzione UPP INNER JOIN lottoproduzione LP ON UPP.Lotto = LP.CodLotto
		 INNER JOIN unitadisponibili UD ON UD.LottoProduzione = UPP.Lotto;
	
    SELECT UD.Variante INTO varia_nte
    FROM unitaperseproduzione UPP INNER JOIN lottoproduzione LP ON UPP.Lotto = LP.CodLotto
		 INNER JOIN unitadisponibili UD ON UD.LottoProduzione = UPP.Lotto;
	
    SELECT 1 INTO flag
    FROM LOG_Unita
    WHERE Prodotto = prodo_tto AND
		  Variante = varia_nte;
          
	IF flag = 1 THEN 
		UPDATE LOG_unita
		SET UP = UP + unita, DataAggiornamento = CURRENT_DATE()
		WHERE log_unita.Prodotto = prodo_tto AND log_unita.Variante = varia_nte;
	ELSEIF flag = 0 THEN
		INSERT INTO LOG_Unita(DataAggiornamento, Prodotto, Variante, UP, UV, US, UR, USM)
        VALUES (CURRENT_DATE(), prodo_tto, varia_nte, unita, 0, 0, 0, 0);
	END IF;
    
END $$


DROP TRIGGER IF EXISTS Aggiorna_LOG_UnitaVendute $$


CREATE TRIGGER Aggiorna_LOG_UnitaVendute
AFTER INSERT ON unitavendute
FOR EACH ROW
BEGIN
	DECLARE flag INT DEFAULT 0;
    
    SELECT 1 INTO flag 
    FROM LOG_Unita
    WHERE Prodotto = NEW.Prodotto AND
		  Variante = NEW.Variante;
	
    IF flag = 1 THEN 
		UPDATE LOG_Unita
        SET UV = UV + 1, DataAggiornamento = CURRENT_DATE()
        WHERE LOG_Unita.Prodotto = NEW.Prodotto AND
			  LOG_Unita.Prodotto = NEW.Prodotto;
    ELSEIF flag = 0 THEN
		INSERT INTO LOG_Unita(DataAggiornamento, Prodotto, Variante, UP, UV, US, UR, USM)
        VALUES (CURRENT_DATE(), NEW.Prodotto, NEW.Variante, 0, 1, 0, 0, 0);
	END IF;
		
END $$


DROP TRIGGER IF EXISTS Aggiorna_LOG_UnitaStoccate $$


CREATE TRIGGER Aggiorna_LOG_UnitaStoccate
AFTER INSERT ON unitadisponibili
FOR EACH ROW
BEGIN
	DECLARE flag INT DEFAULT 0;
    DECLARE var INT DEFAULT 0;
    
    SELECT 1 INTO flag 
    FROM LOG_Unita
    WHERE Prodotto = NEW.Prodotto AND
		  Variante = NEW.Variante;
	
    IF flag = 1 THEN 
		UPDATE LOG_Unita
        SET US = US + 1, DataAggiornamento = CURRENT_DATE()
        WHERE LOG_Unita.Prodotto = NEW.Prodotto AND
			  LOG_Unita.Prodotto = NEW.Prodotto;
    ELSEIF flag = 0 THEN
		SELECT COUNT(*) INTO var
        FROM unitadisponibili
        WHERE Prodotto = NEW.Prodotto AND
			  Variante = NEW.Variante;
		INSERT INTO LOG_Unita(DataAggiornamento, Prodotto, Variante, UP, UV, US, UR, USM)
        VALUES (CURRENT_DATE(), NEW.Prodotto, NEW.Variante, 0, 0, var, 0, 0);
	END IF;
		
END $$


DROP TRIGGER IF EXISTS Aggiorna_LOG_UnitaRicondizionate $$


CREATE TRIGGER Aggiorna_LOG_UnitaRicondizionate
AFTER INSERT ON unitaricondizionate
FOR EACH ROW
BEGIN
	DECLARE flag INT DEFAULT 0;
    DECLARE var INT DEFAULT 0;
    
    SELECT 1 INTO flag 
    FROM LOG_Unita
    WHERE Prodotto = NEW.Prodotto AND
		  Variante = NEW.Variante;
	
    IF flag = 1 THEN 
		UPDATE LOG_Unita
        SET UR = UR + 1, DataAggiornamento = CURRENT_DATE()
        WHERE LOG_Unita.Prodotto = NEW.Prodotto AND
			  LOG_Unita.Prodotto = NEW.Prodotto;
    ELSEIF flag = 0 THEN
		INSERT INTO LOG_Unita(DataAggiornamento, Prodotto, Variante, UP, UV, US, UR, USM)
        VALUES (CURRENT_DATE(), NEW.Prodotto, NEW.Variante, 0, 0, 0, 1, 0);
	END IF;
		
END $$


DROP TRIGGER IF EXISTS Aggiorna_LOG_UnitaSmaltite1 $$


CREATE TRIGGER Aggiorna_LOG_UnitaSmaltite1
AFTER INSERT ON recuperomateriale
FOR EACH ROW
BEGIN
	DECLARE flag1 INT DEFAULT 0;
	DECLARE flag2 INT DEFAULT 0;
    DECLARE var INT DEFAULT 0;
    
    SELECT COUNT(*) INTO flag1
    FROM recuperomateriale
    WHERE UnitaEndOfLife = NEW.UnitaEndOfLife;
    
    SELECT COUNT(*) INTO flag2
    FROM recuperoparte
    WHERE UnitaEndOfLife = NEW.UnitaEndOfLife;
    
    SELECT 1 INTO var
    FROM log_unita
    WHERE Prodotto = (SELECT Prodotto FROM unitaendoflife WHERE UID = NEW.UnitaEndOfLife) AND
		  Variante = (SELECT Variante FROM unitaendoflife WHERE UID = NEW.UnitaEndOfLife);
    
    IF flag1 <= 1 THEN
		IF flag2 = 0 THEN
			IF var = 1 THEN
				UPDATE log_unita
				SET USM = USM + 1, DataAggiornamento = CURRENT_DATE()
				WHERE Prodotto = (SELECT Prodotto FROM unitaendoflife WHERE UID = NEW.UnitaEndOfLife) AND
					  Variante = (SELECT Variante FROM unitaendoflife WHERE UID = NEW.UnitaEndOfLife);
			ELSEIF var = 0 THEN
				INSERT INTO LOG_Unita(DataAggiornamento, Prodotto, Variante, UP, UV, US, UR, USM)
                        VALUES (CURRENT_DATE(), 
							    (SELECT Prodotto FROM unitaendoflife WHERE UID = NEW.UnitaEndOfLife), 
                                (SELECT Variante FROM unitaendoflife WHERE UID = NEW.UnitaEndOfLife),
                                0, 0, 0, 0, 1);
		END IF;
		END IF;
	END IF;
    
END $$


DROP TRIGGER IF EXISTS Aggiorna_LOG_UnitaSmaltite2 $$


CREATE TRIGGER Aggiorna_LOG_UnitaSmaltite2
AFTER INSERT ON recuperoparte
FOR EACH ROW
BEGIN
	DECLARE flag1 INT DEFAULT 0;
	DECLARE flag2 INT DEFAULT 0;
    DECLARE var INT DEFAULT 0;
    
    SELECT COUNT(*) INTO flag1
    FROM recuperomateriale
    WHERE UnitaEndOfLife = NEW.UnitaEndOfLife;
    
    SELECT COUNT(*) INTO flag2
    FROM recuperoparte
    WHERE UnitaEndOfLife = NEW.UnitaEndOfLife;
    
    SELECT 1 INTO var
    FROM log_unita
    WHERE Prodotto = (SELECT Prodotto FROM unitaendoflife WHERE UID = NEW.UnitaEndOfLife) AND
		  Variante = (SELECT Variante FROM unitaendoflife WHERE UID = NEW.UnitaEndOfLife);
    
    IF flag1 = 0 THEN
		IF flag2 <= 1 THEN
			IF var = 1 THEN
				UPDATE log_unita
				SET USM = USM + 1, DataAggiornamento = CURRENT_DATE()
				WHERE Prodotto = (SELECT Prodotto FROM unitaendoflife WHERE UID = NEW.UnitaEndOfLife) AND
					  Variante = (SELECT Variante FROM unitaendoflife WHERE UID = NEW.UnitaEndOfLife);
			ELSEIF var = 0 THEN
				INSERT INTO LOG_Unita(DataAggiornamento, Prodotto, Variante, UP, UV, US, UR, USM)
                        VALUES (CURRENT_DATE(), 
							    (SELECT Prodotto FROM unitaendoflife WHERE UID = NEW.UnitaEndOfLife), 
                                (SELECT Variante FROM unitaendoflife WHERE UID = NEW.UnitaEndOfLife),
                                0, 0, 0, 0, 1);
		END IF;
		END IF;
	END IF;
    
END $$


CREATE PROCEDURE MV_partial_refresh(IN _var DATE)
BEGIN
	DECLARE prezzo_ FLOAT;
    DECLARE cp_ FLOAT;
    DECLARE cmp_ FLOAT;
    DECLARE ppr_ FLOAT;
    DECLARE cmm_ FLOAT;
    DECLARE cms_ FLOAT;
    DECLARE pmr_ FLOAT;
    DECLARE prodotto_ VARCHAR(10);
    DECLARE variante_ VARCHAR(15);
    DECLARE up_ FLOAT;
    DECLARE uv_ FLOAT;
    DECLARE us_ FLOAT;
    DECLARE ur_ FLOAT;
    DECLARE usm_ FLOAT;
    
    DECLARE flag INT DEFAULT 1;
    
    DECLARE cursore CURSOR FOR
    SELECT Prodotto, Variante, UP, UV, US, UR, USM
    FROM log_unita
    WHERE log_unita.DataAggiornamento <= _var;
    
    DECLARE  CONTINUE HANDLER FOR NOT FOUND 
    SET flag = 0;
    
    OPEN cursore;
    
    ciclo: LOOP
			FETCH cursore INTO prodotto_, variante_, up_, uv_, us_, ur_, usm_; 
            /*Salvo la coppia prodotto-variante, prelevata dalla log table, il cui ultimo aggiornamento è avvenuto prima della data specificata.*/
		IF flag = 1 THEN 
            
            SELECT V.Prezzo INTO prezzo_ 
            FROM Varianza V 
            WHERE V.Prodotto = prodotto_ AND V.Variante = variante_;
            /*Salvo nella variabile cp il prezzo attuale di vendita di quella variante del prodotto.*/
            
            SELECT SUM(P.Prezzo*C.Pezzi) INTO cp_ 
            FROM Parte P INNER JOIN Composizione C ON P.CodParte = C.Parte 
            WHERE C.Prodotto = prodotto_;
            /*Calcolo il costo di produzione di quella tipologia di prodotto.*/
            
            SELECT AVG(Prezzo) INTO cmp_ 
            FROM Parte P INNER JOIN Composizione C ON P.CodParte = C.Parte 
            WHERE C.Prodotto = prodotto_;
            /*Calcolo il costo medio delle parti che compongono il prodotto.*/
            
            SELECT IFNULL(AVG((tot*100)/Parti), 0) INTO ppr_             /*Calcolo la media delle percentuali di parti recuperate sino in quel momento.*/
            FROM ( SELECT UEOL.UID,
				   SUM(Quantita) AS tot, 
				   (SELECT COUNT(*) FROM Composizione WHERE Prodotto = prodotto_) AS Parti
			       FROM recuperoparte RP INNER JOIN unitaendoflife UEOL ON RP.UnitaEndOfLife = UEOL.UID
				   WHERE UEOL.Prodotto = prodotto_ AND UEOL.Variante = variante_
                   GROUP BY UID) AS A;
            
            SELECT AVG(M.Valore) INTO cmm_                    /*Calcolo la media dei valori dei materiali presenti nel prodotto.*/
            FROM Materiale M INNER JOIN Struttura S ON M.Nome = S.Materiale
            INNER JOIN (SELECT CodParte
                        FROM Parte P INNER JOIN Composizione C ON P.CodParte = C.Parte
                        WHERE C.Prodotto = prodotto_) AS D ON D.CodParte = S.Parte;
			
            SELECT AVG(M.CoeffSvalutazione) INTO cms_         /*Calcolo la media dei coefficienti di svalutazione dei materiali presenti*/
            FROM Materiale M INNER JOIN Struttura S ON M.Nome = S.Materiale            /*nel prodotto.*/
            INNER JOIN (SELECT CodParte
                        FROM Parte P INNER JOIN Composizione C ON P.CodParte = C.Parte
                        WHERE C.Prodotto = prodotto_) D ON D.CodParte = S.Parte;
                              
            SELECT IFNULL(AVG((tot*100)/PesoTot), 0) INTO pmr_         /*Calcolo la media della percentuale di materiale recuperato sino al momento*/
            FROM 	(   SELECT UEOL.UID,
						SUM(Quantita) AS tot, 
				        (SELECT peso FROM infovarianza WHERE CodProdotto = prodotto_ AND CodVariante = variante_) AS PesoTot
			            FROM recuperomateriale RM INNER JOIN unitaendoflife UEOL ON RM.UnitaEndOfLife = UEOL.UID
			            WHERE UEOL.Prodotto = prodotto_ AND UEOL.Variante = variante_
                        GROUP BY UID )
					AS B;                                        /*per quel prodotto.*/
            
            INSERT INTO DatiVendita VALUES (prodotto_, variante_, YEAR(_var), trimestre(_var), ((prezzo_)-(cp_)), cp_, cmp_, ppr_, cmm_, cms_, pmr_, up_, uv_, us_, ur_, usm_);
            DELETE FROM log_unita WHERE DataAggiornamento <= _var AND log_unita.Prodotto = prodotto_ AND log_unita.Variante = variante_;
            CALL BuildScore(prodotto_, variante_);
		ELSEIF flag = 0 THEN 
			LEAVE ciclo;
		END IF;
    END LOOP;
    
    CLOSE cursore;
    
END $$

DROP FUNCTION IF EXISTS trimestre $$

CREATE FUNCTION trimestre(_var DATE)
RETURNS INT DETERMINISTIC 
BEGIN
	IF MONTH(_var) <= 3 THEN
		RETURN 1;
	ELSEIF (MONTH(_var) > 3 AND MONTH(_var) <= 6) THEN
		RETURN 2;
	ELSEIF(MONTH(_var) > 6 AND MONTH(_var) <= 9) THEN
		RETURN 3;
	ELSEIF (MONTH(_var) > 9) THEN
		RETURN 4;
	END IF;
END $$


DROP EVENT IF EXISTS MV_deffered_refresh $$

CREATE EVENT MV_deffered_refresh
ON SCHEDULE EVERY 3 MONTH
STARTS '2020-04-01 23:55'
DO
CALL MV_partial_refresh(CURRENT_DATE()) $$

DELIMITER ;