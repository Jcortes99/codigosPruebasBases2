
-- ==================================================================================================================
-- ===================================   PRIMER PUNTO TRIGGER CON EXCEPTIONS (25%)   ================================
-- ==================================================================================================================

CREATE OR REPLACE FUNCTION CHECK_PASSPORT(PASSPORT NUMBER)
    RETURN BOOLEAN IS
    BEGIN
        FOR query IN (SELECT * FROM karateca WHERE pasaporte = PASSPORT) LOOP
          RETURN FALSE;
        END LOOP;
        RETURN TRUE;
    END;
/
    
CREATE OR REPLACE TRIGGER CONTROL_DATOEV
BEFORE INSERT
  ON evento
  FOR EACH ROW
DECLARE
    cont NUMBER := 0;
BEGIN
    
    FOR peleas IN (SELECT xt.*
                    FROM XMLTABLE('/Evento/Peleas/Pelea'
                            PASSING :NEW.datoev
                            COLUMNS 
                            pas1     NUMBER(20) PATH 'Pas1',
                            pas2     NUMBER(20) PATH 'Pas2',
                            ganador  VARCHAR2(10) PATH 'Ganador',
                            tecnica  VARCHAR2(40) PATH 'Tecnica'
                            ) xt) LOOP

        cont := cont + 1;

        IF cont > 5 THEN 
            raise_application_error(-20005, 'Hay más de 5 peleas.');
        END IF;

        IF peleas.pas1 = peleas.pas2 THEN
            raise_application_error(-20001, 'Hay peleador consigo mismo.');
        END IF;

        IF (peleas.ganador != 0 AND peleas.ganador != 1 AND peleas.ganador != 2) THEN
            raise_application_error(-20006, 'El valor del campo ganador solo puede ser 0, 1 o 2.');
        END IF;
        
        IF (peleas.ganador = 0 AND peleas.tecnica IS NOT NULL) THEN
            raise_application_error(-20002, 'Hay empate con técnica');
        END IF;

        IF (peleas.ganador != 0 AND peleas.tecnica IS NULL) THEN
            raise_application_error(-20003, 'Hay ganador sin técnica');
        END IF;


        IF (peleas.ganador != 0 AND peleas.ganador != 1 AND peleas.ganador != 2) THEN
            raise_application_error(-20006, 'El valor del campo ganador solo puede ser 0, 1 o 2.');
        END IF;
        
        
        IF (peleas.ganador != 0 AND peleas.ganador != 1 AND peleas.ganador != 2) THEN
            raise_application_error(-20006, 'El valor del campo ganador solo puede ser 0, 1 o 2.');
        END IF;
        
        IF CHECK_PASSPORT(peleas.pas1) THEN 
            raise_application_error(-20003, 'Pasaporte no encontrado: '||peleas.pas1);
        END IF;

        IF CHECK_PASSPORT(peleas.pas2) THEN 
            raise_application_error(-20003, 'Pasaporte no encontrado: '||peleas.pas2);
        END IF;

    END LOOP;

    IF cont < 1 THEN 
        raise_application_error(-20004, 'Hay menos de una pelea.');
    END IF;

END;
/

-- ==================================================================================================================
-- ===================================================   Punto 2 (75 %)   ===========================================
-- ==================================================================================================================


CREATE TABLE KaratecaPeleador (pasaporte NUMBER(20) PRIMARY KEY NOT NULL,
                            nom VARCHAR2(40) NOT NULL,
                            otronom VARCHAR2(40),
                            nick VARCHAR2(40) NOT NULL,
                            otronick VARCHAR2(40));

CREATE TABLE Pelea (consecutivo NUMBER PRIMARY KEY,
                            pas1 NUMBER(20) NOT NULL,
                            pas2 NUMBER(20) NOT NULL,
                            fecha DATE NOT NULL,
                            ganador NUMBER NOT NULL,
                            tecnica VARCHAR2(40),
                            evento VARCHAR2(40),
                            FOREIGN KEY(pas1) REFERENCES karatecaPeleador (pasaporte),
                            FOREIGN KEY(pas2) REFERENCES karatecaPeleador (pasaporte));


