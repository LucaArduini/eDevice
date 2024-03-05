-- -----------------------------------------------------
-- Codice per la creazione del DataBase compreso di trigger, event, procedure ed analytics
-- Gruppo Arduini, Casu, De Marco
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS Progetto;
CREATE SCHEMA IF NOT EXISTS Progetto DEFAULT CHARACTER SET utf8 ;
USE Progetto ;



DROP TABLE IF EXISTS CategoriaProdotto ;

CREATE TABLE IF NOT EXISTS CategoriaProdotto (
  Categoria VARCHAR(3) NOT NULL,
  Nome VARCHAR(30) NOT NULL,
  PRIMARY KEY (Categoria))
ENGINE = InnoDB;



DROP TABLE IF EXISTS Prodotto ;

CREATE TABLE IF NOT EXISTS Prodotto (
  CodProdotto VARCHAR(10) NOT NULL,
  Nome VARCHAR(30) NOT NULL,
  NumeroFacce TINYINT NOT NULL,
  DataCommercio DATE NOT NULL,
  Categoria VARCHAR(3) NOT NULL,
  PRIMARY KEY (CodProdotto),
    FOREIGN KEY (Categoria)
    REFERENCES CategoriaProdotto (Categoria)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (Categoria)
    REFERENCES CategoriaProdotto (Categoria)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS ClasseGuasto ;

CREATE TABLE IF NOT EXISTS ClasseGuasto (
  Nome VARCHAR(45) NOT NULL,
  Descrizione TEXT(200) NULL,
  PRIMARY KEY (Nome))
ENGINE = InnoDB;



DROP TABLE IF EXISTS Guasto ;

CREATE TABLE IF NOT EXISTS Guasto (
  Codice INT NOT NULL,
  Nome VARCHAR(50) NOT NULL,
  Classe VARCHAR(45) NULL,
  PRIMARY KEY (Codice),
    FOREIGN KEY (Classe)
    REFERENCES ClasseGuasto (Nome)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS RelativoA ;

CREATE TABLE IF NOT EXISTS RelativoA (
  CodGuasto INT NOT NULL,
  CodProdotto VARCHAR(10) NOT NULL,
  PRIMARY KEY (CodGuasto, CodProdotto),
    FOREIGN KEY (CodGuasto)
    REFERENCES Guasto (Codice)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (CodProdotto)
    REFERENCES Prodotto (CodProdotto)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS Utente ;

CREATE TABLE IF NOT EXISTS Utente (
  CodFiscale VARCHAR(16) NOT NULL,
  Nome VARCHAR(30) NOT NULL,
  Cognome VARCHAR(30) NOT NULL,
  Citta VARCHAR(30) NOT NULL,
  Provincia VARCHAR(30) NOT NULL,
  Indirizzo TEXT(100) NOT NULL,
  Telefono VARCHAR(30) NOT NULL,
  PRIMARY KEY (CodFiscale))
ENGINE = InnoDB;



DROP TABLE IF EXISTS Account ;

CREATE TABLE IF NOT EXISTS Account (
  NomeUtente VARCHAR(30) NOT NULL,
  Email VARCHAR(30) NOT NULL,
  Password VARCHAR(30) NOT NULL,
  DomandaSicurezza VARCHAR(45) NOT NULL,
  Risposta VARCHAR(45) NOT NULL,
  IndirizzoConsegna VARCHAR(30) NULL,
  Credito FLOAT NOT NULL DEFAULT 0.0,
  Utente VARCHAR(16) NOT NULL,
  PRIMARY KEY (NomeUtente),
    FOREIGN KEY (Utente)
    REFERENCES Utente (CodFiscale)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS Giudizio ;

CREATE TABLE IF NOT EXISTS Giudizio (
  Valutazione INT NOT NULL,
  Commento TEXT(400) NULL,
  Prodotto VARCHAR(10) NOT NULL,
  Account VARCHAR(30) NOT NULL,
  PRIMARY KEY (Prodotto, Account),
    FOREIGN KEY (Prodotto)
    REFERENCES Prodotto (CodProdotto)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (Account)
    REFERENCES Account (NomeUtente)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS Variante ;

CREATE TABLE IF NOT EXISTS Variante (
  CodVariante VARCHAR(15) NOT NULL,
  Descrizione TEXT(100) NOT NULL,
  PRIMARY KEY (CodVariante))
ENGINE = InnoDB;



DROP TABLE IF EXISTS Varianza ;

CREATE TABLE IF NOT EXISTS Varianza (
  Prodotto VARCHAR(10) NOT NULL,
  Variante VARCHAR(15) NOT NULL,
  Prezzo FLOAT NOT NULL,
  PRIMARY KEY (Prodotto, Variante),
    FOREIGN KEY (Prodotto)
    REFERENCES Prodotto (CodProdotto)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (Variante)
    REFERENCES Variante (CodVariante)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS Parte ;

CREATE TABLE IF NOT EXISTS Parte (
  CodParte INT NOT NULL AUTO_INCREMENT,
  Nome VARCHAR(30) NOT NULL,
  Prezzo FLOAT NOT NULL,
  Peso FLOAT NOT NULL DEFAULT 0,
  PRIMARY KEY (CodParte))
ENGINE = InnoDB;



DROP TABLE IF EXISTS Materiale ;

CREATE TABLE IF NOT EXISTS Materiale (
  Nome VARCHAR(15) NOT NULL,
  Valore FLOAT NOT NULL,
  CoeffSvalutazione FLOAT NOT NULL,
  PRIMARY KEY (Nome))
ENGINE = InnoDB;



DROP TABLE IF EXISTS Rimedio ;

CREATE TABLE IF NOT EXISTS Rimedio (
  CodRimedio INT NOT NULL,
  Descrizione VARCHAR(200) NOT NULL,
  PRIMARY KEY (CodRimedio))
ENGINE = InnoDB;



DROP TABLE IF EXISTS CentroAssistenza ;

CREATE TABLE IF NOT EXISTS CentroAssistenza (
  CodCentro VARCHAR(15) NOT NULL,
  Indirizzo VARCHAR(45) NOT NULL,
  Citta VARCHAR(45) NOT NULL,
  Provincia CHAR(2) NOT NULL,
  PRIMARY KEY (CodCentro))
ENGINE = InnoDB;



DROP TABLE IF EXISTS Tecnico ;

CREATE TABLE IF NOT EXISTS Tecnico (
  CodiceFiscale VARCHAR(16) NOT NULL,
  Stipendio VARCHAR(45) NOT NULL,
  CentroAssistenza VARCHAR(15) NOT NULL,
  FasciaOraria VARCHAR(45) NOT NULL,
  Occupato TINYINT NOT NULL DEFAULT 0,
  PRIMARY KEY (CodiceFiscale),
    FOREIGN KEY (CentroAssistenza)
    REFERENCES CentroAssistenza (CodCentro)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS Preventivo ;

CREATE TABLE IF NOT EXISTS Preventivo (
  Codice INT NOT NULL,
  DataRilascio DATE NOT NULL,
  Tecnico VARCHAR(16) NOT NULL,
  PRIMARY KEY (Codice),
    FOREIGN KEY (Tecnico)
    REFERENCES Tecnico (CodiceFiscale)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS Documento ;

CREATE TABLE IF NOT EXISTS Documento (
  Numero VARCHAR(30) NOT NULL,
  Tipologia VARCHAR(30) NOT NULL,
  Scadenza DATE NOT NULL,
  Ente VARCHAR(30) NOT NULL,
  Utente VARCHAR(16) NOT NULL,
  PRIMARY KEY (Numero),
    FOREIGN KEY (Utente)
    REFERENCES Utente (CodFiscale)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS ListaGuasti ;

CREATE TABLE IF NOT EXISTS ListaGuasti (
  Preventivo INT NOT NULL,
  Guasto INT NOT NULL,
  Prezzo FLOAT NOT NULL,
  PRIMARY KEY (Preventivo, Guasto),
    FOREIGN KEY (Preventivo)
    REFERENCES Preventivo (Codice)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (Guasto)
    REFERENCES Guasto (Codice)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS Magazzino ;

CREATE TABLE IF NOT EXISTS Magazzino (
  CodMagazzino INT NOT NULL,
  Sede VARCHAR(45) NOT NULL,
  PRIMARY KEY (CodMagazzino))
ENGINE = InnoDB;



DROP TABLE IF EXISTS AreaMagazzino ;

CREATE TABLE IF NOT EXISTS AreaMagazzino (
  Area INT NOT NULL,
  Magazzino INT NOT NULL,
  Predisposizione VARCHAR(3) NOT NULL,
  Capienza FLOAT NOT NULL,
  CapienzaDisponibile FLOAT NOT NULL DEFAULT 0,
  PRIMARY KEY (Area, Magazzino),
    FOREIGN KEY (Magazzino)
    REFERENCES Magazzino (CodMagazzino)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (Predisposizione)
    REFERENCES CategoriaProdotto (Categoria)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS Sequenza ;

CREATE TABLE IF NOT EXISTS Sequenza (
  Prodotto VARCHAR(10) NOT NULL,
  Variante VARCHAR(15) NOT NULL,
  Codice INT NOT NULL,
  PRIMARY KEY (Prodotto, Variante, Codice),
    FOREIGN KEY (Prodotto)
    REFERENCES Varianza (Prodotto)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (Variante)
    REFERENCES Varianza (Variante)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS Linea ;

CREATE TABLE IF NOT EXISTS Linea (
  CodLinea VARCHAR(10) NOT NULL,
  Tempo FLOAT NOT NULL DEFAULT 0,
  Tipo CHAR(1) NOT NULL,
  Prodotto VARCHAR(10) NOT NULL,
  Variante VARCHAR(45) NOT NULL,
  Sequenza INT NOT NULL,
  PRIMARY KEY (CodLinea),
    FOREIGN KEY (Prodotto , Variante , Sequenza)
    REFERENCES Sequenza (Prodotto , Variante , Codice)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS LottoProduzione ;

CREATE TABLE IF NOT EXISTS LottoProduzione (
  CodLotto INT NOT NULL,
  DataProduzione DATE NOT NULL,
  DurataPreventivata FLOAT NOT NULL,
  DurataEffettiva FLOAT NULL,
  UnitaPreviste TINYINT NOT NULL,
  UnitaEffettive TINYINT NOT NULL,
  Linea VARCHAR(10) NOT NULL,
  Magazzino INT NOT NULL,
  Area INT NOT NULL,
  PrimaProduzione INT NOT NULL DEFAULT 0,
  PRIMARY KEY (CodLotto),
    FOREIGN KEY (Magazzino , Area)
    REFERENCES AreaMagazzino (Magazzino , Area)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (Linea)
    REFERENCES Linea (CodLinea)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS UnitaVendute ;

CREATE TABLE IF NOT EXISTS UnitaVendute (
  UID VARCHAR(15) NOT NULL,
  OrdineVendita INT NOT NULL,
  Prodotto VARCHAR(10) NOT NULL,
  Variante VARCHAR(15) NOT NULL,
  LottoProduzione INT NOT NULL,
  PRIMARY KEY (UID),
    FOREIGN KEY (Prodotto , Variante)
    REFERENCES Varianza (Prodotto , Variante)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (LottoProduzione)
    REFERENCES LottoProduzione (CodLotto)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS Sintomo ;

CREATE TABLE IF NOT EXISTS Sintomo (
  CodSintomo INT NOT NULL,
  Descrizione TEXT(100) NOT NULL,
  PRIMARY KEY (CodSintomo))
ENGINE = InnoDB;



DROP TABLE IF EXISTS AssistenzaVirtualeNOCodErrore ;

CREATE TABLE IF NOT EXISTS AssistenzaVirtualeNOCodErrore (
  CodiceAssistenza INT NOT NULL,
  DataRichiesta DATE NOT NULL,
  Riuscita TINYINT(1) NULL DEFAULT NULL,
  UnitaVendute VARCHAR(15) NOT NULL,
  Sintomo INT NOT NULL,
  PRIMARY KEY (CodiceAssistenza),
    FOREIGN KEY (UnitaVendute)
    REFERENCES UnitaVendute (UID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (Sintomo)
    REFERENCES Sintomo (CodSintomo)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS Domanda ;

CREATE TABLE IF NOT EXISTS Domanda (
  CodDomanda INT NOT NULL,
  Testo TEXT(150) NOT NULL,
  PRIMARY KEY (CodDomanda))
ENGINE = InnoDB;



DROP TABLE IF EXISTS AutoDiagnosi ;

CREATE TABLE IF NOT EXISTS AutoDiagnosi (
  AssistenzaVirtualeNOErrore INT NOT NULL,
  Rimedio INT NOT NULL,
  Domanda INT NOT NULL,
  Risposta VARCHAR(1) NOT NULL,
  PRIMARY KEY (AssistenzaVirtualeNOErrore, Rimedio, Domanda),
    FOREIGN KEY (AssistenzaVirtualeNOErrore)
    REFERENCES AssistenzaVirtualeNOCodErrore (CodiceAssistenza)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (Domanda)
    REFERENCES Domanda (CodDomanda)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (Rimedio)
    REFERENCES Rimedio (CodRimedio)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS AssistenzaVirtualeCONCodErrore ;

CREATE TABLE IF NOT EXISTS AssistenzaVirtualeCONCodErrore (
  CodiceAssistenza INT NOT NULL,
  DataRichiesta DATE NOT NULL,
  CodErrore INT NOT NULL,
  Guasto INT NOT NULL,
  Rimedio INT NOT NULL,
  UnitaVendute VARCHAR(15) NOT NULL,
  PRIMARY KEY (CodiceAssistenza),
    FOREIGN KEY (Guasto)
    REFERENCES Guasto (Codice)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (Rimedio)
    REFERENCES Rimedio (CodRimedio)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (UnitaVendute)
    REFERENCES UnitaVendute (UID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS AssistenzaFisica ;

CREATE TABLE IF NOT EXISTS AssistenzaFisica (
  CodiceAssistenza INT NOT NULL,
  DataRichiesta DATE NOT NULL,
  UnitaVendute VARCHAR(15) NOT NULL,
  TecniciRichiesti INT NOT NULL,
  PRIMARY KEY (CodiceAssistenza),
    FOREIGN KEY (UnitaVendute)
    REFERENCES UnitaVendute (UID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS SintomiAccusati ;

CREATE TABLE IF NOT EXISTS SintomiAccusati (
  Sintomo INT NOT NULL,
  AssistenzaFisica INT NOT NULL,
  PRIMARY KEY (Sintomo, AssistenzaFisica),
    FOREIGN KEY (Sintomo)
    REFERENCES Sintomo (CodSintomo)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (AssistenzaFisica)
    REFERENCES AssistenzaFisica (CodiceAssistenza)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS Conoscenza ;

CREATE TABLE IF NOT EXISTS Conoscenza (
  AIM CHAR(10) NOT NULL,
  DataRisoluzione DATE NOT NULL,
  Guasto INT NOT NULL,
  PRIMARY KEY (AIM),
    FOREIGN KEY (Guasto)
    REFERENCES Guasto (Codice)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS SintomiMemorizzati ;

CREATE TABLE IF NOT EXISTS SintomiMemorizzati (
  Sintomo INT NOT NULL,
  Conoscenza CHAR(10) NOT NULL,
  PRIMARY KEY (Sintomo, Conoscenza),
    FOREIGN KEY (Sintomo)
    REFERENCES Sintomo (CodSintomo)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (Conoscenza)
    REFERENCES Conoscenza (AIM)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS InterventoFisico ;

CREATE TABLE IF NOT EXISTS InterventoFisico (
  Ticket INT NOT NULL,
  Domicilio TINYINT NOT NULL,
  Stato VARCHAR(15) NOT NULL DEFAULT 'Da assegnare',
  OreLavoro TINYINT NULL,
  AssistenzaFisica INT NOT NULL,
  Preventivo INT NOT NULL,
  Data DATE NULL,
  QuantiAssegnati INT NOT NULL DEFAULT 0,
  PRIMARY KEY (Ticket),
    FOREIGN KEY (AssistenzaFisica)
    REFERENCES AssistenzaFisica (CodiceAssistenza)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (Preventivo)
    REFERENCES Preventivo (Codice)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS Struttura ;

CREATE TABLE IF NOT EXISTS Struttura (
  Parte INT NOT NULL,
  Materiale VARCHAR(15) NOT NULL,
  Quantità FLOAT NOT NULL,
  PRIMARY KEY (Parte, Materiale),
    FOREIGN KEY (Parte)
    REFERENCES Parte (CodParte)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (Materiale)
    REFERENCES Materiale (Nome)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS Composizione ;

CREATE TABLE IF NOT EXISTS Composizione (
  Prodotto VARCHAR(10) NOT NULL,
  Parte INT NOT NULL,
  Pezzi TINYINT NOT NULL,
  PRIMARY KEY (Prodotto, Parte),
    FOREIGN KEY (Prodotto)
    REFERENCES Prodotto (CodProdotto)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (Parte)
    REFERENCES Parte (CodParte)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS Giunzione ;

CREATE TABLE IF NOT EXISTS Giunzione (
  CodGiunzione VARCHAR(10) NOT NULL,
  Tipo VARCHAR(45) NOT NULL,
  PRIMARY KEY (CodGiunzione))
ENGINE = InnoDB;



DROP TABLE IF EXISTS ClasseCampione ;

CREATE TABLE IF NOT EXISTS ClasseCampione (
  CodSet VARCHAR(45) NOT NULL,
  Descrizione VARCHAR(100) NOT NULL,
  PRIMARY KEY (CodSet))
ENGINE = InnoDB;



DROP TABLE IF EXISTS Operazione ;

CREATE TABLE IF NOT EXISTS Operazione (
  ID INT NOT NULL,
  Descrizione VARCHAR(200) NOT NULL,
  Faccia TINYINT NOT NULL,
  Tipo CHAR(1) NOT NULL,
  ClasseCampione VARCHAR(45) NOT NULL,
  Giunzione VARCHAR(10) NULL,
  Prodotto VARCHAR(10) NOT NULL,
  Variante VARCHAR(15) NOT NULL,
  Livello TINYINT NOT NULL,
  PRIMARY KEY (ID),
    FOREIGN KEY (Giunzione)
    REFERENCES Giunzione (CodGiunzione)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (ClasseCampione)
    REFERENCES ClasseCampione (CodSet)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (Variante)
    REFERENCES Varianza (Variante)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (Prodotto)
    REFERENCES Varianza (Prodotto)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS Azione ;

CREATE TABLE IF NOT EXISTS Azione (
  Base INT NOT NULL,
  Applicata INT NOT NULL,
  Operazione INT NOT NULL,
  Sequenza INT NOT NULL,
  Ripetizioni TINYINT NOT NULL,
  PRIMARY KEY (Base, Applicata, Operazione),
    FOREIGN KEY (Operazione)
    REFERENCES Operazione (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (Base)
    REFERENCES Parte (CodParte)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (Applicata)
    REFERENCES Parte (CodParte)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS Utensile ;

CREATE TABLE IF NOT EXISTS Utensile (
  Nome VARCHAR(45) NOT NULL,
  Tipologia VARCHAR(45) NOT NULL,
  PRIMARY KEY (Nome, Tipologia))
ENGINE = InnoDB;



DROP TABLE IF EXISTS Usa ;

CREATE TABLE IF NOT EXISTS Usa (
  Operazione INT NOT NULL,
  Sequenza INT NOT NULL,
  Utensile VARCHAR(75) NOT NULL,
  PRIMARY KEY (Operazione, Sequenza, Utensile),
    FOREIGN KEY (Utensile)
    REFERENCES Utensile (Nome)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (Operazione)
    REFERENCES Operazione (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS DatiAnagraficiOperatore ;

CREATE TABLE IF NOT EXISTS DatiAnagraficiOperatore (
  Nome VARCHAR(30) NOT NULL,
  Cognome VARCHAR(30) NOT NULL,
  Citta VARCHAR(30) NOT NULL,
  CodFiscale VARCHAR(16) NOT NULL,
  DataNascita DATE NOT NULL,
  PRIMARY KEY (CodFiscale))
ENGINE = InnoDB;



DROP TABLE IF EXISTS Incarico ;

CREATE TABLE IF NOT EXISTS Incarico (
  Tecnico VARCHAR(16) NOT NULL,
  InterventoFisico INT NOT NULL,
  PRIMARY KEY (Tecnico, InterventoFisico),
    FOREIGN KEY (InterventoFisico)
    REFERENCES InterventoFisico (Ticket)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS RimediUtilizzati ;

CREATE TABLE IF NOT EXISTS RimediUtilizzati (
  Conoscenza CHAR(10) NOT NULL,
  CodRimedio INT NOT NULL,
  PRIMARY KEY (Conoscenza, CodRimedio),
    FOREIGN KEY (Conoscenza)
    REFERENCES Conoscenza (AIM)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (CodRimedio)
    REFERENCES Rimedio (CodRimedio)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS Fattura ;

CREATE TABLE IF NOT EXISTS Fattura (
  Codice INT NOT NULL,
  DataRilascio DATE NOT NULL,
  TotaleNetto FLOAT NOT NULL,
  Pagamento VARCHAR(30) NOT NULL,
  InGaranzia TINYINT NOT NULL,
  InterventoFisico INT NOT NULL,
  PRIMARY KEY (Codice),
    FOREIGN KEY (InterventoFisico)
    REFERENCES InterventoFisico (Ticket)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS Garanzia ;

CREATE TABLE IF NOT EXISTS Garanzia (
  CodGaranzia VARCHAR(10) NOT NULL,
  Descrizione TEXT(150) NOT NULL,
  Durata TINYINT NOT NULL,
  ClasseGuasti VARCHAR(45) NOT NULL,
  PRIMARY KEY (CodGaranzia),
    FOREIGN KEY (ClasseGuasti)
    REFERENCES ClasseGuasto (Nome)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS Copertura ;

CREATE TABLE IF NOT EXISTS Copertura (
  Prodotto VARCHAR(10) NOT NULL,
  Garanzia VARCHAR(10) NOT NULL,
  Prezzo FLOAT NOT NULL,
  PRIMARY KEY (Prodotto, Garanzia),
    FOREIGN KEY (Prodotto)
    REFERENCES Prodotto (CodProdotto)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (Garanzia)
    REFERENCES Garanzia (CodGaranzia)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS OrdineVendita ;

CREATE TABLE IF NOT EXISTS OrdineVendita (
  CodOrdine INT NOT NULL,
  Stato VARCHAR(20) NOT NULL DEFAULT 'InProcessazione',
  DataOrdine DATE NOT NULL,
  TotDaPagare FLOAT NOT NULL DEFAULT 0,
  Account VARCHAR(30) NOT NULL,
  PRIMARY KEY (CodOrdine),
    FOREIGN KEY (Account)
    REFERENCES Account (NomeUtente)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS Carrello ;

CREATE TABLE IF NOT EXISTS Carrello (
  Prodotto VARCHAR(10) NOT NULL,
  Variante VARCHAR(15) NOT NULL,
  OrdineVendita INT NOT NULL,
  Garanzia VARCHAR(10) NOT NULL,
  Categoria CHAR(1) NOT NULL,
  Quantita TINYINT NOT NULL,
  Stato TINYINT NOT NULL DEFAULT 1,
  PRIMARY KEY (Prodotto, Variante, OrdineVendita, Garanzia, Categoria),
    FOREIGN KEY (Prodotto , Variante)
    REFERENCES Varianza (Prodotto , Variante)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (Garanzia)
    REFERENCES Garanzia (CodGaranzia)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (OrdineVendita)
    REFERENCES OrdineVendita (CodOrdine)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS Spedizione ;

CREATE TABLE IF NOT EXISTS Spedizione (
  Codice INT NOT NULL,
  DataPrevista DATE NOT NULL,
  HubAttuale VARCHAR(30) NULL,
  Stato VARCHAR(15) NOT NULL,
  AccountConsegna VARCHAR(30) NOT NULL,
  OrdineVendita INT NOT NULL,
  PRIMARY KEY (Codice),
    FOREIGN KEY (AccountConsegna)
    REFERENCES Account (NomeUtente)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (OrdineVendita)
    REFERENCES OrdineVendita (CodOrdine)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS OrdineParti ;

CREATE TABLE IF NOT EXISTS OrdineParti (
  Codice INT NOT NULL,
  DataRichiesta DATE NOT NULL,
  DataPrevistaConsegna DATE NOT NULL,
  DataConsegna DATE NULL,
  InterventoFisico INT NOT NULL,
  PRIMARY KEY (Codice),
    FOREIGN KEY (InterventoFisico)
    REFERENCES InterventoFisico (Ticket)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS Ricambio ;

CREATE TABLE IF NOT EXISTS Ricambio (
  OrdineParti INT NOT NULL,
  Parte INT NOT NULL,
  PRIMARY KEY (OrdineParti, Parte),
    FOREIGN KEY (OrdineParti)
    REFERENCES OrdineParti (Codice)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (Parte)
    REFERENCES Parte (CodParte)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS Reso ;

CREATE TABLE IF NOT EXISTS Reso (
  Codice INT NOT NULL,
  DataRichiesta DATE NOT NULL,
  Approvato TINYINT NOT NULL,
  DataApprovazione DATE NOT NULL,
  UnitaVendute VARCHAR(10) NOT NULL,
  PRIMARY KEY (Codice),
    FOREIGN KEY (UnitaVendute)
    REFERENCES UnitaVendute (UID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS Motivazione ;

CREATE TABLE IF NOT EXISTS Motivazione (
  CodMotivazione INT NOT NULL,
  Nome VARCHAR(45) NOT NULL,
  Descrizione TEXT(200) NULL,
  PRIMARY KEY (CodMotivazione))
ENGINE = InnoDB;



DROP TABLE IF EXISTS RichiestaReso ;

CREATE TABLE IF NOT EXISTS RichiestaReso (
  Reso INT NOT NULL,
  Motivazione INT NOT NULL,
  `Account` VARCHAR(30) NOT NULL,
  Commento TEXT(400) NULL,
  PRIMARY KEY (Reso, Motivazione, Account),
    FOREIGN KEY (Reso)
    REFERENCES Reso (Codice)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (Motivazione)
    REFERENCES Motivazione (CodMotivazione)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (Account)
    REFERENCES `Account` (NomeUtente)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS UnitaDisponibili ;

CREATE TABLE IF NOT EXISTS UnitaDisponibili (
  UID VARCHAR(15) NOT NULL,
  Prodotto VARCHAR(10) NOT NULL,
  Variante VARCHAR(15) NOT NULL,
  LottoProduzione INT NOT NULL,
  PRIMARY KEY (UID),
    FOREIGN KEY (Prodotto , Variante)
    REFERENCES Varianza (Prodotto , Variante)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (LottoProduzione)
    REFERENCES LottoProduzione (CodLotto)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS LottoSmaltimento ;

CREATE TABLE IF NOT EXISTS LottoSmaltimento (
  CodLotto INT NOT NULL,
  Magazzino INT NOT NULL,
  Area INT NOT NULL,
  Linea VARCHAR(10) NOT NULL,
  DataInizioSmaltimento DATE NULL,
  PRIMARY KEY (CodLotto),
    FOREIGN KEY (Magazzino , Area)
    REFERENCES AreaMagazzino (Magazzino , Area)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (Linea)
    REFERENCES Linea (CodLinea)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS StazioneProduzione ;

CREATE TABLE IF NOT EXISTS StazioneProduzione (
  CodStazione VARCHAR(10) NOT NULL,
  Orientazione TINYINT NOT NULL,
  TempoPrevisto FLOAT NOT NULL DEFAULT 0,
  Linea VARCHAR(10) NOT NULL,
  ClasseCampione VARCHAR(45) NULL,
  PRIMARY KEY (CodStazione),
    FOREIGN KEY (Linea)
    REFERENCES Linea (CodLinea)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (ClasseCampione)
    REFERENCES ClasseCampione (CodSet)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS StazioneSmaltimento ;

CREATE TABLE IF NOT EXISTS StazioneSmaltimento (
  CodStazione VARCHAR(10) NOT NULL,
  Livello TINYINT NOT NULL,
  ParteTarget VARCHAR(45) NULL,
  Linea VARCHAR(10) NOT NULL,
  PRIMARY KEY (CodStazione),
    FOREIGN KEY (Linea)
    REFERENCES Linea (CodLinea)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS EsecuzioneProduzione ;

CREATE TABLE IF NOT EXISTS EsecuzioneProduzione (
  StazioneProduzione VARCHAR(10) NOT NULL,
  Operazione INT NOT NULL,
  Sequenza INT NOT NULL,
  PRIMARY KEY (StazioneProduzione, Operazione, Sequenza),
    FOREIGN KEY (Operazione)
    REFERENCES Operazione (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (StazioneProduzione)
    REFERENCES StazioneProduzione (CodStazione)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS EsecuzioneSmaltimento ;

CREATE TABLE IF NOT EXISTS EsecuzioneSmaltimento (
  StazioneSmaltimento VARCHAR(10) NOT NULL,
  Operazione INT NOT NULL,
  Sequenza INT NOT NULL,
  PRIMARY KEY (StazioneSmaltimento, Operazione, Sequenza),
    FOREIGN KEY (Operazione)
    REFERENCES Operazione (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (StazioneSmaltimento)
    REFERENCES StazioneSmaltimento (CodStazione)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS UnitaRese ;

CREATE TABLE IF NOT EXISTS UnitaRese (
  UID VARCHAR(15) NOT NULL,
  Reso INT NOT NULL,
  Magazzino INT NOT NULL,
  Area INT NOT NULL,
  PRIMARY KEY (UID),
    FOREIGN KEY (Magazzino , Area)
    REFERENCES AreaMagazzino (Magazzino , Area)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (Reso)
    REFERENCES Reso (Codice)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS Test ;

CREATE TABLE IF NOT EXISTS Test (
  Codice VARCHAR(10) NOT NULL,
  Nome VARCHAR(30) NOT NULL,
  TestPadre VARCHAR(10) NULL,
  Importanza TINYINT NOT NULL,
  Prodotto VARCHAR(10) NOT NULL,
  Livello INT NOT NULL,
  PRIMARY KEY (Codice),
    FOREIGN KEY (Prodotto)
    REFERENCES Prodotto (CodProdotto)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS ControlloGenerale ;

CREATE TABLE IF NOT EXISTS ControlloGenerale (
  UnitaResa VARCHAR(15) NOT NULL,
  Test VARCHAR(10) NOT NULL,
  Superato TINYINT NOT NULL,
  PRIMARY KEY (UnitaResa, Test),
    FOREIGN KEY (Test)
    REFERENCES Test (Codice)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (UnitaResa)
    REFERENCES UnitaRese (UID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS ControlloTest ;

CREATE TABLE IF NOT EXISTS ControlloTest (
  Parte INT NOT NULL,
  Test VARCHAR(10) NOT NULL,
  PRIMARY KEY (Parte, Test),
    FOREIGN KEY (Parte)
    REFERENCES Parte (CodParte)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (Test)
    REFERENCES Test (Codice)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS Ricondizionamento ;

CREATE TABLE IF NOT EXISTS Ricondizionamento (
  Parte INT NOT NULL,
  UnitaResa VARCHAR(15) NOT NULL,
  Quantita TINYINT NOT NULL,
  PRIMARY KEY (Parte, UnitaResa),
    FOREIGN KEY (Parte)
    REFERENCES Parte (CodParte)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (UnitaResa)
    REFERENCES UnitaRese (UID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS UnitaEndOfLife ;

CREATE TABLE IF NOT EXISTS UnitaEndOfLife (
  UID VARCHAR(15) NOT NULL,
  GradoUsura INT NOT NULL,
  LottoSmaltimento INT NOT NULL,
  Prodotto VARCHAR(10) NOT NULL,
  Variante VARCHAR(15) NOT NULL,
  PRIMARY KEY (UID),
    FOREIGN KEY (Prodotto , Variante)
    REFERENCES Varianza (Prodotto , Variante)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS UnitaRicondizionate ;

CREATE TABLE IF NOT EXISTS UnitaRicondizionate (
  UID VARCHAR(15) NOT NULL,
  Grado CHAR(2) NULL,
  Prodotto VARCHAR(10) NOT NULL,
  Variante VARCHAR(15) NOT NULL,
  Ricondizionamento TINYINT NOT NULL,
  PRIMARY KEY (UID),
    FOREIGN KEY (Prodotto, Variante)
    REFERENCES Varianza (Prodotto , Variante)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS RecuperoMateriale ;

CREATE TABLE IF NOT EXISTS RecuperoMateriale (
  UnitaEndOfLife VARCHAR(15) NOT NULL,
  StazioneSmaltimento VARCHAR(10) NOT NULL,
  Materiale VARCHAR(15) NOT NULL,
  Quantita FLOAT NOT NULL,
  PRIMARY KEY (UnitaEndOfLife, StazioneSmaltimento, Materiale),
    FOREIGN KEY (UnitaEndOfLife)
    REFERENCES UnitaEndOfLife (UID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (StazioneSmaltimento)
    REFERENCES StazioneSmaltimento (CodStazione)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (Materiale)
    REFERENCES Materiale (Nome)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS RecuperoParte ;

CREATE TABLE IF NOT EXISTS RecuperoParte (
  UnitaEndOfLife VARCHAR(15) NOT NULL,
  Parte INT NOT NULL,
  StazioneSmaltimento VARCHAR(10) NOT NULL,
  Quantita TINYINT NOT NULL,
  PRIMARY KEY (UnitaEndOfLife, Parte, StazioneSmaltimento),
    FOREIGN KEY (UnitaEndOfLife)
    REFERENCES UnitaEndOfLife (UID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (Parte)
    REFERENCES Parte (CodParte)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (StazioneSmaltimento)
    REFERENCES StazioneSmaltimento (CodStazione)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS UnitaPerseProduzione ;

CREATE TABLE IF NOT EXISTS UnitaPerseProduzione (
  Lotto INT NOT NULL,
  UltimaOperazione INT NOT NULL,
  Quante INT NOT NULL,
  StazioneProduzione VARCHAR(10) NOT NULL,
  PRIMARY KEY (Lotto, UltimaOperazione),
    FOREIGN KEY (StazioneProduzione)
    REFERENCES StazioneProduzione (CodStazione)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (UltimaOperazione)
    REFERENCES Operazione (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (Lotto)
    REFERENCES LottoProduzione (CodLotto)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS Operatore ;

CREATE TABLE IF NOT EXISTS Operatore (
  CodiceFiscale VARCHAR(16) NOT NULL,
  Stipendio INT NOT NULL,
  StazioneProduzione VARCHAR(10) NULL,
  StazioneSmaltimento VARCHAR(10) NULL,
  PRIMARY KEY (CodiceFiscale),
    FOREIGN KEY (CodiceFiscale)
    REFERENCES DatiAnagraficiOperatore (CodFiscale)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (StazioneProduzione)
    REFERENCES StazioneProduzione (CodStazione)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (StazioneSmaltimento)
    REFERENCES StazioneSmaltimento (CodStazione)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS Valutazione ;

CREATE TABLE IF NOT EXISTS Valutazione (
  ClasseCampione VARCHAR(45) NOT NULL,
  Dipendente CHAR(16) NOT NULL,
  TempoImpiegato FLOAT NOT NULL,
  PRIMARY KEY (ClasseCampione, Dipendente),
    FOREIGN KEY (ClasseCampione)
    REFERENCES ClasseCampione (CodSet)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (Dipendente)
    REFERENCES Operatore (CodiceFiscale)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS DatiAnagraficiTecnico ;

CREATE TABLE IF NOT EXISTS DatiAnagraficiTecnico (
  Nome VARCHAR(30) NOT NULL,
  Cognome VARCHAR(30) NOT NULL,
  Citta VARCHAR(30) NOT NULL,
  CodiceFiscale VARCHAR(16) NOT NULL,
  DataNascita DATE NOT NULL,
  PRIMARY KEY (CodiceFiscale))
ENGINE = InnoDB;



DROP TABLE IF EXISTS DatiSequenza ;

CREATE TABLE IF NOT EXISTS DatiSequenza (
  Operazione INT NOT NULL,
  Prodotto VARCHAR(10) NOT NULL,
  Variante VARCHAR(15) NOT NULL,
  Sequenza INT NOT NULL,
  NumOperazione INT NULL,
  PRIMARY KEY (Operazione, Prodotto, Variante, Sequenza),
    FOREIGN KEY (Prodotto , Variante , Sequenza)
    REFERENCES Sequenza (Prodotto , Variante , Codice)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (Operazione)
    REFERENCES Operazione (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS UnitaPerseSmaltimento ;

CREATE TABLE IF NOT EXISTS UnitaPerseSmaltimento (
  Lotto INT NOT NULL,
  UltimaOperazione INT NOT NULL,
  Quante INT NOT NULL,
  StazioneSmaltimento VARCHAR(10) NOT NULL,
  PRIMARY KEY (Lotto, UltimaOperazione),
    FOREIGN KEY (Lotto)
    REFERENCES LottoSmaltimento (CodLotto)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (UltimaOperazione)
    REFERENCES Operazione (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    FOREIGN KEY (StazioneSmaltimento)
    REFERENCES StazioneSmaltimento (CodStazione)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



DROP TABLE IF EXISTS InfoVarianza ;

CREATE TABLE IF NOT EXISTS InfoVarianza (
  CodProdotto VARCHAR(10) NOT NULL,
  CodVariante VARCHAR(15) NOT NULL,
  NumMinimoUnitaLotto INT NOT NULL,
  NumMinimoUnitaRicond INT NOT NULL,
  NumMinimoUnitaSmaltimento INT NOT NULL,
  PercentualeRicondizionamento INT NOT NULL,
  Peso FLOAT NOT NULL,
  Ingombro FLOAT NOT NULL,
  PRIMARY KEY (CodProdotto, CodVariante),
    FOREIGN KEY (CodProdotto , CodVariante)
    REFERENCES Varianza (Prodotto , Variante)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



USE `Progetto`;


-- -----------------------------------------------------
-- TRIGGERS
-- -----------------------------------------------------
DELIMITER $$

DROP TRIGGER IF EXISTS LottoProduzione_AFTER_INSERT $$
CREATE TRIGGER LottoProduzione_AFTER_INSERT 
AFTER INSERT ON LottoProduzione 
FOR EACH ROW
BEGIN
	SET @spazioOccupato =
    (
		SELECT LP.UnitaPreviste * IV.Ingombro
        FROM InfoVarianza IV INNER JOIN Linea L ON L.Prodotto = IV.CodProdotto AND L.Variante = IV.CodVariante
				INNER JOIN LottoProduzione LP ON LP.Linea = L.CodLinea
		WHERE LP.CodLotto = NEW.CodLotto
    );
    IF(NEW.UnitaPreviste = NEW.UnitaEffettive) THEN
	UPDATE AreaMagazzino AA
    SET CapienzaDisponibile = CapienzaDisponibile - @spazioOccupato
    WHERE AA.Area = NEW.Area AND AA.Magazzino = NEW.Magazzino;
    END IF;
END$$



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
END$$



DROP TRIGGER IF EXISTS LottoProduzione_AFTER_UPDATE $$
CREATE TRIGGER LottoProduzione_AFTER_UPDATE 
AFTER UPDATE ON LottoProduzione 
FOR EACH ROW
BEGIN
	SET @spazioOccupato =
    (
		SELECT LP.UnitaPreviste * IV.Ingombro
        FROM InfoVarianza IV INNER JOIN Linea L ON L.Prodotto = IV.CodProdotto AND L.Variante = IV.CodVariante
				INNER JOIN LottoProduzione LP ON LP.Linea = L.CodLinea
		WHERE LP.CodLotto = NEW.CodLotto
    );
    IF(NEW.UnitaPreviste = NEW.UnitaEffettive AND OLD.UnitaPreviste <> OLD.UnitaEffettive) THEN
	UPDATE AreaMagazzino
    SET CapienzaDisponibile = CapienzaDisponibile - @spazioOccupato
    WHERE Area = NEW.Area AND Magazzino = NEW.Magazzino;
    END IF;
END$$



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
          
	IF flag < NEW.Quantita THEN 
	SET NEW.Stato = 0;
	UPDATE ordinevendita
	SET Stato = 'Pendente'
	WHERE CodOrdine = NEW.OrdineVendita; 
    
    ELSE IF(flag = NEW.Quantita) THEN
    SET NEW.Stato = 1;
    UPDATE ordinevendita
    SET Stato = 'InProcessazione'
    WHERE CodOrdine = NEW.OrdineVendita;
    END IF;
END IF;
END $$



DROP TRIGGER IF EXISTS Carrello_AFTER_INSERT $$ 
CREATE TRIGGER Carrello_AFTER_INSERT 
AFTER INSERT ON Carrello 
FOR EACH ROW
BEGIN
	DECLARE ordineRiferimento INTEGER DEFAULT 0;
    DECLARE daPagare  INTEGER DEFAULT 0;
    
   
	
    SET daPagare = (
    SELECT IF(NEW.Categoria <> 'A', (IV.Prezzo - IV.Prezzo * (5 * NEW.Categoria / 100)) * NEW.Quantita, IV.Prezzo * NEW.Quantita)
    FROM Varianza IV
    WHERE IV.Prodotto = NEW.Prodotto AND IV.Variante = NEW.Variante);
    
    UPDATE OrdineVendita OV
    SET OV.TotDaPagare = OV.TotDaPagare + daPagare
    WHERE OV.CodOrdine = NEW.OrdineVendita;
		
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




DROP TRIGGER IF EXISTS ordine_pendente_piuVecchio_soddisfattibile $$
CREATE TRIGGER ordine_pendente_piuVecchio_soddisfattibile
AFTER INSERT ON unitadisponibili
FOR EACH ROW
BEGIN
	DECLARE codiceOrdine INT;
    DECLARE accountUtente VARCHAR(30) DEFAULT NULL;
    DECLARE garanzia VARCHAR(45) DEFAULT NULL;
    DECLARE unitaNONdisponibili INT;
    DECLARE flag INTEGER DEFAULT 0;
    
    DECLARE cursore CURSOR FOR
    SELECT OV.CodOrdine, OV.Account as Utente, C.Garanzia
    FROM ordinevendita OV INNER JOIN carrello C ON OV.CodOrdine = C.OrdineVendita
    WHERE C.Prodotto = NEW.Prodotto AND C.Variante = NEW.Variante AND
          C.Stato = 0 and OV.DataOrdine = 
          (select MIN(OV1.DataOrdine)
           FROM ordinevendita OV1 INNER JOIN carrello C1 on OV1.CodOrdine = C1.OrdineVendita
           WHERE C1.Prodotto = NEW.Prodotto AND C1.Variante = NEW.Variante AND
                 C1.Stato = 0)    /* Carello.Stato = 0 -> Unità non disponibile*/
	LIMIT 1;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET flag = 1;
    
    OPEN cursore;
scanner : LOOP
	
	FETCH cursore INTO codiceOrdine, accountUtente, garanzia;
    IF(flag = 1) THEN
		LEAVE scanner;
	END IF;
	UPDATE carrello C SET C.Stato = 1 
	WHERE C.Prodotto = NEW.Prodotto AND
		  C.Variante = NEW.Variante AND
		  C.OrdineVendita = codiceOrdine AND
		  C.Garanzia = garanzia;
END LOOP;
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

DELIMITER ;


-- -----------------------------------------------------
-- EVENT
-- -----------------------------------------------------
DELIMITER $$

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



-- -----------------------------------------------------
-- ANALITYCS
-- -----------------------------------------------------
DELIMITER $$

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



DROP PROCEDURE IF EXISTS MV_partial_refresh $$
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



-- -----------------------------------------------------
-- INSERT
-- -----------------------------------------------------
START TRANSACTION;
USE `Progetto`;

INSERT INTO CategoriaProdotto (Categoria, Nome) VALUES ('A9', 'Smartphone');
INSERT INTO CategoriaProdotto (Categoria, Nome) VALUES ('B72', 'Sistemi Audio-Visivi');
INSERT INTO CategoriaProdotto (Categoria, Nome) VALUES ('C62', 'Elettrodomestici');


INSERT INTO Prodotto (CodProdotto, Nome, NumeroFacce, DataCommercio, Categoria) VALUES ('AIph2017', 'ePhone', 2, '2017-11-01', 'A9');
INSERT INTO Prodotto (CodProdotto, Nome, NumeroFacce, DataCommercio, Categoria) VALUES ('LavAs2018', 'LavaAsciuga', 6, '2018-02-01', 'C62');
INSERT INTO Prodotto (CodProdotto, Nome, NumeroFacce, DataCommercio, Categoria) VALUES ('TelQHD54', 'SmartTV', 2, '2019-05-01', 'B72');


INSERT INTO ClasseGuasto (Nome, Descrizione) VALUES ('U01', 'Danni dovuti all\'usura ');
INSERT INTO ClasseGuasto (Nome, Descrizione) VALUES ('U02', 'Danni dovuti all\'usura in un periodo prolungato');
INSERT INTO ClasseGuasto (Nome, Descrizione) VALUES ('U03', 'Danni dovuti all\'usura e al fine vita di una parte');
INSERT INTO ClasseGuasto (Nome, Descrizione) VALUES ('A01', 'Danni accidentali');
INSERT INTO ClasseGuasto (Nome, Descrizione) VALUES ('A02', 'Danni accidentali e/o al mal utilizzo');
INSERT INTO ClasseGuasto (Nome, Descrizione) VALUES ('A03', 'Danni dovuti al mal utilizzo');
INSERT INTO ClasseGuasto (Nome, Descrizione) VALUES ('B00', 'Danni casuali');


INSERT INTO Guasto (Codice, Nome, Classe) VALUES (10, 'Assenza risposte a input', 'B00');
INSERT INTO Guasto (Codice, Nome, Classe) VALUES (20, 'Schermo rotto', 'A02');
INSERT INTO Guasto (Codice, Nome, Classe) VALUES (30, 'Touch non risponde a input', 'B00');
INSERT INTO Guasto (Codice, Nome, Classe) VALUES (40, 'Non si accende', 'B00');
INSERT INTO Guasto (Codice, Nome, Classe) VALUES (50, 'Batteria usurata', 'U01');
INSERT INTO Guasto (Codice, Nome, Classe) VALUES (60, 'Fotocamera rotta', 'A02');
INSERT INTO Guasto (Codice, Nome, Classe) VALUES (70, 'Pannello LCD rotto', 'A03');
INSERT INTO Guasto (Codice, Nome, Classe) VALUES (80, 'Pixel neri', 'B00');
INSERT INTO Guasto (Codice, Nome, Classe) VALUES (90, 'Audio distorto', 'U02');
INSERT INTO Guasto (Codice, Nome, Classe) VALUES (100, 'Perdita acqua', 'U01');
INSERT INTO Guasto (Codice, Nome, Classe) VALUES (110, 'Non Attivazione centrifuga', 'U03');
INSERT INTO Guasto (Codice, Nome, Classe) VALUES (120, 'Bucato sporco', 'B00');
INSERT INTO Guasto (Codice, Nome, Classe) VALUES (130, 'Trabocco acqua vaschetta detersivi', 'B00');


INSERT INTO RelativoA (CodGuasto, CodProdotto) VALUES (10, 'AIph2017');
INSERT INTO RelativoA (CodGuasto, CodProdotto) VALUES (20, 'AIph2017');
INSERT INTO RelativoA (CodGuasto, CodProdotto) VALUES (30, 'AIph2017');
INSERT INTO RelativoA (CodGuasto, CodProdotto) VALUES (40, 'AIph2017');
INSERT INTO RelativoA (CodGuasto, CodProdotto) VALUES (50, 'AIph2017');
INSERT INTO RelativoA (CodGuasto, CodProdotto) VALUES (60, 'AIph2017');
INSERT INTO RelativoA (CodGuasto, CodProdotto) VALUES (10, 'LavAs2018');
INSERT INTO RelativoA (CodGuasto, CodProdotto) VALUES (40, 'LavAs2018');
INSERT INTO RelativoA (CodGuasto, CodProdotto) VALUES (130, 'LavAs2018');
INSERT INTO RelativoA (CodGuasto, CodProdotto) VALUES (100, 'LavAs2018');
INSERT INTO RelativoA (CodGuasto, CodProdotto) VALUES (110, 'LavAs2018');
INSERT INTO RelativoA (CodGuasto, CodProdotto) VALUES (120, 'LavAs2018');
INSERT INTO RelativoA (CodGuasto, CodProdotto) VALUES (70, 'TelQHD54');
INSERT INTO RelativoA (CodGuasto, CodProdotto) VALUES (80, 'TelQHD54');
INSERT INTO RelativoA (CodGuasto, CodProdotto) VALUES (90, 'TelQHD54');
INSERT INTO RelativoA (CodGuasto, CodProdotto) VALUES (10, 'TelQHD54');
INSERT INTO RelativoA (CodGuasto, CodProdotto) VALUES (40, 'TelQHD54');


INSERT INTO Utente (CodFiscale, Nome, Cognome, Citta, Provincia, Indirizzo, Telefono) VALUES ('aaa1', 'Federico', 'Casu', 'Mogoro', 'Oristano', 'A.Gramsci 72', '3883842556');
INSERT INTO Utente (CodFiscale, Nome, Cognome, Citta, Provincia, Indirizzo, Telefono) VALUES ('bbb2', 'Angelo', 'De Marco', 'Corigliano-Rossano', 'Cosenza', 'U.Eco 190', '3296054837');
INSERT INTO Utente (CodFiscale, Nome, Cognome, Citta, Provincia, Indirizzo, Telefono) VALUES ('ccc3', 'Luca', 'Arduini', 'Fondi', 'Latina', 'E.Salgari 24', '3891243640');


INSERT INTO Account (NomeUtente, Email, Password, DomandaSicurezza, Risposta, IndirizzoConsegna, Credito, Utente) VALUES ('f.casu1', 'f.casu1@gmail.com', 'caneRosso', 'Animale preferito', 'Cane', 'A.Gramsci 72', 2, 'aaa1');
INSERT INTO Account (NomeUtente, Email, Password, DomandaSicurezza, Risposta, IndirizzoConsegna, Credito, Utente) VALUES ('a.demarco0', 'a.demarco0@yahoo.com', 'gattoNero', 'Cibo preferito', 'Pizza', 'R.CuorDiLeone 18', 195, 'bbb2');
INSERT INTO Account (NomeUtente, Email, Password, DomandaSicurezza, Risposta, IndirizzoConsegna, Credito, Utente) VALUES ('l.arduini2', 'l.arduini2@gmail.com', 'ElefanteBlu', 'Città preferita', 'Napoli', 'E.Salgari 24', 589.20, 'ccc3'); 


INSERT INTO Giudizio (Valutazione, Commento, Prodotto, Account) VALUES (4, 'Buona qualità costruttiva, ottima fotocamera ma scarsa durata della batteria', 'AIph2017', 'f.casu1');
INSERT INTO Giudizio (Valutazione, Commento, Prodotto, Account) VALUES (1, 'Batteria diffetosa sin da pochi giorni dopo l\'acquisto', 'AIph2017', 'l.arduini2');


INSERT INTO Variante (CodVariante, Descrizione) VALUES ('AIph01', 'Modello base');
INSERT INTO Variante (CodVariante, Descrizione) VALUES ('AIph01Plus', 'Schermo 6.5\"');
INSERT INTO Variante (CodVariante, Descrizione) VALUES ('AIph02', 'Colore Gold');
INSERT INTO Variante (CodVariante, Descrizione) VALUES ('AIph03', 'Colore Black');
INSERT INTO Variante (CodVariante, Descrizione) VALUES ('LavAs01', 'Modello base');
INSERT INTO Variante (CodVariante, Descrizione) VALUES ('LavAs01Plus', 'Cestello 10 kg');
INSERT INTO Variante (CodVariante, Descrizione) VALUES ('LavAs02', 'Modello a pozzo');
INSERT INTO Variante (CodVariante, Descrizione) VALUES ('LavAs01Mini', 'Cestello 5 kg');
INSERT INTO Variante (CodVariante, Descrizione) VALUES ('TelQHD01', 'Modello base');
INSERT INTO Variante (CodVariante, Descrizione) VALUES ('TelQHD02', 'Attacco a muro');
INSERT INTO Variante (CodVariante, Descrizione) VALUES ('TelQHD03XL', 'Schermo 65\"');


INSERT INTO Varianza (Prodotto, Variante, Prezzo) VALUES ('AIph2017', 'AIph01', 789);
INSERT INTO Varianza (Prodotto, Variante, Prezzo) VALUES ('AIph2017', 'AIph01Plus', 859);
INSERT INTO Varianza (Prodotto, Variante, Prezzo) VALUES ('AIph2017', 'AIph02', 789);
INSERT INTO Varianza (Prodotto, Variante, Prezzo) VALUES ('AIph2017', 'AIph03', 789);
INSERT INTO Varianza (Prodotto, Variante, Prezzo) VALUES ('LavAs2018', 'LavAs01', 529);
INSERT INTO Varianza (Prodotto, Variante, Prezzo) VALUES ('LavAs2018', 'LavAs01Plus', 599);
INSERT INTO Varianza (Prodotto, Variante, Prezzo) VALUES ('LavAs2018', 'LavAs02', 539);
INSERT INTO Varianza (Prodotto, Variante, Prezzo) VALUES ('LavAs2018', 'LavAs01Mini', 499);
INSERT INTO Varianza (Prodotto, Variante, Prezzo) VALUES ('TelQHD54', 'TelQHD01', 1099);
INSERT INTO Varianza (Prodotto, Variante, Prezzo) VALUES ('TelQHD54', 'TelQHD02', 1089);
INSERT INTO Varianza (Prodotto, Variante, Prezzo) VALUES ('TelQHD54', 'TelQHD03XL', 1299);


INSERT INTO Parte (CodParte, Nome, Prezzo, Peso) VALUES (101, 'Schermo Touch 5.9\"', 78.99, 0.055);
INSERT INTO Parte (CodParte, Nome, Prezzo, Peso) VALUES (102, 'Scocca Modello 5.9\"', 27.10, 0.031);
INSERT INTO Parte (CodParte, Nome, Prezzo, Peso) VALUES (103, 'Scocca Modello 6.5\"', 30.99, 0.038);
INSERT INTO Parte (CodParte, Nome, Prezzo, Peso) VALUES (104, 'Schermo Touch 6.5\"', 97.59, 0.061);
INSERT INTO Parte (CodParte, Nome, Prezzo, Peso) VALUES (105, 'Scheda Madre AIph', 111.95, 0.023);
INSERT INTO Parte (CodParte, Nome, Prezzo, Peso) VALUES (106, 'Fotocamera AIph', 45.29, 0.006);
INSERT INTO Parte (CodParte, Nome, Prezzo, Peso) VALUES (107, 'Batteria AIph 3500', 54.29, 0.064);
INSERT INTO Parte (CodParte, Nome, Prezzo, Peso) VALUES (108, 'Batteria AIph 4000', 65.05, 0.070);
INSERT INTO Parte (CodParte, Nome, Prezzo, Peso) VALUES (109, 'Back Cover White', 12.79, 0.009);
INSERT INTO Parte (CodParte, Nome, Prezzo, Peso) VALUES (110, 'Back Cover Black', 12.79, 0.009);
INSERT INTO Parte (CodParte, Nome, Prezzo, Peso) VALUES (111, 'Back Cover Gold', 12.79, 0.009);
INSERT INTO Parte (CodParte, Nome, Prezzo, Peso) VALUES (112, 'Ricarica USB-C', 9.95, 0.004);
INSERT INTO Parte (CodParte, Nome, Prezzo, Peso) VALUES (201, 'Struttura Modello base', 112.45, 15.046);
INSERT INTO Parte (CodParte, Nome, Prezzo, Peso) VALUES (202, 'Struttura Modello 10kg', 115.99, 17.034);
INSERT INTO Parte (CodParte, Nome, Prezzo, Peso) VALUES (203, 'Struttura Modello 5kg', 109.99, 12.642);
INSERT INTO Parte (CodParte, Nome, Prezzo, Peso) VALUES (204, 'Cestello base', 24, 5.233);
INSERT INTO Parte (CodParte, Nome, Prezzo, Peso) VALUES (205, 'Cestello 10kg', 27, 6.432);
INSERT INTO Parte (CodParte, Nome, Prezzo, Peso) VALUES (206, 'Cestello 5kg', 22.50, 3.463);
INSERT INTO Parte (CodParte, Nome, Prezzo, Peso) VALUES (207, 'Motore', 157.99, 3.535);
INSERT INTO Parte (CodParte, Nome, Prezzo, Peso) VALUES (208, 'Cinghia', 6.89, 0.137);
INSERT INTO Parte (CodParte, Nome, Prezzo, Peso) VALUES (209, 'Oblò', 18.40, 2.353);
INSERT INTO Parte (CodParte, Nome, Prezzo, Peso) VALUES (210, 'Tubo acqua', 3.15, 0.180);
INSERT INTO Parte (CodParte, Nome, Prezzo, Peso) VALUES (211, 'Pannello laterale', 19.50, 4.754);
INSERT INTO Parte (CodParte, Nome, Prezzo, Peso) VALUES (212, 'Pannello Principale', 19.80, 5.321);
INSERT INTO Parte (CodParte, Nome, Prezzo, Peso) VALUES (213, 'Pulsante', 0.79, 0.005);
INSERT INTO Parte (CodParte, Nome, Prezzo, Peso) VALUES (214, 'Spina', 3.65, 0.035);
INSERT INTO Parte (CodParte, Nome, Prezzo, Peso) VALUES (301, 'Scocca Modello base', 54.60, 0.642);
INSERT INTO Parte (CodParte, Nome, Prezzo, Peso) VALUES (302, 'Scocca Modello 65\"', 59.90, 0.675);
INSERT INTO Parte (CodParte, Nome, Prezzo, Peso) VALUES (303, 'Scocca Modello a muro', 55.05, 0.745);
INSERT INTO Parte (CodParte, Nome, Prezzo, Peso) VALUES (304, 'Pannello LCD 54\"', 459.05, 1.031);
INSERT INTO Parte (CodParte, Nome, Prezzo, Peso) VALUES (305, 'Pannello LCD 65\"', 485.95, 1.632);
INSERT INTO Parte (CodParte, Nome, Prezzo, Peso) VALUES (306, 'Pulsante soft-touch', 1.25, 0.010);
INSERT INTO Parte (CodParte, Nome, Prezzo, Peso) VALUES (307, 'Back Cover Modello base', 12.70, 0.532);
INSERT INTO Parte (CodParte, Nome, Prezzo, Peso) VALUES (308, 'Back Cover Modello 65\"', 13.65, 0.754);
INSERT INTO Parte (CodParte, Nome, Prezzo, Peso) VALUES (309, 'Scheda Madre TelQHD', 98.15, 0.122);
INSERT INTO Parte (CodParte, Nome, Prezzo, Peso) VALUES (310, 'Ricevitore Infrarossi', 3.70, 0.002);
INSERT INTO Parte (CodParte, Nome, Prezzo, Peso) VALUES (311, 'Hub INPUT esterni', 18.95, 0.063);
INSERT INTO Parte (CodParte, Nome, Prezzo, Peso) VALUES (123, 'Nessuna', 0, 0);


INSERT INTO Materiale (Nome, Valore, CoeffSvalutazione) VALUES ('Rame', 4, 0.75);
INSERT INTO Materiale (Nome, Valore, CoeffSvalutazione) VALUES ('Argento', 753.65, 0.80);
INSERT INTO Materiale (Nome, Valore, CoeffSvalutazione) VALUES ('Ferro', 0.25, 0.65);
INSERT INTO Materiale (Nome, Valore, CoeffSvalutazione) VALUES ('Acciaio INOX', 1.65, 0.70);
INSERT INTO Materiale (Nome, Valore, CoeffSvalutazione) VALUES ('ABS', 0.10, 0.45);
INSERT INTO Materiale (Nome, Valore, CoeffSvalutazione) VALUES ('Plastica', 0.05, 0.45);
INSERT INTO Materiale (Nome, Valore, CoeffSvalutazione) VALUES ('Vetro', 0.44, 0.25);
INSERT INTO Materiale (Nome, Valore, CoeffSvalutazione) VALUES ('Plexiglass', 0.30, 0.35);
INSERT INTO Materiale (Nome, Valore, CoeffSvalutazione) VALUES ('Litio', 59.98, 0.65);
INSERT INTO Materiale (Nome, Valore, CoeffSvalutazione) VALUES ('Alluminio', 45.25, 0.75);


INSERT INTO InfoVarianza (CodProdotto, CodVariante, NumMinimoUnitaLotto, NumMinimoUnitaRicond, NumMinimoUnitaSmaltimento, PercentualeRicondizionamento, Peso, Ingombro) VALUES ('AIph2017', 'AIph01Plus', 10, 2, 5, 35, 0.150, 0.0025);
INSERT INTO InfoVarianza (CodProdotto, CodVariante, NumMinimoUnitaLotto, NumMinimoUnitaRicond, NumMinimoUnitaSmaltimento, PercentualeRicondizionamento, Peso, Ingombro) VALUES ('AIph2017', 'AIph01', 12, 2, 6, 40, 0.135, 0.0022);
INSERT INTO InfoVarianza (CodProdotto, CodVariante, NumMinimoUnitaLotto, NumMinimoUnitaRicond, NumMinimoUnitaSmaltimento, PercentualeRicondizionamento, Peso, Ingombro) VALUES ('AIph2017', 'AIph02', 8, 2, 7, 33, 0.135, 0.0022);
INSERT INTO InfoVarianza (CodProdotto, CodVariante, NumMinimoUnitaLotto, NumMinimoUnitaRicond, NumMinimoUnitaSmaltimento, PercentualeRicondizionamento, Peso, Ingombro) VALUES ('AIph2017', 'AIph03', 14, 2, 8, 40, 0.135, 0.0022);


INSERT INTO Rimedio (CodRimedio, Descrizione) VALUES (721, 'Collegare la spina alla presa');
INSERT INTO Rimedio (CodRimedio, Descrizione) VALUES (722, 'Ricaricare la batteria');
INSERT INTO Rimedio (CodRimedio, Descrizione) VALUES (723, 'Pulire filtro dell\'acqua');
INSERT INTO Rimedio (CodRimedio, Descrizione) VALUES (724, 'Riavvio del dispositivo');
INSERT INTO Rimedio (CodRimedio, Descrizione) VALUES (725, 'Pulire filtro detersivi');
INSERT INTO Rimedio (CodRimedio, Descrizione) VALUES (20800, 'Sostituzione pannello LCD');
INSERT INTO Rimedio (CodRimedio, Descrizione) VALUES (20801, 'Sostituzione Schermo');
INSERT INTO Rimedio (CodRimedio, Descrizione) VALUES (20802, 'Riprogrammazione chip LCD');
INSERT INTO Rimedio (CodRimedio, Descrizione) VALUES (20803, 'Sostituzione flat-cable LCD');
INSERT INTO Rimedio (CodRimedio, Descrizione) VALUES (20804, 'Sostituzione scheda madre');


INSERT INTO CentroAssistenza (CodCentro, Indirizzo, Citta, Provincia) VALUES ('345', 'Via dell\'Artigiano, 43', 'Milano', 'MI');
INSERT INTO CentroAssistenza (CodCentro, Indirizzo, Citta, Provincia) VALUES ('346', 'Via Aureliana, 91', 'Roma', 'RO');
INSERT INTO CentroAssistenza (CodCentro, Indirizzo, Citta, Provincia) VALUES ('347', 'Via Avv. Agnelli, 10', 'Torino', 'TO');
INSERT INTO CentroAssistenza (CodCentro, Indirizzo, Citta, Provincia) VALUES ('348', 'Via San Simone, 345', 'Milano', 'MI');
INSERT INTO CentroAssistenza (CodCentro, Indirizzo, Citta, Provincia) VALUES ('349', 'Via Giannicolo, 76', 'Roma', 'RO');


INSERT INTO Tecnico (CodiceFiscale, Stipendio, CentroAssistenza, FasciaOraria, Occupato) VALUES ('hgh3', '1980', '345', '08-16', 0);
INSERT INTO Tecnico (CodiceFiscale, Stipendio, CentroAssistenza, FasciaOraria, Occupato) VALUES ('nrn5', '1805', '346', '16-24', 0);
INSERT INTO Tecnico (CodiceFiscale, Stipendio, CentroAssistenza, FasciaOraria, Occupato) VALUES ('eve2', '1889', '347', '08-16', 0);
INSERT INTO Tecnico (CodiceFiscale, Stipendio, CentroAssistenza, FasciaOraria, Occupato) VALUES ('klk9', '1799', '348', '16-24', 0);
INSERT INTO Tecnico (CodiceFiscale, Stipendio, CentroAssistenza, FasciaOraria, Occupato) VALUES ('brb4', '1893', '349', '08-16', 0);
INSERT INTO Tecnico (CodiceFiscale, Stipendio, CentroAssistenza, FasciaOraria, Occupato) VALUES ('xcz1', '1902', '345', '16-24', 1);
INSERT INTO Tecnico (CodiceFiscale, Stipendio, CentroAssistenza, FasciaOraria, Occupato) VALUES ('lok8', '1982', '346', '08-16', 1);
INSERT INTO Tecnico (CodiceFiscale, Stipendio, CentroAssistenza, FasciaOraria, Occupato) VALUES ('bje5', '1802', '347', '16-24', 1);
INSERT INTO Tecnico (CodiceFiscale, Stipendio, CentroAssistenza, FasciaOraria, Occupato) VALUES ('xsw2', '1785', '348', '08-16', 1);
INSERT INTO Tecnico (CodiceFiscale, Stipendio, CentroAssistenza, FasciaOraria, Occupato) VALUES ('ofe7', '1855', '349', '16-24', 1);

INSERT INTO Preventivo (Codice, DataRilascio, Tecnico) VALUES (6001, '2019-06-29', 'nrn5');
INSERT INTO Preventivo (Codice, DataRilascio, Tecnico) VALUES (6002, '2020-05-03', 'lok8');
INSERT INTO Preventivo (Codice, DataRilascio, Tecnico) VALUES (6003, '2020-11-09', 'bje5');

INSERT INTO Documento (Numero, Tipologia, Scadenza, Ente, Utente) VALUES ('123987', 'Carta d\'identità', '2028-02-24', 'Comune', 'aaa1');
INSERT INTO Documento (Numero, Tipologia, Scadenza, Ente, Utente) VALUES ('678294', 'Patente', '2027-09-01', 'Motorizzazione', 'bbb2');
INSERT INTO Documento (Numero, Tipologia, Scadenza, Ente, Utente) VALUES ('894638', 'Carta d\'identità', '2025-04-21', 'Comune', 'ccc3');


INSERT INTO ListaGuasti (Preventivo, Guasto, Prezzo) VALUES (6001, 50, 91.56);
INSERT INTO ListaGuasti (Preventivo, Guasto, Prezzo) VALUES (6002, 20, 131.25);


INSERT INTO Magazzino (CodMagazzino, Sede) VALUES (3001, 'Milano');
INSERT INTO Magazzino (CodMagazzino, Sede) VALUES (3002, 'Roma');


INSERT INTO AreaMagazzino (Area, Magazzino, Predisposizione, Capienza, CapienzaDisponibile) VALUES (1, 3001, 'A9', 100, 100);
INSERT INTO AreaMagazzino (Area, Magazzino, Predisposizione, Capienza, CapienzaDisponibile) VALUES (2, 3001, 'B72', 100, 100);
INSERT INTO AreaMagazzino (Area, Magazzino, Predisposizione, Capienza, CapienzaDisponibile) VALUES (3, 3001, 'C62', 200, 200);
INSERT INTO AreaMagazzino (Area, Magazzino, Predisposizione, Capienza, CapienzaDisponibile) VALUES (1, 3002, 'A9', 55, 55);
INSERT INTO AreaMagazzino (Area, Magazzino, Predisposizione, Capienza, CapienzaDisponibile) VALUES (2, 3002, 'B72', 150, 150);
INSERT INTO AreaMagazzino (Area, Magazzino, Predisposizione, Capienza, CapienzaDisponibile) VALUES (3, 3002, 'C62', 150, 150);


INSERT INTO Sequenza (Prodotto, Variante, Codice) VALUES ('AIph2017', 'AIph01Plus', 1);
INSERT INTO Sequenza (Prodotto, Variante, Codice) VALUES ('AIph2017', 'AIph01Plus', 12);


INSERT INTO Linea (CodLinea, Tempo, Tipo, Prodotto, Variante, Sequenza) VALUES ('201', 5, 'M', 'AIph2017', 'AIph01Plus', 1);
INSERT INTO Linea (CodLinea, Tempo, Tipo, Prodotto, Variante, Sequenza) VALUES ('201S', 4, 'S', 'AIph2017', 'AIph01Plus', 12);


INSERT INTO LottoProduzione (CodLotto, DataProduzione, DurataPreventivata, DurataEffettiva, UnitaPreviste, UnitaEffettive, Linea, Magazzino, Area, PrimaProduzione) VALUES (801, '2019-01-2', 5, 6.5, 10, 10, '201', 3001, 1, 8);
INSERT INTO LottoProduzione (CodLotto, DataProduzione, DurataPreventivata, DurataEffettiva, UnitaPreviste, UnitaEffettive, Linea, Magazzino, Area, PrimaProduzione) VALUES (799, '2018-12-01', 3, 4.5, 6, 6, '201', 3001, 1, 5);
INSERT INTO LottoProduzione (CodLotto, DataProduzione, DurataPreventivata, DurataEffettiva, UnitaPreviste, UnitaEffettive, Linea, Magazzino, Area, PrimaProduzione) VALUES (802, '2020-11-01', 6, 7, 10, 10, '201', 3001, 1, 6);
INSERT INTO LottoProduzione (CodLotto, DataProduzione, DurataPreventivata, DurataEffettiva, UnitaPreviste, UnitaEffettive, Linea, Magazzino, Area, PrimaProduzione) VALUES (803, '2020-11-02', 6, 7, 10, 10, '201', 3001, 1, 10);
INSERT INTO LottoProduzione (CodLotto, DataProduzione, DurataPreventivata, DurataEffettiva, UnitaPreviste, UnitaEffettive, Linea, Magazzino, Area, PrimaProduzione) VALUES (804, '2020-11-03', 6, 7, 10, 10, '201', 3001, 1, 4);


INSERT INTO `Progetto`.`OrdineVendita` (`CodOrdine`, `Stato`, `DataOrdine`, `TotDaPagare`, `Account`) VALUES (701, 'Evaso', '2019-11-21', 0, 'l.arduini2');
INSERT INTO `Progetto`.`OrdineVendita` (`CodOrdine`, `Stato`, `DataOrdine`, `TotDaPagare`, `Account`) VALUES (702, 'Evaso', '2019-12-13', 0, 'a.demarco0');
INSERT INTO `Progetto`.`OrdineVendita` (`CodOrdine`, `Stato`, `DataOrdine`, `TotDaPagare`, `Account`) VALUES (703, 'Evaso', '2020-02-24', 0, 'f.casu1');
INSERT INTO `Progetto`.`OrdineVendita` (`CodOrdine`, `Stato`, `DataOrdine`, `TotDaPagare`, `Account`) VALUES (700, 'Evaso', '2019-10-30', 0, 'f.casu1');
INSERT INTO `Progetto`.`OrdineVendita` (`CodOrdine`, `Stato`, `DataOrdine`, `TotDaPagare`, `Account`) VALUES (699, 'Evaso', '2019-08-20', 0, 'l.arduini2');
INSERT INTO `Progetto`.`OrdineVendita` (`CodOrdine`, `Stato`, `DataOrdine`, `TotDaPagare`, `Account`) VALUES (698, 'Evaso', '2019-08-03', 0, 'a.demarco0');
INSERT INTO `Progetto`.`OrdineVendita` (`CodOrdine`, `Stato`, `DataOrdine`, `TotDaPagare`, `Account`) VALUES (697, 'Evaso', '2019-01-10', 0, 'f.casu1');
INSERT INTO `Progetto`.`OrdineVendita` (`CodOrdine`, `Stato`, `DataOrdine`, `TotDaPagare`, `Account`) VALUES (696, 'Evaso', '2019-03-12', 0, 'a.demarco0');
INSERT INTO `Progetto`.`OrdineVendita` (`CodOrdine`, `Stato`, `DataOrdine`, `TotDaPagare`, `Account`) VALUES (704, DEFAULT, '2020-11-13', 0, 'a.demarco0');


INSERT INTO UnitaVendute (UID, OrdineVendita, Prodotto, Variante, LottoProduzione) VALUES ('901', 702, 'AIph2017', 'AIph01Plus', 801);
INSERT INTO UnitaVendute (UID, OrdineVendita, Prodotto, Variante, LottoProduzione) VALUES ('902', 701, 'AIph2017', 'AIph01Plus', 801);
INSERT INTO UnitaVendute (UID, OrdineVendita, Prodotto, Variante, LottoProduzione) VALUES ('903', 703, 'AIph2017', 'AIph01Plus', 801);
INSERT INTO UnitaVendute (UID, OrdineVendita, Prodotto, Variante, LottoProduzione) VALUES ('910', 698, 'AIph2017', 'AIph01Plus', 801);
INSERT INTO UnitaVendute (UID, OrdineVendita, Prodotto, Variante, LottoProduzione) VALUES ('911', 699, 'AIph2017', 'AIph01Plus', 801);
INSERT INTO UnitaVendute (UID, OrdineVendita, Prodotto, Variante, LottoProduzione) VALUES ('912', 700, 'AIph2017', 'AIph01Plus', 801);
INSERT INTO UnitaVendute (UID, OrdineVendita, Prodotto, Variante, LottoProduzione) VALUES ('907', 697, 'AIph2017', 'AIph01Plus', 801);
INSERT INTO UnitaVendute (UID, OrdineVendita, Prodotto, Variante, LottoProduzione) VALUES ('820', 696, 'AIph2017', 'AIph01', 799);


INSERT INTO Sintomo (CodSintomo, Descrizione) VALUES (651, 'Non risposta a input');
INSERT INTO Sintomo (CodSintomo, Descrizione) VALUES (652, 'Foto/Video neri');
INSERT INTO Sintomo (CodSintomo, Descrizione) VALUES (653, 'Numero di ricariche molto maggiori rispetto alla normale operatività');
INSERT INTO Sintomo (CodSintomo, Descrizione) VALUES (654, 'Filature visibili nel vetro ');
INSERT INTO Sintomo (CodSintomo, Descrizione) VALUES (655, 'Schermo nero, non risposta ad input');
INSERT INTO Sintomo (CodSintomo, Descrizione) VALUES (656, 'Flattering dello schermo');
INSERT INTO Sintomo (CodSintomo, Descrizione) VALUES (657, 'Riavvii inaspettati');


INSERT INTO AssistenzaVirtualeNOCodErrore (CodiceAssistenza, DataRichiesta, Riuscita, UnitaVendute, Sintomo) VALUES (451, '2020-02-23', 1, '901', 651);
INSERT INTO AssistenzaVirtualeNOCodErrore (CodiceAssistenza, DataRichiesta, Riuscita, UnitaVendute, Sintomo) VALUES (452, '2020-05-02', 0, '902', 653);
INSERT INTO AssistenzaVirtualeNOCodErrore (CodiceAssistenza, DataRichiesta, Riuscita, UnitaVendute, Sintomo) VALUES (453, '2019-06-28', 0, '903', 654);


INSERT INTO Domanda (CodDomanda, Testo) VALUES (91, 'Emette scintille quando si attacca la spina?');
INSERT INTO Domanda (CodDomanda, Testo) VALUES (92, 'La spina è attaccata?');
INSERT INTO Domanda (CodDomanda, Testo) VALUES (93, 'E\' presente la corrente?');
INSERT INTO Domanda (CodDomanda, Testo) VALUES (94, 'Vibra più del normale?');
INSERT INTO Domanda (CodDomanda, Testo) VALUES (95, 'La batteria tiene la carica?');
INSERT INTO Domanda (CodDomanda, Testo) VALUES (96, 'Lo schermo si vede chiaramente?');
INSERT INTO Domanda (CodDomanda, Testo) VALUES (97, 'Emette suoni anormali?');
INSERT INTO Domanda (CodDomanda, Testo) VALUES (98, 'Il motore gira?');
INSERT INTO Domanda (CodDomanda, Testo) VALUES (99, 'Risponde agli input?');
INSERT INTO Domanda (CodDomanda, Testo) VALUES (90, 'Si accende?');


INSERT INTO AutoDiagnosi (AssistenzaVirtualeNOErrore, Rimedio, Domanda, Risposta) VALUES (451, 724, 99, '1');
INSERT INTO AutoDiagnosi (AssistenzaVirtualeNOErrore, Rimedio, Domanda, Risposta) VALUES (452, 722, 95, '0');
INSERT INTO AutoDiagnosi (AssistenzaVirtualeNOErrore, Rimedio, Domanda, Risposta) VALUES (452, 724, 96, '0');
INSERT INTO AutoDiagnosi (AssistenzaVirtualeNOErrore, Rimedio, Domanda, Risposta) VALUES (452, 724, 94, '0');
INSERT INTO AutoDiagnosi (AssistenzaVirtualeNOErrore, Rimedio, Domanda, Risposta) VALUES (453, 724, 96, '0');
INSERT INTO AutoDiagnosi (AssistenzaVirtualeNOErrore, Rimedio, Domanda, Risposta) VALUES (453, 722, 96, '0');


INSERT INTO AssistenzaFisica (CodiceAssistenza, DataRichiesta, UnitaVendute, TecniciRichiesti) VALUES (4520, '2020-05-02', '902', 1);
INSERT INTO AssistenzaFisica (CodiceAssistenza, DataRichiesta, UnitaVendute, TecniciRichiesti) VALUES (4530, '2019-06-28', '903', 1);
INSERT INTO AssistenzaFisica (CodiceAssistenza, DataRichiesta, UnitaVendute, TecniciRichiesti) VALUES (4540, '2020-11-08', '903', 1);


INSERT INTO SintomiAccusati (Sintomo, AssistenzaFisica) VALUES (651, 4540);
INSERT INTO SintomiAccusati (Sintomo, AssistenzaFisica) VALUES (655, 4540);
INSERT INTO SintomiAccusati (Sintomo, AssistenzaFisica) VALUES (654, 4540);


INSERT INTO Conoscenza (AIM, DataRisoluzione, Guasto) VALUES ('5252', '2019-06-30', 70);
INSERT INTO Conoscenza (AIM, DataRisoluzione, Guasto) VALUES ('6565', '2020-05-06', 20);


INSERT INTO `Progetto`.`SintomiMemorizzati` (`Sintomo`, `Conoscenza`) VALUES (656, '5252');
INSERT INTO `Progetto`.`SintomiMemorizzati` (`Sintomo`, `Conoscenza`) VALUES (657, '5252');
INSERT INTO `Progetto`.`SintomiMemorizzati` (`Sintomo`, `Conoscenza`) VALUES (651, '5252');
INSERT INTO `Progetto`.`SintomiMemorizzati` (`Sintomo`, `Conoscenza`) VALUES (655, '5252');
INSERT INTO `Progetto`.`SintomiMemorizzati` (`Sintomo`, `Conoscenza`) VALUES (651, '6565');
INSERT INTO `Progetto`.`SintomiMemorizzati` (`Sintomo`, `Conoscenza`) VALUES (654, '6565');
INSERT INTO `Progetto`.`SintomiMemorizzati` (`Sintomo`, `Conoscenza`) VALUES (653, '6565');
INSERT INTO `Progetto`.`SintomiMemorizzati` (`Sintomo`, `Conoscenza`) VALUES (657, '6565');


INSERT INTO `Progetto`.`InterventoFisico` (`Ticket`, `Domicilio`, `Stato`, `OreLavoro`, `AssistenzaFisica`, `Preventivo`, `Data`, `QuantiAssegnati`) VALUES (10025, 1, 'Da svolgere', 1, 4520, 6002, '2020-05-06', 1);
INSERT INTO `Progetto`.`InterventoFisico` (`Ticket`, `Domicilio`, `Stato`, `OreLavoro`, `AssistenzaFisica`, `Preventivo`, `Data`, `QuantiAssegnati`) VALUES (10026, 1, 'Finito', 1, 4530, 6001, '2019-06-30', 1);
INSERT INTO `Progetto`.`InterventoFisico` (`Ticket`, `Domicilio`, `Stato`, `OreLavoro`, `AssistenzaFisica`, `Preventivo`, `Data`, `QuantiAssegnati`) VALUES (10027, 1, DEFAULT, NULL, 4540, 6003, NULL, DEFAULT);


INSERT INTO `Progetto`.`Struttura` (`Parte`, `Materiale`, `Quantità`) VALUES (101, 'Vetro', 0.025);
INSERT INTO `Progetto`.`Struttura` (`Parte`, `Materiale`, `Quantità`) VALUES (101, 'Acciaio INOX', 0.005);
INSERT INTO `Progetto`.`Struttura` (`Parte`, `Materiale`, `Quantità`) VALUES (104, 'Vetro', 0.025);
INSERT INTO `Progetto`.`Struttura` (`Parte`, `Materiale`, `Quantità`) VALUES (104, 'Acciaio INOX', 0.005);
INSERT INTO `Progetto`.`Struttura` (`Parte`, `Materiale`, `Quantità`) VALUES (112, 'Rame', 0.005);
INSERT INTO `Progetto`.`Struttura` (`Parte`, `Materiale`, `Quantità`) VALUES (109, 'Vetro', 0.010);
INSERT INTO `Progetto`.`Struttura` (`Parte`, `Materiale`, `Quantità`) VALUES (110, 'Vetro', 0.010);
INSERT INTO `Progetto`.`Struttura` (`Parte`, `Materiale`, `Quantità`) VALUES (111, 'Vetro', 0.010);
INSERT INTO `Progetto`.`Struttura` (`Parte`, `Materiale`, `Quantità`) VALUES (102, 'Acciaio INOX', 0.030);
INSERT INTO `Progetto`.`Struttura` (`Parte`, `Materiale`, `Quantità`) VALUES (103, 'Acciaio INOX', 0.030);
INSERT INTO `Progetto`.`Struttura` (`Parte`, `Materiale`, `Quantità`) VALUES (105, 'Rame', 0.010);
INSERT INTO `Progetto`.`Struttura` (`Parte`, `Materiale`, `Quantità`) VALUES (105, 'Argento', 0.010);
INSERT INTO `Progetto`.`Struttura` (`Parte`, `Materiale`, `Quantità`) VALUES (107, 'Litio', 0.030);
INSERT INTO `Progetto`.`Struttura` (`Parte`, `Materiale`, `Quantità`) VALUES (106, 'Vetro', 0.010);
INSERT INTO `Progetto`.`Struttura` (`Parte`, `Materiale`, `Quantità`) VALUES (106, 'Acciaio INOX', 0.010);
INSERT INTO `Progetto`.`Struttura` (`Parte`, `Materiale`, `Quantità`) VALUES (108, 'Litio', 0.030);
INSERT INTO `Progetto`.`Struttura` (`Parte`, `Materiale`, `Quantità`) VALUES (201, 'Ferro', 30);
INSERT INTO `Progetto`.`Struttura` (`Parte`, `Materiale`, `Quantità`) VALUES (202, 'Ferro', 30);
INSERT INTO `Progetto`.`Struttura` (`Parte`, `Materiale`, `Quantità`) VALUES (203, 'Ferro', 30);
INSERT INTO `Progetto`.`Struttura` (`Parte`, `Materiale`, `Quantità`) VALUES (204, 'Acciaio INOX', 15);
INSERT INTO `Progetto`.`Struttura` (`Parte`, `Materiale`, `Quantità`) VALUES (205, 'Acciaio INOX', 15);
INSERT INTO `Progetto`.`Struttura` (`Parte`, `Materiale`, `Quantità`) VALUES (206, 'Acciaio INOX', 15);
INSERT INTO `Progetto`.`Struttura` (`Parte`, `Materiale`, `Quantità`) VALUES (207, 'Rame', 4.5);
INSERT INTO `Progetto`.`Struttura` (`Parte`, `Materiale`, `Quantità`) VALUES (207, 'Acciaio INOX', 0.5);
INSERT INTO `Progetto`.`Struttura` (`Parte`, `Materiale`, `Quantità`) VALUES (208, 'ABS', 0.5);
INSERT INTO `Progetto`.`Struttura` (`Parte`, `Materiale`, `Quantità`) VALUES (209, 'Vetro', 1);
INSERT INTO `Progetto`.`Struttura` (`Parte`, `Materiale`, `Quantità`) VALUES (210, 'Plastica', 0.225);
INSERT INTO `Progetto`.`Struttura` (`Parte`, `Materiale`, `Quantità`) VALUES (211, 'Alluminio', 0.995);
INSERT INTO `Progetto`.`Struttura` (`Parte`, `Materiale`, `Quantità`) VALUES (212, 'Alluminio', 0.995);
INSERT INTO `Progetto`.`Struttura` (`Parte`, `Materiale`, `Quantità`) VALUES (213, 'Plastica', 0.010);
INSERT INTO `Progetto`.`Struttura` (`Parte`, `Materiale`, `Quantità`) VALUES (214, 'ABS', 0.100);
INSERT INTO `Progetto`.`Struttura` (`Parte`, `Materiale`, `Quantità`) VALUES (214, 'Rame', 0.900);
INSERT INTO `Progetto`.`Struttura` (`Parte`, `Materiale`, `Quantità`) VALUES (301, 'Acciaio INOX', 4.50);
INSERT INTO `Progetto`.`Struttura` (`Parte`, `Materiale`, `Quantità`) VALUES (302, 'Acciaio INOX', 4.50);
INSERT INTO `Progetto`.`Struttura` (`Parte`, `Materiale`, `Quantità`) VALUES (303, 'Acciaio INOX', 4.50);
INSERT INTO `Progetto`.`Struttura` (`Parte`, `Materiale`, `Quantità`) VALUES (304, 'Vetro', 3.75);
INSERT INTO `Progetto`.`Struttura` (`Parte`, `Materiale`, `Quantità`) VALUES (305, 'Vetro', 3.75);
INSERT INTO `Progetto`.`Struttura` (`Parte`, `Materiale`, `Quantità`) VALUES (311, 'Plastica', 0.050);
INSERT INTO `Progetto`.`Struttura` (`Parte`, `Materiale`, `Quantità`) VALUES (307, 'Plastica', 1.50);
INSERT INTO `Progetto`.`Struttura` (`Parte`, `Materiale`, `Quantità`) VALUES (306, 'Plastica', 1.50);


INSERT INTO `Progetto`.`Composizione` (`Prodotto`, `Parte`, `Pezzi`) VALUES ('AIph2017', 101, 1);
INSERT INTO `Progetto`.`Composizione` (`Prodotto`, `Parte`, `Pezzi`) VALUES ('AIph2017', 102, 1);
INSERT INTO `Progetto`.`Composizione` (`Prodotto`, `Parte`, `Pezzi`) VALUES ('AIph2017', 103, 1);
INSERT INTO `Progetto`.`Composizione` (`Prodotto`, `Parte`, `Pezzi`) VALUES ('AIph2017', 104, 1);
INSERT INTO `Progetto`.`Composizione` (`Prodotto`, `Parte`, `Pezzi`) VALUES ('AIph2017', 105, 1);
INSERT INTO `Progetto`.`Composizione` (`Prodotto`, `Parte`, `Pezzi`) VALUES ('AIph2017', 106, 1);
INSERT INTO `Progetto`.`Composizione` (`Prodotto`, `Parte`, `Pezzi`) VALUES ('AIph2017', 107, 1);
INSERT INTO `Progetto`.`Composizione` (`Prodotto`, `Parte`, `Pezzi`) VALUES ('AIph2017', 108, 1);
INSERT INTO `Progetto`.`Composizione` (`Prodotto`, `Parte`, `Pezzi`) VALUES ('AIph2017', 109, 1);
INSERT INTO `Progetto`.`Composizione` (`Prodotto`, `Parte`, `Pezzi`) VALUES ('AIph2017', 110, 1);
INSERT INTO `Progetto`.`Composizione` (`Prodotto`, `Parte`, `Pezzi`) VALUES ('AIph2017', 111, 1);
INSERT INTO `Progetto`.`Composizione` (`Prodotto`, `Parte`, `Pezzi`) VALUES ('AIph2017', 112, 1);
INSERT INTO `Progetto`.`Composizione` (`Prodotto`, `Parte`, `Pezzi`) VALUES ('LavAs2018', 201, 1);
INSERT INTO `Progetto`.`Composizione` (`Prodotto`, `Parte`, `Pezzi`) VALUES ('LavAs2018', 202, 1);
INSERT INTO `Progetto`.`Composizione` (`Prodotto`, `Parte`, `Pezzi`) VALUES ('LavAs2018', 203, 1);
INSERT INTO `Progetto`.`Composizione` (`Prodotto`, `Parte`, `Pezzi`) VALUES ('LavAs2018', 204, 1);
INSERT INTO `Progetto`.`Composizione` (`Prodotto`, `Parte`, `Pezzi`) VALUES ('LavAs2018', 205, 1);
INSERT INTO `Progetto`.`Composizione` (`Prodotto`, `Parte`, `Pezzi`) VALUES ('LavAs2018', 206, 1);
INSERT INTO `Progetto`.`Composizione` (`Prodotto`, `Parte`, `Pezzi`) VALUES ('LavAs2018', 207, 1);
INSERT INTO `Progetto`.`Composizione` (`Prodotto`, `Parte`, `Pezzi`) VALUES ('LavAs2018', 208, 1);
INSERT INTO `Progetto`.`Composizione` (`Prodotto`, `Parte`, `Pezzi`) VALUES ('LavAs2018', 209, 1);
INSERT INTO `Progetto`.`Composizione` (`Prodotto`, `Parte`, `Pezzi`) VALUES ('LavAs2018', 210, 12);
INSERT INTO `Progetto`.`Composizione` (`Prodotto`, `Parte`, `Pezzi`) VALUES ('LavAs2018', 211, 3);
INSERT INTO `Progetto`.`Composizione` (`Prodotto`, `Parte`, `Pezzi`) VALUES ('LavAs2018', 212, 1);
INSERT INTO `Progetto`.`Composizione` (`Prodotto`, `Parte`, `Pezzi`) VALUES ('LavAs2018', 213, 10);
INSERT INTO `Progetto`.`Composizione` (`Prodotto`, `Parte`, `Pezzi`) VALUES ('LavAs2018', 214, 1);
INSERT INTO `Progetto`.`Composizione` (`Prodotto`, `Parte`, `Pezzi`) VALUES ('TelQHD54', 301, 1);
INSERT INTO `Progetto`.`Composizione` (`Prodotto`, `Parte`, `Pezzi`) VALUES ('TelQHD54', 302, 1);
INSERT INTO `Progetto`.`Composizione` (`Prodotto`, `Parte`, `Pezzi`) VALUES ('TelQHD54', 303, 1);
INSERT INTO `Progetto`.`Composizione` (`Prodotto`, `Parte`, `Pezzi`) VALUES ('TelQHD54', 304, 1);
INSERT INTO `Progetto`.`Composizione` (`Prodotto`, `Parte`, `Pezzi`) VALUES ('TelQHD54', 305, 1);
INSERT INTO `Progetto`.`Composizione` (`Prodotto`, `Parte`, `Pezzi`) VALUES ('TelQHD54', 306, 12);
INSERT INTO `Progetto`.`Composizione` (`Prodotto`, `Parte`, `Pezzi`) VALUES ('TelQHD54', 307, 1);
INSERT INTO `Progetto`.`Composizione` (`Prodotto`, `Parte`, `Pezzi`) VALUES ('TelQHD54', 308, 1);
INSERT INTO `Progetto`.`Composizione` (`Prodotto`, `Parte`, `Pezzi`) VALUES ('TelQHD54', 309, 1);
INSERT INTO `Progetto`.`Composizione` (`Prodotto`, `Parte`, `Pezzi`) VALUES ('TelQHD54', 310, 1);
INSERT INTO `Progetto`.`Composizione` (`Prodotto`, `Parte`, `Pezzi`) VALUES ('TelQHD54', 311, 1);


INSERT INTO `Progetto`.`Giunzione` (`CodGiunzione`, `Tipo`) VALUES ('150', 'Vite + 0.2 mm');
INSERT INTO `Progetto`.`Giunzione` (`CodGiunzione`, `Tipo`) VALUES ('151', 'Vite Torx 0.2 mm');
INSERT INTO `Progetto`.`Giunzione` (`CodGiunzione`, `Tipo`) VALUES ('152', 'Vite - 0.2 mm');
INSERT INTO `Progetto`.`Giunzione` (`CodGiunzione`, `Tipo`) VALUES ('153', 'Vite + 120 mm');
INSERT INTO `Progetto`.`Giunzione` (`CodGiunzione`, `Tipo`) VALUES ('154', 'Vite -  120 mm');
INSERT INTO `Progetto`.`Giunzione` (`CodGiunzione`, `Tipo`) VALUES ('155', 'Dado/Bullone 12mm');
INSERT INTO `Progetto`.`Giunzione` (`CodGiunzione`, `Tipo`) VALUES ('156', 'Dado/Bullone 10 mm');
INSERT INTO `Progetto`.`Giunzione` (`CodGiunzione`, `Tipo`) VALUES ('157', 'Rivetto ');
INSERT INTO `Progetto`.`Giunzione` (`CodGiunzione`, `Tipo`) VALUES ('158', 'Colla bicomponente');
INSERT INTO `Progetto`.`Giunzione` (`CodGiunzione`, `Tipo`) VALUES ('159', 'Fascetta (idraulica)');
INSERT INTO `Progetto`.`Giunzione` (`CodGiunzione`, `Tipo`) VALUES ('160', 'Fascetta (elettronica)');


INSERT INTO `Progetto`.`ClasseCampione` (`CodSet`, `Descrizione`) VALUES ('891', 'Saldatura di precisione (elettronica)');
INSERT INTO `Progetto`.`ClasseCampione` (`CodSet`, `Descrizione`) VALUES ('892', 'Saldatura ');
INSERT INTO `Progetto`.`ClasseCampione` (`CodSet`, `Descrizione`) VALUES ('893', 'Foratura');
INSERT INTO `Progetto`.`ClasseCampione` (`CodSet`, `Descrizione`) VALUES ('894', 'Crimpaggio fili elettrici');
INSERT INTO `Progetto`.`ClasseCampione` (`CodSet`, `Descrizione`) VALUES ('895', 'Serraggio di precisione');
INSERT INTO `Progetto`.`ClasseCampione` (`CodSet`, `Descrizione`) VALUES ('896', 'Rivettatura');
INSERT INTO `Progetto`.`ClasseCampione` (`CodSet`, `Descrizione`) VALUES ('897', 'Avvitare ');
INSERT INTO `Progetto`.`ClasseCampione` (`CodSet`, `Descrizione`) VALUES ('898', 'Svitare ');
INSERT INTO `Progetto`.`ClasseCampione` (`CodSet`, `Descrizione`) VALUES ('899', 'Incastro di due/più parti');
INSERT INTO `Progetto`.`ClasseCampione` (`CodSet`, `Descrizione`) VALUES ('890', 'Dissaldatura');
INSERT INTO `Progetto`.`ClasseCampione` (`CodSet`, `Descrizione`) VALUES ('879', 'Disincastro di due/più parti');


INSERT INTO `Progetto`.`Operazione` (`ID`, `Descrizione`, `Faccia`, `Tipo`, `ClasseCampione`, `Giunzione`, `Prodotto`, `Variante`, `Livello`) VALUES (1, 'Assemblaggio scocca, scheda madre', 1, 'M', '897', '151', 'AIph2017', 'AIph01Plus', 1);
INSERT INTO `Progetto`.`Operazione` (`ID`, `Descrizione`, `Faccia`, `Tipo`, `ClasseCampione`, `Giunzione`, `Prodotto`, `Variante`, `Livello`) VALUES (2, 'Assemblaggio scocca, back cover', 2, 'M', '899', NULL, 'AIph2017', 'AIph01Plus', 1);
INSERT INTO `Progetto`.`Operazione` (`ID`, `Descrizione`, `Faccia`, `Tipo`, `ClasseCampione`, `Giunzione`, `Prodotto`, `Variante`, `Livello`) VALUES (3, 'Assemblaggio scheda madre, fotocamera', 1, 'M', '891', NULL, 'AIph2017', 'AIph01Plus', 2);
INSERT INTO `Progetto`.`Operazione` (`ID`, `Descrizione`, `Faccia`, `Tipo`, `ClasseCampione`, `Giunzione`, `Prodotto`, `Variante`, `Livello`) VALUES (4, 'Assemblaggio scheda madre, batteria', 1, 'M', '897', '150', 'AIph2017', 'AIph01Plus', 2);
INSERT INTO `Progetto`.`Operazione` (`ID`, `Descrizione`, `Faccia`, `Tipo`, `ClasseCampione`, `Giunzione`, `Prodotto`, `Variante`, `Livello`) VALUES (5, 'Assemblaggio scheda madre, slot ricarica', 1, 'M', '897', '152', 'AIph2017', 'AIph01Plus', 3);
INSERT INTO `Progetto`.`Operazione` (`ID`, `Descrizione`, `Faccia`, `Tipo`, `ClasseCampione`, `Giunzione`, `Prodotto`, `Variante`, `Livello`) VALUES (6, 'Assemblaggio scheda madre, schermo touch-screen', 1, 'M', '891', NULL, 'AIph2017', 'AIph01Plus', 4);
INSERT INTO `Progetto`.`Operazione` (`ID`, `Descrizione`, `Faccia`, `Tipo`, `ClasseCampione`, `Giunzione`, `Prodotto`, `Variante`, `Livello`) VALUES (21, 'Smontaggio scocca, scheda madre', 1, 'S', '898', NULL, 'AIph2017', 'AIph01Plus', 3);
INSERT INTO `Progetto`.`Operazione` (`ID`, `Descrizione`, `Faccia`, `Tipo`, `ClasseCampione`, `Giunzione`, `Prodotto`, `Variante`, `Livello`) VALUES (22, 'Smontaggio scocca, back cover', 2, 'S', '879', NULL, 'AIph2017', 'AIph01Plus', 3);
INSERT INTO `Progetto`.`Operazione` (`ID`, `Descrizione`, `Faccia`, `Tipo`, `ClasseCampione`, `Giunzione`, `Prodotto`, `Variante`, `Livello`) VALUES (23, 'Smontaggio scheda madre, fotocamera', 1, 'S', '890', NULL, 'AIph2017', 'AIph01Plus', 2);
INSERT INTO `Progetto`.`Operazione` (`ID`, `Descrizione`, `Faccia`, `Tipo`, `ClasseCampione`, `Giunzione`, `Prodotto`, `Variante`, `Livello`) VALUES (24, 'Smontaggio scheda madre, batteria ', 1, 'S', '898', NULL, 'AIph2017', 'AIph01Plus', 2);
INSERT INTO `Progetto`.`Operazione` (`ID`, `Descrizione`, `Faccia`, `Tipo`, `ClasseCampione`, `Giunzione`, `Prodotto`, `Variante`, `Livello`) VALUES (25, 'Smontaggio scheda madre, slot ricarica ', 1, 'S', '898', NULL, 'AIph2017', 'AIph01Plus', 2);
INSERT INTO `Progetto`.`Operazione` (`ID`, `Descrizione`, `Faccia`, `Tipo`, `ClasseCampione`, `Giunzione`, `Prodotto`, `Variante`, `Livello`) VALUES (26, 'Smontaggio scheda madre, schermo touch-screen', 1, 'S', '890', NULL, 'AIph2017', 'AIph01Plus', 1);


INSERT INTO `Progetto`.`Azione` (`Base`, `Applicata`, `Operazione`, `Sequenza`, `Ripetizioni`) VALUES (102, 105, 1, 1, 1);
INSERT INTO `Progetto`.`Azione` (`Base`, `Applicata`, `Operazione`, `Sequenza`, `Ripetizioni`) VALUES (103, 105, 1, 1, 1);
INSERT INTO `Progetto`.`Azione` (`Base`, `Applicata`, `Operazione`, `Sequenza`, `Ripetizioni`) VALUES (102, 109, 2, 1, 1);
INSERT INTO `Progetto`.`Azione` (`Base`, `Applicata`, `Operazione`, `Sequenza`, `Ripetizioni`) VALUES (102, 110, 2, 1, 1);
INSERT INTO `Progetto`.`Azione` (`Base`, `Applicata`, `Operazione`, `Sequenza`, `Ripetizioni`) VALUES (102, 111, 2, 1, 1);
INSERT INTO `Progetto`.`Azione` (`Base`, `Applicata`, `Operazione`, `Sequenza`, `Ripetizioni`) VALUES (103, 110, 2, 1, 1);
INSERT INTO `Progetto`.`Azione` (`Base`, `Applicata`, `Operazione`, `Sequenza`, `Ripetizioni`) VALUES (103, 109, 2, 1, 1);
INSERT INTO `Progetto`.`Azione` (`Base`, `Applicata`, `Operazione`, `Sequenza`, `Ripetizioni`) VALUES (103, 111, 2, 1, 1);
INSERT INTO `Progetto`.`Azione` (`Base`, `Applicata`, `Operazione`, `Sequenza`, `Ripetizioni`) VALUES (105, 106, 3, 1, 1);
INSERT INTO `Progetto`.`Azione` (`Base`, `Applicata`, `Operazione`, `Sequenza`, `Ripetizioni`) VALUES (105, 107, 4, 1, 1);
INSERT INTO `Progetto`.`Azione` (`Base`, `Applicata`, `Operazione`, `Sequenza`, `Ripetizioni`) VALUES (105, 108, 4, 1, 1);
INSERT INTO `Progetto`.`Azione` (`Base`, `Applicata`, `Operazione`, `Sequenza`, `Ripetizioni`) VALUES (105, 112, 5, 1, 1);
INSERT INTO `Progetto`.`Azione` (`Base`, `Applicata`, `Operazione`, `Sequenza`, `Ripetizioni`) VALUES (105, 101, 6, 1, 1);
INSERT INTO `Progetto`.`Azione` (`Base`, `Applicata`, `Operazione`, `Sequenza`, `Ripetizioni`) VALUES (105, 104, 6, 1, 1);


INSERT INTO `Progetto`.`Utensile` (`Nome`, `Tipologia`) VALUES ('Trapano', 'Forare');
INSERT INTO `Progetto`.`Utensile` (`Nome`, `Tipologia`) VALUES ('Rivettatrice', 'Assemblare');
INSERT INTO `Progetto`.`Utensile` (`Nome`, `Tipologia`) VALUES ('Cacciavite Torx', 'Avvitare/Svitare');
INSERT INTO `Progetto`.`Utensile` (`Nome`, `Tipologia`) VALUES ('Cacciavite +', 'Avvitare/Svitare');
INSERT INTO `Progetto`.`Utensile` (`Nome`, `Tipologia`) VALUES ('Cacciavite -', 'Avvitare/Svitare');
INSERT INTO `Progetto`.`Utensile` (`Nome`, `Tipologia`) VALUES ('Saldatrice TIG', 'Saldare');
INSERT INTO `Progetto`.`Utensile` (`Nome`, `Tipologia`) VALUES ('Saldatrice a Stagno', 'Saldare (parti elettroniche)');
INSERT INTO `Progetto`.`Utensile` (`Nome`, `Tipologia`) VALUES ('Martello ', 'Battere');
INSERT INTO `Progetto`.`Utensile` (`Nome`, `Tipologia`) VALUES ('Martello (gomma)', 'Incastrare');
INSERT INTO `Progetto`.`Utensile` (`Nome`, `Tipologia`) VALUES ('Brugola 8 mm', 'Avvitare/Svitare');
INSERT INTO `Progetto`.`Utensile` (`Nome`, `Tipologia`) VALUES ('Brugola 9 mm', 'Avvitare/Svitare');
INSERT INTO `Progetto`.`Utensile` (`Nome`, `Tipologia`) VALUES ('Brugola 10 mm', 'Avvitare/Svitare');
INSERT INTO `Progetto`.`Utensile` (`Nome`, `Tipologia`) VALUES ('Chiave 10 mm', 'Avvitare/Svitare');
INSERT INTO `Progetto`.`Utensile` (`Nome`, `Tipologia`) VALUES ('Chiave 12 mm', 'Avvitare/Svitare');
INSERT INTO `Progetto`.`Utensile` (`Nome`, `Tipologia`) VALUES ('Pinza a becco stretto', 'Stringere');
INSERT INTO `Progetto`.`Utensile` (`Nome`, `Tipologia`) VALUES ('Pinza Crimpatrice', 'Spellare cavi');
INSERT INTO `Progetto`.`Utensile` (`Nome`, `Tipologia`) VALUES ('Chiave Dinamometrica', 'Serraggio di precisione');
INSERT INTO `Progetto`.`Utensile` (`Nome`, `Tipologia`) VALUES ('Pistola termica', 'Utensile universale');
INSERT INTO `Progetto`.`Utensile` (`Nome`, `Tipologia`) VALUES ('Dissaldatore ', 'Dissaldatura');


INSERT INTO `Progetto`.`Usa` (`Operazione`, `Sequenza`, `Utensile`) VALUES (1, 1, 'Cacciavite Torx');
INSERT INTO `Progetto`.`Usa` (`Operazione`, `Sequenza`, `Utensile`) VALUES (3, 1, 'Saldatrice a Stagno');
INSERT INTO `Progetto`.`Usa` (`Operazione`, `Sequenza`, `Utensile`) VALUES (4, 1, 'Cacciavite +');
INSERT INTO `Progetto`.`Usa` (`Operazione`, `Sequenza`, `Utensile`) VALUES (5, 1, 'Cacciavite -');
INSERT INTO `Progetto`.`Usa` (`Operazione`, `Sequenza`, `Utensile`) VALUES (6, 1, 'Saldatrice a Stagno');
INSERT INTO `Progetto`.`Usa` (`Operazione`, `Sequenza`, `Utensile`) VALUES (1, 12, 'Cacciavite Torx');
INSERT INTO `Progetto`.`Usa` (`Operazione`, `Sequenza`, `Utensile`) VALUES (3, 12, 'Dissaldatore');
INSERT INTO `Progetto`.`Usa` (`Operazione`, `Sequenza`, `Utensile`) VALUES (4, 12, 'Cacciavite +');
INSERT INTO `Progetto`.`Usa` (`Operazione`, `Sequenza`, `Utensile`) VALUES (5, 12, 'Cacciavite -');
INSERT INTO `Progetto`.`Usa` (`Operazione`, `Sequenza`, `Utensile`) VALUES (6, 12, 'Dissaldatore');


INSERT INTO `Progetto`.`DatiAnagraficiOperatore` (`Nome`, `Cognome`, `Citta`, `CodFiscale`, `DataNascita`) VALUES ('Giovanni', 'Verdi', 'Roma', 'jjj3', '1992-06-04');
INSERT INTO `Progetto`.`DatiAnagraficiOperatore` (`Nome`, `Cognome`, `Citta`, `CodFiscale`, `DataNascita`) VALUES ('Piero', 'Levi', 'Milano', 'fff8', '1979-12-05');
INSERT INTO `Progetto`.`DatiAnagraficiOperatore` (`Nome`, `Cognome`, `Citta`, `CodFiscale`, `DataNascita`) VALUES ('Franco', 'Rossi', 'Cagliari', 'sss0', '1986-05-21');
INSERT INTO `Progetto`.`DatiAnagraficiOperatore` (`Nome`, `Cognome`, `Citta`, `CodFiscale`, `DataNascita`) VALUES ('Gianna', 'Montessori', 'Torino', 'nnn2', '1968-01-29');
INSERT INTO `Progetto`.`DatiAnagraficiOperatore` (`Nome`, `Cognome`, `Citta`, `CodFiscale`, `DataNascita`) VALUES ('Francesca ', 'Pia', 'Milano', 'xxx2', '1974-03-09');
INSERT INTO `Progetto`.`DatiAnagraficiOperatore` (`Nome`, `Cognome`, `Citta`, `CodFiscale`, `DataNascita`) VALUES ('Simonetta', 'Viscardi', 'Roma', 'yyy9', '1982-09-16');
INSERT INTO `Progetto`.`DatiAnagraficiOperatore` (`Nome`, `Cognome`, `Citta`, `CodFiscale`, `DataNascita`) VALUES ('Federico', 'Copernico', 'Milano', 'hth5', '1995-03-15');
INSERT INTO `Progetto`.`DatiAnagraficiOperatore` (`Nome`, `Cognome`, `Citta`, `CodFiscale`, `DataNascita`) VALUES ('Samuele', 'Boldi', 'Roma', 'bab3', '1986-02-18');
INSERT INTO `Progetto`.`DatiAnagraficiOperatore` (`Nome`, `Cognome`, `Citta`, `CodFiscale`, `DataNascita`) VALUES ('Tommaso', 'Pannofino', 'Milano', 'vev1', '1990-07-24');
INSERT INTO `Progetto`.`DatiAnagraficiOperatore` (`Nome`, `Cognome`, `Citta`, `CodFiscale`, `DataNascita`) VALUES ('Allegra', 'De Marco', 'Roma', 'uuu9', '1959-08-16');


INSERT INTO Incarico (Tecnico, InterventoFisico) VALUES ('lok8', 10025);
INSERT INTO Incarico (Tecnico, InterventoFisico) VALUES ('nrn5', 10026);


INSERT INTO RimediUtilizzati (Conoscenza, CodRimedio) VALUES ('5252', 20800);
INSERT INTO RimediUtilizzati (Conoscenza, CodRimedio) VALUES ('5252', 20802);
INSERT INTO RimediUtilizzati (Conoscenza, CodRimedio) VALUES ('5252', 20803);
INSERT INTO RimediUtilizzati (Conoscenza, CodRimedio) VALUES ('6565', 20800);
INSERT INTO RimediUtilizzati (Conoscenza, CodRimedio) VALUES ('6565', 20801);
INSERT INTO RimediUtilizzati (Conoscenza, CodRimedio) VALUES ('6565', 20804);


INSERT INTO `Progetto`.`Garanzia` (`CodGaranzia`, `Descrizione`, `Durata`, `ClasseGuasti`) VALUES ('01A', 'Garanzia base', 12, 'U01');
INSERT INTO `Progetto`.`Garanzia` (`CodGaranzia`, `Descrizione`, `Durata`, `ClasseGuasti`) VALUES ('01B', 'Garanzia base + 1 anno', 24, 'U02');
INSERT INTO `Progetto`.`Garanzia` (`CodGaranzia`, `Descrizione`, `Durata`, `ClasseGuasti`) VALUES ('01C', 'Garanzia base + 2 anni', 36, 'U03');
INSERT INTO `Progetto`.`Garanzia` (`CodGaranzia`, `Descrizione`, `Durata`, `ClasseGuasti`) VALUES ('02A', 'Garanzia kasko base', 12, 'A01');
INSERT INTO `Progetto`.`Garanzia` (`CodGaranzia`, `Descrizione`, `Durata`, `ClasseGuasti`) VALUES ('02B', 'Garanzia kasko + 1 anno', 24, 'A02');
INSERT INTO `Progetto`.`Garanzia` (`CodGaranzia`, `Descrizione`, `Durata`, `ClasseGuasti`) VALUES ('02C', 'Garanzia kasko + 2 anni', 36, 'A03');


INSERT INTO `Progetto`.`Copertura` (`Prodotto`, `Garanzia`, `Prezzo`) VALUES ('AIph2017', '01A', 0);
INSERT INTO `Progetto`.`Copertura` (`Prodotto`, `Garanzia`, `Prezzo`) VALUES ('AIph2017', '01B', 52.25);
INSERT INTO `Progetto`.`Copertura` (`Prodotto`, `Garanzia`, `Prezzo`) VALUES ('AIph2017', '01C', 75.89);
INSERT INTO `Progetto`.`Copertura` (`Prodotto`, `Garanzia`, `Prezzo`) VALUES ('AIph2017', '02A', 105.59);
INSERT INTO `Progetto`.`Copertura` (`Prodotto`, `Garanzia`, `Prezzo`) VALUES ('AIph2017', '02B', 145.99);
INSERT INTO `Progetto`.`Copertura` (`Prodotto`, `Garanzia`, `Prezzo`) VALUES ('AIph2017', '02C', 175.99);
INSERT INTO `Progetto`.`Copertura` (`Prodotto`, `Garanzia`, `Prezzo`) VALUES ('LavAs2018', '01A', 0);
INSERT INTO `Progetto`.`Copertura` (`Prodotto`, `Garanzia`, `Prezzo`) VALUES ('LavAs2018', '01B', 43.99);
INSERT INTO `Progetto`.`Copertura` (`Prodotto`, `Garanzia`, `Prezzo`) VALUES ('LavAs2018', '01C', 67.25);
INSERT INTO `Progetto`.`Copertura` (`Prodotto`, `Garanzia`, `Prezzo`) VALUES ('LavAs2018', '02A', 98.25);
INSERT INTO `Progetto`.`Copertura` (`Prodotto`, `Garanzia`, `Prezzo`) VALUES ('LavAs2018', '02B', 107.99);
INSERT INTO `Progetto`.`Copertura` (`Prodotto`, `Garanzia`, `Prezzo`) VALUES ('LavAs2018', '02C', 125.40);
INSERT INTO `Progetto`.`Copertura` (`Prodotto`, `Garanzia`, `Prezzo`) VALUES ('TelQHD54', '01A', 0);
INSERT INTO `Progetto`.`Copertura` (`Prodotto`, `Garanzia`, `Prezzo`) VALUES ('TelQHD54', '01B', 53.00);
INSERT INTO `Progetto`.`Copertura` (`Prodotto`, `Garanzia`, `Prezzo`) VALUES ('TelQHD54', '01C', 67.95);
INSERT INTO `Progetto`.`Copertura` (`Prodotto`, `Garanzia`, `Prezzo`) VALUES ('TelQHD54', '02A', 89.39);
INSERT INTO `Progetto`.`Copertura` (`Prodotto`, `Garanzia`, `Prezzo`) VALUES ('TelQHD54', '02B', 99.00);
INSERT INTO `Progetto`.`Copertura` (`Prodotto`, `Garanzia`, `Prezzo`) VALUES ('TelQHD54', '02C', 121.39);


INSERT INTO `Progetto`.`Carrello` (`Prodotto`, `Variante`, `OrdineVendita`, `Garanzia`, `Categoria`, `Quantita`, `Stato`) VALUES ('AIph2017', 'AIph01Plus', 701, '01A', 'A', 1, 1);
INSERT INTO `Progetto`.`Carrello` (`Prodotto`, `Variante`, `OrdineVendita`, `Garanzia`, `Categoria`, `Quantita`, `Stato`) VALUES ('AIph2017', 'AIph01Plus', 702, '01A', 'A', 1, 1);
INSERT INTO `Progetto`.`Carrello` (`Prodotto`, `Variante`, `OrdineVendita`, `Garanzia`, `Categoria`, `Quantita`, `Stato`) VALUES ('AIph2017', 'AIph01Plus', 703, '01A', 'A', 1, 1);
INSERT INTO `Progetto`.`Carrello` (`Prodotto`, `Variante`, `OrdineVendita`, `Garanzia`, `Categoria`, `Quantita`, `Stato`) VALUES ('AIph2017', 'AIph01Plus', 700, '01A', 'A', 1, 1);
INSERT INTO `Progetto`.`Carrello` (`Prodotto`, `Variante`, `OrdineVendita`, `Garanzia`, `Categoria`, `Quantita`, `Stato`) VALUES ('AIph2017', 'AIph01Plus', 699, '01A', 'A', 1, 1);
INSERT INTO `Progetto`.`Carrello` (`Prodotto`, `Variante`, `OrdineVendita`, `Garanzia`, `Categoria`, `Quantita`, `Stato`) VALUES ('AIph2017', 'AIph01Plus', 698, '01A', 'A', 1, 1);
INSERT INTO `Progetto`.`Carrello` (`Prodotto`, `Variante`, `OrdineVendita`, `Garanzia`, `Categoria`, `Quantita`, `Stato`) VALUES ('AIph2017', 'AIph01Plus', 697, '01A', 'A', 1, 1);
INSERT INTO `Progetto`.`Carrello` (`Prodotto`, `Variante`, `OrdineVendita`, `Garanzia`, `Categoria`, `Quantita`, `Stato`) VALUES ('AIph2017', 'AIph01', 696, '01B', 'A', 1, 1);
INSERT INTO `Progetto`.`Carrello` (`Prodotto`, `Variante`, `OrdineVendita`, `Garanzia`, `Categoria`, `Quantita`, `Stato`) VALUES ('AIph2017', 'AIph01Plus', 704, '01A', 'A', 40, 0);


INSERT INTO `Progetto`.`Spedizione` (`Codice`, `DataPrevista`, `HubAttuale`, `Stato`, `AccountConsegna`, `OrdineVendita`) VALUES (791, '2019-11-26', 'Latina', 'Consegnato', 'l.arduini2', 701);
INSERT INTO `Progetto`.`Spedizione` (`Codice`, `DataPrevista`, `HubAttuale`, `Stato`, `AccountConsegna`, `OrdineVendita`) VALUES (792, '2019-12-17', 'Corigliano-Rozzano', 'Consegnato', 'a.demarco0', 702);
INSERT INTO `Progetto`.`Spedizione` (`Codice`, `DataPrevista`, `HubAttuale`, `Stato`, `AccountConsegna`, `OrdineVendita`) VALUES (793, '2020-02-28', 'Oristano', 'Consegnato', 'f.casu1', 703);
INSERT INTO `Progetto`.`Spedizione` (`Codice`, `DataPrevista`, `HubAttuale`, `Stato`, `AccountConsegna`, `OrdineVendita`) VALUES (790, '2019-11-03', 'Oristano', 'Consegnato', 'f.casu1', 700);
INSERT INTO `Progetto`.`Spedizione` (`Codice`, `DataPrevista`, `HubAttuale`, `Stato`, `AccountConsegna`, `OrdineVendita`) VALUES (789, '2019-08-25', 'Latina', 'Consegnato', 'l.arduini2', 699);
INSERT INTO `Progetto`.`Spedizione` (`Codice`, `DataPrevista`, `HubAttuale`, `Stato`, `AccountConsegna`, `OrdineVendita`) VALUES (788, '2019-08-08', 'Corigliano-Rozzano', 'Consegnato', 'a.demarco0', 698);
INSERT INTO `Progetto`.`Spedizione` (`Codice`, `DataPrevista`, `HubAttuale`, `Stato`, `AccountConsegna`, `OrdineVendita`) VALUES (787, '2019-01-15', 'Oristano', 'Consegnato', 'f.casu1', 697);


INSERT INTO `Progetto`.`OrdineParti` (`Codice`, `DataRichiesta`, `DataPrevistaConsegna`, `DataConsegna`, `InterventoFisico`) VALUES (6824, '2020-05-03', '2020-05-05', '2020-05-05', 10025);
INSERT INTO `Progetto`.`OrdineParti` (`Codice`, `DataRichiesta`, `DataPrevistaConsegna`, `DataConsegna`, `InterventoFisico`) VALUES (9285, '2019-06-29', '2019-06-30', '2019-06-30', 10026);


INSERT INTO `Progetto`.`Ricambio` (`OrdineParti`, `Parte`) VALUES (6824, 108);
INSERT INTO `Progetto`.`Ricambio` (`OrdineParti`, `Parte`) VALUES (9285, 104);


INSERT INTO `Progetto`.`Reso` (`Codice`, `DataRichiesta`, `Approvato`, `DataApprovazione`, `UnitaVendute`) VALUES (400, '2019-12-07', 1, '2019-12-10', '910');
INSERT INTO `Progetto`.`Reso` (`Codice`, `DataRichiesta`, `Approvato`, `DataApprovazione`, `UnitaVendute`) VALUES (401, '2019-12-27', 1, '2019-12-29', '911');
INSERT INTO `Progetto`.`Reso` (`Codice`, `DataRichiesta`, `Approvato`, `DataApprovazione`, `UnitaVendute`) VALUES (402, '2019-01-28', 1, '2020-01-31', '912');
INSERT INTO `Progetto`.`Reso` (`Codice`, `DataRichiesta`, `Approvato`, `DataApprovazione`, `UnitaVendute`) VALUES (403, '2019-02-19', 1, '2020-02-21', '907');


INSERT INTO `Progetto`.`Fattura` (`Codice`, `DataRilascio`, `TotaleNetto`, `Pagamento`, `InGaranzia`, `InterventoFisico`) VALUES (95353, '2020-05-06', 0, 'Contanti', 0, 10025);
INSERT INTO `Progetto`.`Fattura` (`Codice`, `DataRilascio`, `TotaleNetto`, `Pagamento`, `InGaranzia`, `InterventoFisico`) VALUES (98526, '2019-06-30', 0, 'Bonifico', 0, 10026);


INSERT INTO Motivazione (CodMotivazione, Nome, Descrizione) VALUES (62, 'Insoddisfazione', 'Cliente insoddisfatto (generico)');
INSERT INTO Motivazione (CodMotivazione, Nome, Descrizione) VALUES (63, 'Scarsa qualità', 'Cliente insoddisfatto della qualità costruttiva');
INSERT INTO Motivazione (CodMotivazione, Nome, Descrizione) VALUES (64, 'Scarse prestazioni', 'Cliente insoddisfatto delle prestazioni');
INSERT INTO Motivazione (CodMotivazione, Nome, Descrizione) VALUES (65, 'Prodotto difettoso', 'Prodotto diffettoso (generico)');
INSERT INTO Motivazione (CodMotivazione, Nome, Descrizione) VALUES (66, 'Imperfezioni estetiche', 'Il prodotto presenta imperfezioni estetiche');
INSERT INTO Motivazione (CodMotivazione, Nome, Descrizione) VALUES (67, 'Altro', 'Altra motivazione');
INSERT INTO Motivazione (CodMotivazione, Nome, Descrizione) VALUES (61, 'Descrizione non conforme', 'Prodotto non conforme alla descrizione fornita al momento dell\'acquisto');
INSERT INTO Motivazione (CodMotivazione, Nome, Descrizione) VALUES (68, 'M00', 'Diritto di recesso');


INSERT INTO RichiestaReso (Reso, Motivazione, Account, Commento) VALUES (400, 62, 'a.demarco0', NULL);
INSERT INTO RichiestaReso (Reso, Motivazione, Account, Commento) VALUES (401, 67, 'l.arduini2', 'L\'angolo superiore sinistro presenta un graffio profondo');
INSERT INTO RichiestaReso (Reso, Motivazione, Account, Commento) VALUES (402, 63, 'f.casu1', NULL);
INSERT INTO RichiestaReso (Reso, Motivazione, Account, Commento) VALUES (403, 67, 'f.casu1', 'Prodotto non utile alle mie esigenze');


INSERT INTO UnitaDisponibili (UID, Prodotto, Variante, LottoProduzione) VALUES ('904', 'AIph2017', 'AIph01Plus', 801);
INSERT INTO UnitaDisponibili (UID, Prodotto, Variante, LottoProduzione) VALUES ('905', 'AIph2017', 'AIph01Plus', 801);
INSERT INTO UnitaDisponibili (UID, Prodotto, Variante, LottoProduzione) VALUES ('906', 'AIph2017', 'AIph01Plus', 801);
INSERT INTO UnitaDisponibili (UID, Prodotto, Variante, LottoProduzione) VALUES ('990', 'AIph2017', 'AIph01Plus', 802);
INSERT INTO UnitaDisponibili (UID, Prodotto, Variante, LottoProduzione) VALUES ('991', 'AIph2017', 'AIph01Plus', 802);
INSERT INTO UnitaDisponibili (UID, Prodotto, Variante, LottoProduzione) VALUES ('992', 'AIph2017', 'AIph01Plus', 802);
INSERT INTO UnitaDisponibili (UID, Prodotto, Variante, LottoProduzione) VALUES ('993', 'AIph2017', 'AIph01Plus', 802);
INSERT INTO UnitaDisponibili (UID, Prodotto, Variante, LottoProduzione) VALUES ('994', 'AIph2017', 'AIph01Plus', 802);
INSERT INTO UnitaDisponibili (UID, Prodotto, Variante, LottoProduzione) VALUES ('995', 'AIph2017', 'AIph01Plus', 802);
INSERT INTO UnitaDisponibili (UID, Prodotto, Variante, LottoProduzione) VALUES ('996', 'AIph2017', 'AIph01Plus', 802);
INSERT INTO UnitaDisponibili (UID, Prodotto, Variante, LottoProduzione) VALUES ('997', 'AIph2017', 'AIph01Plus', 802);
INSERT INTO UnitaDisponibili (UID, Prodotto, Variante, LottoProduzione) VALUES ('998', 'AIph2017', 'AIph01Plus', 802);
INSERT INTO UnitaDisponibili (UID, Prodotto, Variante, LottoProduzione) VALUES ('999', 'AIph2017', 'AIph01Plus', 802);
INSERT INTO UnitaDisponibili (UID, Prodotto, Variante, LottoProduzione) VALUES ('980', 'AIph2017', 'AIph01Plus', 803);
INSERT INTO UnitaDisponibili (UID, Prodotto, Variante, LottoProduzione) VALUES ('981', 'AIph2017', 'AIph01Plus', 803);
INSERT INTO UnitaDisponibili (UID, Prodotto, Variante, LottoProduzione) VALUES ('982', 'AIph2017', 'AIph01Plus', 803);
INSERT INTO UnitaDisponibili (UID, Prodotto, Variante, LottoProduzione) VALUES ('983', 'AIph2017', 'AIph01Plus', 803);
INSERT INTO UnitaDisponibili (UID, Prodotto, Variante, LottoProduzione) VALUES ('984', 'AIph2017', 'AIph01Plus', 803);
INSERT INTO UnitaDisponibili (UID, Prodotto, Variante, LottoProduzione) VALUES ('985', 'AIph2017', 'AIph01Plus', 803);
INSERT INTO UnitaDisponibili (UID, Prodotto, Variante, LottoProduzione) VALUES ('986', 'AIph2017', 'AIph01Plus', 803);
INSERT INTO UnitaDisponibili (UID, Prodotto, Variante, LottoProduzione) VALUES ('987', 'AIph2017', 'AIph01Plus', 803);
INSERT INTO UnitaDisponibili (UID, Prodotto, Variante, LottoProduzione) VALUES ('988', 'AIph2017', 'AIph01Plus', 803);
INSERT INTO UnitaDisponibili (UID, Prodotto, Variante, LottoProduzione) VALUES ('989', 'AIph2017', 'AIph01Plus', 803);
INSERT INTO UnitaDisponibili (UID, Prodotto, Variante, LottoProduzione) VALUES ('970', 'AIph2017', 'AIph01Plus', 804);
INSERT INTO UnitaDisponibili (UID, Prodotto, Variante, LottoProduzione) VALUES ('971', 'AIph2017', 'AIph01Plus', 804);
INSERT INTO UnitaDisponibili (UID, Prodotto, Variante, LottoProduzione) VALUES ('972', 'AIph2017', 'AIph01Plus', 804);
INSERT INTO UnitaDisponibili (UID, Prodotto, Variante, LottoProduzione) VALUES ('973', 'AIph2017', 'AIph01Plus', 804);
INSERT INTO UnitaDisponibili (UID, Prodotto, Variante, LottoProduzione) VALUES ('974', 'AIph2017', 'AIph01Plus', 804);
INSERT INTO UnitaDisponibili (UID, Prodotto, Variante, LottoProduzione) VALUES ('975', 'AIph2017', 'AIph01Plus', 804);
INSERT INTO UnitaDisponibili (UID, Prodotto, Variante, LottoProduzione) VALUES ('976', 'AIph2017', 'AIph01Plus', 804);


INSERT INTO LottoSmaltimento (CodLotto, Magazzino, Area, Linea, DataInizioSmaltimento) VALUES (501, 3002, 1, '201S', '2019-12-12');
INSERT INTO LottoSmaltimento (CodLotto, Magazzino, Area, Linea, DataInizioSmaltimento) VALUES (409, 3002, 1, '201S', '2020-01-04');
INSERT INTO LottoSmaltimento (CodLotto, Magazzino, Area, Linea, DataInizioSmaltimento) VALUES (503, 3002, 1, '201S', '2020-03-10');


INSERT INTO StazioneProduzione (CodStazione, Orientazione, TempoPrevisto, Linea, ClasseCampione) VALUES ('660', 1, 4, '201', '879');
INSERT INTO StazioneProduzione (CodStazione, Orientazione, TempoPrevisto, Linea, ClasseCampione) VALUES ('661', 2, 1, '201', '891');
INSERT INTO StazioneProduzione (CodStazione, Orientazione, TempoPrevisto, Linea, ClasseCampione) VALUES ('662', 1, 5, '201', '892');
INSERT INTO StazioneProduzione (CodStazione, Orientazione, TempoPrevisto, Linea, ClasseCampione) VALUES ('663', 1, 4, '201', '892');


INSERT INTO StazioneSmaltimento (CodStazione, Livello, ParteTarget, Linea) VALUES ('671', 0, 'Back Cover', '201S');
INSERT INTO StazioneSmaltimento (CodStazione, Livello, ParteTarget, Linea) VALUES ('672', 0, NULL, '201S');
INSERT INTO StazioneSmaltimento (CodStazione, Livello, ParteTarget, Linea) VALUES ('673', 1, 'Fotocamera', '201S');
INSERT INTO StazioneSmaltimento (CodStazione, Livello, ParteTarget, Linea) VALUES ('674', 1, 'Batteria', '201S');
INSERT INTO StazioneSmaltimento (CodStazione, Livello, ParteTarget, Linea) VALUES ('675', 1, 'Ricarica USB-C', '201S');
INSERT INTO StazioneSmaltimento (CodStazione, Livello, ParteTarget, Linea) VALUES ('676', 1, 'Scheda Madre', '201S');


INSERT INTO Operatore (CodiceFiscale, Stipendio, StazioneProduzione, StazioneSmaltimento) VALUES ('jjj3', 1675, '660', NULL);
INSERT INTO Operatore (CodiceFiscale, Stipendio, StazioneProduzione, StazioneSmaltimento) VALUES ('fff8', 1745, '660', NULL);
INSERT INTO Operatore (CodiceFiscale, Stipendio, StazioneProduzione, StazioneSmaltimento) VALUES ('sss0', 1650, '661', NULL);
INSERT INTO Operatore (CodiceFiscale, Stipendio, StazioneProduzione, StazioneSmaltimento) VALUES ('nnn2', 1680, '662', NULL);
INSERT INTO Operatore (CodiceFiscale, Stipendio, StazioneProduzione, StazioneSmaltimento) VALUES ('xxx2', 1710, '663', NULL);
INSERT INTO Operatore (CodiceFiscale, Stipendio, StazioneProduzione, StazioneSmaltimento) VALUES ('yyy9', 1705, NULL, NULL);


INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('891', 'jjj3', 4);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('892', 'jjj3', 4);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('893', 'jjj3', 3);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('894', 'jjj3', 5);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('895', 'jjj3', 4);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('896', 'jjj3', 3);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('897', 'jjj3', 2);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('898', 'jjj3', 3);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('899', 'jjj3', 4);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('890', 'jjj3', 5);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('879', 'jjj3', 3);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('891', 'fff8', 5);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('892', 'fff8', 3);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('893', 'fff8', 4);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('894', 'fff8', 3);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('895', 'fff8', 2);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('896', 'fff8', 3);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('897', 'fff8', 4);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('898', 'fff8', 3);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('899', 'fff8', 3);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('890', 'fff8', 4);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('879', 'fff8', 3);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('891', 'sss0', 4);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('892', 'sss0', 5);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('893', 'sss0', 3);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('894', 'sss0', 4);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('895', 'sss0', 4);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('896', 'sss0', 2);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('897', 'sss0', 3);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('898', 'sss0', 4);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('899', 'sss0', 5);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('890', 'sss0', 4);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('879', 'sss0', 4);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('891', 'nnn2', 5);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('892', 'nnn2', 4);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('893', 'nnn2', 4);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('894', 'nnn2', 5);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('895', 'nnn2', 5);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('896', 'nnn2', 4);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('897', 'nnn2', 4);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('898', 'nnn2', 3);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('899', 'nnn2', 3);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('890', 'nnn2', 4);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('879', 'nnn2', 4);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('891', 'xxx2', 3);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('892', 'xxx2', 3);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('893', 'xxx2', 4);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('894', 'xxx2', 3);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('895', 'xxx2', 3);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('896', 'xxx2', 5);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('897', 'xxx2', 4);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('898', 'xxx2', 5);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('899', 'xxx2', 5);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('890', 'xxx2', 4);
INSERT INTO Valutazione (ClasseCampione, Dipendente, TempoImpiegato) VALUES ('879', 'xxx2', 4);


INSERT INTO EsecuzioneProduzione (StazioneProduzione, Operazione, Sequenza) VALUES ('660', 1, 1);
INSERT INTO EsecuzioneProduzione (StazioneProduzione, Operazione, Sequenza) VALUES ('661', 2, 1);
INSERT INTO EsecuzioneProduzione (StazioneProduzione, Operazione, Sequenza) VALUES ('662', 3, 1);
INSERT INTO EsecuzioneProduzione (StazioneProduzione, Operazione, Sequenza) VALUES ('662', 6, 1);
INSERT INTO EsecuzioneProduzione (StazioneProduzione, Operazione, Sequenza) VALUES ('663', 4, 1);
INSERT INTO EsecuzioneProduzione (StazioneProduzione, Operazione, Sequenza) VALUES ('663', 5, 1);


INSERT INTO EsecuzioneSmaltimento (StazioneSmaltimento, Operazione, Sequenza) VALUES ('671', 2, 12);
INSERT INTO EsecuzioneSmaltimento (StazioneSmaltimento, Operazione, Sequenza) VALUES ('672', 1, 12);
INSERT INTO EsecuzioneSmaltimento (StazioneSmaltimento, Operazione, Sequenza) VALUES ('673', 3, 12);
INSERT INTO EsecuzioneSmaltimento (StazioneSmaltimento, Operazione, Sequenza) VALUES ('674', 4, 12);
INSERT INTO EsecuzioneSmaltimento (StazioneSmaltimento, Operazione, Sequenza) VALUES ('675', 5, 12);
INSERT INTO EsecuzioneSmaltimento (StazioneSmaltimento, Operazione, Sequenza) VALUES ('676', 6, 12);


INSERT INTO UnitaRese (UID, Reso, Magazzino, Area) VALUES ('910', 400, 3001, 1);
INSERT INTO UnitaRese (UID, Reso, Magazzino, Area) VALUES ('911', 401, 3001, 1);
INSERT INTO UnitaRese (UID, Reso, Magazzino, Area) VALUES ('912', 402, 3001, 1);
INSERT INTO UnitaRese (UID, Reso, Magazzino, Area) VALUES ('907', 403, 3001, 1);


INSERT INTO Test (Codice, Nome, TestPadre, Importanza, Prodotto, Livello) VALUES ('A20', 'Test Back Cover (estetico)', NULL, 5, 'AIph2017', 0);
INSERT INTO Test (Codice, Nome, TestPadre, Importanza, Prodotto, Livello) VALUES ('A21', 'Test Scocca', 'A20', 5, 'AIph2017', 1);
INSERT INTO Test (Codice, Nome, TestPadre, Importanza, Prodotto, Livello) VALUES ('A22', 'Test Batteria', 'A23', 10, 'AIph2017', 2);
INSERT INTO Test (Codice, Nome, TestPadre, Importanza, Prodotto, Livello) VALUES ('A23', 'Test Schermo Touch-screen', 'A20', 30, 'AIph2017', 1);
INSERT INTO Test (Codice, Nome, TestPadre, Importanza, Prodotto, Livello) VALUES ('A24', 'Test Fotocamera', 'A23', 10, 'AIph2017', 2);
INSERT INTO Test (Codice, Nome, TestPadre, Importanza, Prodotto, Livello) VALUES ('A25', 'Test Scheda Madre', 'A23', 25, 'AIph2017', 2);
INSERT INTO Test (Codice, Nome, TestPadre, Importanza, Prodotto, Livello) VALUES ('A26', 'Test Audio', 'A25', 5, 'AIph2017', 3);
INSERT INTO Test (Codice, Nome, TestPadre, Importanza, Prodotto, Livello) VALUES ('A27', 'Test Pulsanti', 'A25', 5, 'AIph2017', 3);
INSERT INTO Test (Codice, Nome, TestPadre, Importanza, Prodotto, Livello) VALUES ('A28', 'Test Ricarica USB-C', 'A23', 5, 'AIph2017', 2);


INSERT INTO ControlloGenerale (UnitaResa, Test, Superato) VALUES ('907', 'A20', 1);
INSERT INTO ControlloGenerale (UnitaResa, Test, Superato) VALUES ('907', 'A21', 1);
INSERT INTO ControlloGenerale (UnitaResa, Test, Superato) VALUES ('907', 'A22', 0);
INSERT INTO ControlloGenerale (UnitaResa, Test, Superato) VALUES ('907', 'A23', 1);
INSERT INTO ControlloGenerale (UnitaResa, Test, Superato) VALUES ('907', 'A24', 1);
INSERT INTO ControlloGenerale (UnitaResa, Test, Superato) VALUES ('907', 'A25', 1);
INSERT INTO ControlloGenerale (UnitaResa, Test, Superato) VALUES ('907', 'A26', 1);
INSERT INTO ControlloGenerale (UnitaResa, Test, Superato) VALUES ('907', 'A27', 1);
INSERT INTO ControlloGenerale (UnitaResa, Test, Superato) VALUES ('907', 'A28', 1);
INSERT INTO ControlloGenerale (UnitaResa, Test, Superato) VALUES ('910', 'A20', 1);
INSERT INTO ControlloGenerale (UnitaResa, Test, Superato) VALUES ('910', 'A21', 1);
INSERT INTO ControlloGenerale (UnitaResa, Test, Superato) VALUES ('910', 'A22', 1);
INSERT INTO ControlloGenerale (UnitaResa, Test, Superato) VALUES ('910', 'A23', 1);
INSERT INTO ControlloGenerale (UnitaResa, Test, Superato) VALUES ('910', 'A24', 1);
INSERT INTO ControlloGenerale (UnitaResa, Test, Superato) VALUES ('910', 'A25', 0);
INSERT INTO ControlloGenerale (UnitaResa, Test, Superato) VALUES ('910', 'A26', 0);
INSERT INTO ControlloGenerale (UnitaResa, Test, Superato) VALUES ('910', 'A27', 0);
INSERT INTO ControlloGenerale (UnitaResa, Test, Superato) VALUES ('910', 'A28', 1);
INSERT INTO ControlloGenerale (UnitaResa, Test, Superato) VALUES ('911', 'A20', 1);
INSERT INTO ControlloGenerale (UnitaResa, Test, Superato) VALUES ('911', 'A21', 1);
INSERT INTO ControlloGenerale (UnitaResa, Test, Superato) VALUES ('911', 'A22', 1);
INSERT INTO ControlloGenerale (UnitaResa, Test, Superato) VALUES ('911', 'A23', 1);
INSERT INTO ControlloGenerale (UnitaResa, Test, Superato) VALUES ('911', 'A24', 1);
INSERT INTO ControlloGenerale (UnitaResa, Test, Superato) VALUES ('911', 'A25', 0);
INSERT INTO ControlloGenerale (UnitaResa, Test, Superato) VALUES ('911', 'A26', 0);
INSERT INTO ControlloGenerale (UnitaResa, Test, Superato) VALUES ('911', 'A27', 0);
INSERT INTO ControlloGenerale (UnitaResa, Test, Superato) VALUES ('911', 'A28', 1);


INSERT INTO ControlloTest (Parte, Test) VALUES (109, 'A20');
INSERT INTO ControlloTest (Parte, Test) VALUES (110, 'A20');
INSERT INTO ControlloTest (Parte, Test) VALUES (111, 'A20');
INSERT INTO ControlloTest (Parte, Test) VALUES (112, 'A28');
INSERT INTO ControlloTest (Parte, Test) VALUES (102, 'A21');
INSERT INTO ControlloTest (Parte, Test) VALUES (103, 'A21');
INSERT INTO ControlloTest (Parte, Test) VALUES (101, 'A23');
INSERT INTO ControlloTest (Parte, Test) VALUES (104, 'A23');
INSERT INTO ControlloTest (Parte, Test) VALUES (107, 'A22');
INSERT INTO ControlloTest (Parte, Test) VALUES (108, 'A22');
INSERT INTO ControlloTest (Parte, Test) VALUES (105, 'A25');
INSERT INTO ControlloTest (Parte, Test) VALUES (106, 'A24');
INSERT INTO ControlloTest (Parte, Test) VALUES (105, 'A27');
INSERT INTO ControlloTest (Parte, Test) VALUES (105, 'A26');


INSERT INTO Ricondizionamento (Parte, UnitaResa, Quantita) VALUES (107, '907', 1);


INSERT INTO UnitaEndOfLife (UID, GradoUsura, LottoSmaltimento, Prodotto, Variante) VALUES ('908', 3, 501, 'AIph2017', 'AIph01Plus');
INSERT INTO UnitaEndOfLife (UID, GradoUsura, LottoSmaltimento, Prodotto, Variante) VALUES ('909', 3, 501, 'AIph2017', 'AIph01Plus');
INSERT INTO UnitaEndOfLife (UID, GradoUsura, LottoSmaltimento, Prodotto, Variante) VALUES ('815', 2, 409, 'AIph2017', 'AIph01');
INSERT INTO UnitaEndOfLife (UID, GradoUsura, LottoSmaltimento, Prodotto, Variante) VALUES ('816', 2, 409, 'AIph2017', 'AIph01');
INSERT INTO UnitaEndOfLife (UID, GradoUsura, LottoSmaltimento, Prodotto, Variante) VALUES ('817', 2, 409, 'AIph2017', 'AIph01');
INSERT INTO UnitaEndOfLife (UID, GradoUsura, LottoSmaltimento, Prodotto, Variante) VALUES ('818', 2, 409, 'AIph2017', 'AIph01');
INSERT INTO UnitaEndOfLife (UID, GradoUsura, LottoSmaltimento, Prodotto, Variante) VALUES ('819', 2, 409, 'AIph2017', 'AIph01');
INSERT INTO UnitaEndOfLife (UID, GradoUsura, LottoSmaltimento, Prodotto, Variante) VALUES ('821', 2, 409, 'AIph2017', 'AIph01');


INSERT INTO UnitaRicondizionate (UID, Grado, Prodotto, Variante, Ricondizionamento) VALUES ('907R', 'B', 'AIph2017', 'AIph02', 1);


INSERT INTO RecuperoMateriale (UnitaEndOfLife, StazioneSmaltimento, Materiale, Quantita) VALUES ('908', '674', 'Litio', 0.010);
INSERT INTO RecuperoMateriale (UnitaEndOfLife, StazioneSmaltimento, Materiale, Quantita) VALUES ('909', '674', 'Litio', 0.009);
INSERT INTO RecuperoMateriale (UnitaEndOfLife, StazioneSmaltimento, Materiale, Quantita) VALUES ('815', '674', 'Litio', 0.0085);
INSERT INTO RecuperoMateriale (UnitaEndOfLife, StazioneSmaltimento, Materiale, Quantita) VALUES ('816', '674', 'Litio', 0.0011);
INSERT INTO RecuperoMateriale (UnitaEndOfLife, StazioneSmaltimento, Materiale, Quantita) VALUES ('817', '674', 'Litio', 0.00105);
INSERT INTO RecuperoMateriale (UnitaEndOfLife, StazioneSmaltimento, Materiale, Quantita) VALUES ('818', '674', 'Litio', 0.0083);
INSERT INTO RecuperoMateriale (UnitaEndOfLife, StazioneSmaltimento, Materiale, Quantita) VALUES ('819', '674', 'Litio', 0.0056);
INSERT INTO RecuperoMateriale (UnitaEndOfLife, StazioneSmaltimento, Materiale, Quantita) VALUES ('821', '674', 'Litio', 0.0012);
INSERT INTO RecuperoMateriale (UnitaEndOfLife, StazioneSmaltimento, Materiale, Quantita) VALUES ('908', '673', 'Acciaio INOX', 0.0034);
INSERT INTO RecuperoMateriale (UnitaEndOfLife, StazioneSmaltimento, Materiale, Quantita) VALUES ('909', '673', 'Acciaio INOX', 0.00355);
INSERT INTO RecuperoMateriale (UnitaEndOfLife, StazioneSmaltimento, Materiale, Quantita) VALUES ('815', '673', 'Acciaio INOX', 0.00245);
INSERT INTO RecuperoMateriale (UnitaEndOfLife, StazioneSmaltimento, Materiale, Quantita) VALUES ('816', '676', 'Rame', 0.00053);
INSERT INTO RecuperoMateriale (UnitaEndOfLife, StazioneSmaltimento, Materiale, Quantita) VALUES ('817', '675', 'Acciaio INOX', 0.0043);
INSERT INTO RecuperoMateriale (UnitaEndOfLife, StazioneSmaltimento, Materiale, Quantita) VALUES ('818', '676', 'Rame', 0.0023);
INSERT INTO RecuperoMateriale (UnitaEndOfLife, StazioneSmaltimento, Materiale, Quantita) VALUES ('819', '676', 'Rame', 0.009033);
INSERT INTO RecuperoMateriale (UnitaEndOfLife, StazioneSmaltimento, Materiale, Quantita) VALUES ('821', '676', 'Rame', 0.0010);
INSERT INTO RecuperoMateriale (UnitaEndOfLife, StazioneSmaltimento, Materiale, Quantita) VALUES ('821', '676', 'Argento', 0.0042);
INSERT INTO RecuperoMateriale (UnitaEndOfLife, StazioneSmaltimento, Materiale, Quantita) VALUES ('909', '676', 'Argento', 0.00646);
INSERT INTO RecuperoMateriale (UnitaEndOfLife, StazioneSmaltimento, Materiale, Quantita) VALUES ('815', '671', 'Vetro', 0.009);
INSERT INTO RecuperoMateriale (UnitaEndOfLife, StazioneSmaltimento, Materiale, Quantita) VALUES ('817', '671', 'Vetro', 0.0053);
INSERT INTO RecuperoMateriale (UnitaEndOfLife, StazioneSmaltimento, Materiale, Quantita) VALUES ('819', '671', 'Vetro', 0.00453);
INSERT INTO RecuperoMateriale (UnitaEndOfLife, StazioneSmaltimento, Materiale, Quantita) VALUES ('816', '672', 'Plastica', 0.00543);
INSERT INTO RecuperoMateriale (UnitaEndOfLife, StazioneSmaltimento, Materiale, Quantita) VALUES ('818', '672', 'Plastica', 0.0031);
INSERT INTO RecuperoMateriale (UnitaEndOfLife, StazioneSmaltimento, Materiale, Quantita) VALUES ('908', '672', 'Plastica', 0.00464);


INSERT INTO RecuperoParte (UnitaEndOfLife, Parte, StazioneSmaltimento, Quantita) VALUES ('908', 108, '674', 1);
INSERT INTO RecuperoParte (UnitaEndOfLife, Parte, StazioneSmaltimento, Quantita) VALUES ('909', 108, '674', 1);
INSERT INTO RecuperoParte (UnitaEndOfLife, Parte, StazioneSmaltimento, Quantita) VALUES ('815', 107, '674', 1);
INSERT INTO RecuperoParte (UnitaEndOfLife, Parte, StazioneSmaltimento, Quantita) VALUES ('816', 107, '674', 1);
INSERT INTO RecuperoParte (UnitaEndOfLife, Parte, StazioneSmaltimento, Quantita) VALUES ('817', 107, '674', 1);
INSERT INTO RecuperoParte (UnitaEndOfLife, Parte, StazioneSmaltimento, Quantita) VALUES ('818', 107, '674', 1);
INSERT INTO RecuperoParte (UnitaEndOfLife, Parte, StazioneSmaltimento, Quantita) VALUES ('819', 107, '674', 1);
INSERT INTO RecuperoParte (UnitaEndOfLife, Parte, StazioneSmaltimento, Quantita) VALUES ('821', 109, '672', 1);


INSERT INTO DatiAnagraficiTecnico (Nome, Cognome, Citta, CodiceFiscale, DataNascita) VALUES ('Amed', 'Hallamush', 'Latina', 'hgh3', '1980-09-20');
INSERT INTO DatiAnagraficiTecnico (Nome, Cognome, Citta, CodiceFiscale, DataNascita) VALUES ('Francesca', 'Verdi', 'Roma', 'nrn5', '1979-01-31');
INSERT INTO DatiAnagraficiTecnico (Nome, Cognome, Citta, CodiceFiscale, DataNascita) VALUES ('Marco', 'Rossi', 'Catania', 'eve2', '1992-02-25');
INSERT INTO DatiAnagraficiTecnico (Nome, Cognome, Citta, CodiceFiscale, DataNascita) VALUES ('Bill', 'Gates', 'New York', 'klk9', '1959-06-06');
INSERT INTO DatiAnagraficiTecnico (Nome, Cognome, Citta, CodiceFiscale, DataNascita) VALUES ('Luis', 'Arancione', 'Oristano', 'brb4', '1993-07-24');
INSERT INTO DatiAnagraficiTecnico (Nome, Cognome, Citta, CodiceFiscale, DataNascita) VALUES ('Federico', 'Baggio', 'Bologna', 'xcz1', '1984-09-17');
INSERT INTO DatiAnagraficiTecnico (Nome, Cognome, Citta, CodiceFiscale, DataNascita) VALUES ('Ivan', 'Greco', 'Torino', 'lok8', '1975-12-12');
INSERT INTO DatiAnagraficiTecnico (Nome, Cognome, Citta, CodiceFiscale, DataNascita) VALUES ('Simone', 'Todaro', 'Venezia', 'bje5', '1996-05-27');
INSERT INTO DatiAnagraficiTecnico (Nome, Cognome, Citta, CodiceFiscale, DataNascita) VALUES ('Allegra', 'Piano', 'Trento', 'xsw2', '1978-04-21');
INSERT INTO DatiAnagraficiTecnico (Nome, Cognome, Citta, CodiceFiscale, DataNascita) VALUES ('Martina', 'Smeraldi', 'Napoli', 'ofe7', '1999-09-12');

COMMIT;