CREATE OR REPLACE PROCEDURE getFromKarateca (pasaport IN NUMBER, nombreout OUT VARCHAR2, nickout OUT VARCHAR2) IS
BEGIN
    FOR person IN (SELECT
        EXTRACTVALUE (datoka, '/Karateca/Nombre') AS nombreKarateca,
        EXTRACTVALUE (datoka, '/Karateca/Nickname') AS nickKarateca
        FROM karateca b WHERE pasaporte = pasaport) LOOP
        nombreout := person.nombreKarateca;
        nickout := person.nickKarateca;
    END LOOP;
END;
/

CREATE OR REPLACE PROCEDURE getFromPeleador(pasaport IN NUMBER, nombreout OUT VARCHAR2, nickout OUT VARCHAR2) IS
BEGIN
    FOR person IN (SELECT 
        JSON_VALUE(datope, '$.nombre') AS nombrePeleador,
        JSON_VALUE(datope, '$.nickname') AS nickPeleador        
        FROM peleador p WHERE pasaporte = pasaport) LOOP
        nombreout := person.nombrePeleador;
        nickout := person.nickPeleador;
    END LOOP;
END;
/

-- SI SE VUELVE A CORRER EL SCRIPT PARA LLENAR LA TABLA  ESTA FUNCIÓN AYUDA A QUE SE INSERTEN ÚNICAMENTE 
-- LOS NUEVOS REGISTROS
CREATE OR REPLACE FUNCTION CHECK_KARATECAPELEADOR(pasaport1 NUMBER, pasaport2 NUMBER)
    RETURN BOOLEAN IS
    BEGIN
        FOR query IN (SELECT * FROM KaratecaPeleador WHERE pasaporte = pasaport1 OR pasaporte = pasaport2) LOOP
          RETURN FALSE;
        END LOOP;
        RETURN TRUE;
    END;
/
----------------------------------------------------------------------------------------
-------------------    PARA LLENAR LA TABLA KARATECA-PELEADOR     ----------------------
----------------------------------------------------------------------------------------
DECLARE
    PASSPORT NUMBER(20);
    NOM VARCHAR2(40);
    OTRONOM VARCHAR2(40);
    NICK VARCHAR2(40);
    OTRONICK VARCHAR2(40);
BEGIN 
    FOR passports IN (SELECT K.PASAPORTE AS KARATECA,
                             P.PASAPORTE AS PELEADOR 
                        FROM KARATECA K FULL JOIN PELEADOR P ON K.PASAPORTE = P.PASAPORTE) LOOP
        
        IF CHECK_KARATECAPELEADOR(passports.karateca, passports.peleador) THEN
            IF (passports.karateca IS NOT NULL AND passports.peleador IS NOT NULL) THEN
                getFromKarateca(passports.karateca, NOM, NICK);
                getFromPeleador(passports.peleador, OTRONOM, OTRONICK);
                IF (NOM = OTRONOM) THEN
                    OTRONOM := NULL;
                END IF;

                IF (NICK = OTRONICK) THEN
                    OTRONICK := NULL;
                END IF;
                PASSPORT := passports.karateca;
            ELSIF (passports.peleador IS NULL) THEN
                getFromKarateca(passports.karateca, NOM, NICK);
                PASSPORT := passports.karateca;
            ELSE
                getFromPeleador(passports.peleador, NOM, NICK);
                PASSPORT := passports.peleador;
            END IF;
            
            INSERT INTO KaratecaPeleador VALUES (PASSPORT, NOM, OTRONOM, NICK, OTRONICK);
        END IF;

        NOM := NULL;
        OTRONOM := NULL;
        NICK := NULL;
        OTRONICK := NULL;
    END LOOP;
END;
/

----------------------------------------------------------------------------------------
-------------------------        LLENADO DE LA TABLA PELEA     -------------------------
----------------------------------------------------------------------------------------

---- SECUENCIA PARA EL AUTOINCREMENTO
CREATE SEQUENCE CONSECUTIVOS MINVALUE 1 START WITH 1
    INCREMENT BY 1 CACHE 20;

---- FUNCION PARA EVITAR COLISIONES EN LA INSERCIÓN
CREATE OR REPLACE FUNCTION CHECK_PELEA(PASPORT1 NUMBER, PASPORT2 NUMBER, FCHA DATE, TEC VARCHAR2, EVEN VARCHAR2)
    RETURN BOOLEAN IS
    BEGIN
        FOR query IN (SELECT * FROM pelea P
                    WHERE ((P.PAS1 = PASPORT1 AND P.PAS2 = PASPORT2) 
                        OR (P.PAS1 = PASPORT2 AND P.PAS2 = PASPORT1)) AND (P.FECHA = FCHA) 
                        AND ((P.TECNICA IS NOT NULL AND P.TECNICA = TEC) OR (P.TECNICA IS NULL AND TEC IS NULL))
                        AND ((P.EVENTO IS NOT NULL AND P.EVENTO = EVEN) OR (P.EVENTO IS NULL AND EVEN IS NULL))) LOOP
          RETURN FALSE;
        END LOOP;
        RETURN TRUE; 
    END;
/

---- PROCEDIMIENTO QUE LLENA LA TABLA
BEGIN
    FOR peleas IN (SELECT xt.*, EXTRACTVALUE (datoev, '/Evento/Nombre') as evento,
                EXTRACTVALUE (datoev, '/Evento/Fecha') as fecha
                    FROM evento e, XMLTABLE('/Evento/Peleas/Pelea'
                            PASSING e.datoev
                            COLUMNS 
                            pas1     NUMBER(20) PATH 'Pas1',
                            pas2     NUMBER(20) PATH 'Pas2',
                            ganador  VARCHAR2(10) PATH 'Ganador',
                            tecnica  VARCHAR2(40) PATH 'Tecnica'
                            ) xt) LOOP

            IF CHECK_PELEA(peleas.pas1, peleas.pas2, TO_DATE(peleas.fecha, 'DD/MM/YYYY'), peleas.tecnica, peleas.evento) THEN
                INSERT INTO PELEA VALUES 
                (CONSECUTIVOS.NEXTVAL, peleas.pas1, peleas.pas2, TO_DATE(peleas.fecha, 'DD/MM/YYYY'), peleas.ganador, peleas.tecnica, peleas.evento);
            END IF;
    END LOOP;

    FOR peleas2 IN (SELECT p.pasaporte as pas1, xt.*
                    FROM peleador p, JSON_TABLE(datope, '$.peleas[*]'
                            COLUMNS (
                            "PAS2"  NUMBER(20) PATH '$.pasrival',
                            "FECHA"     VARCHAR2(20) PATH '$.fecha',
                            "GANADOR"  NUMBER(10) PATH '$.ganador',
                            "TECNICA"  VARCHAR2(40) PATH '$.tecnica',
                            "EVENTO"  VARCHAR2(40) PATH '$.evento'
                            )) xt) LOOP

            IF CHECK_PELEA(peleas2.pas1, peleas2.pas2, TO_DATE(peleas2.fecha, 'DD/MM/YYYY'), peleas2.tecnica, peleas2.evento) THEN
                INSERT INTO PELEA VALUES 
                (CONSECUTIVOS.NEXTVAL, peleas2.pas1, peleas2.pas2, TO_DATE(peleas2.fecha, 'DD/MM/YYYY'), peleas2.ganador, peleas2.tecnica, peleas2.evento);
            END IF;
    END LOOP;
END;
/