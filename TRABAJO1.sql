
-- PRIMER PUNTO TRIGGER CON EXCEPTIONS (25%)

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
    cont NUMBER(2) := 0;
BEGIN
    
    FOR pelea IN (SELECT xt.*
                    FROM XMLTABLE('/Evento/Peleas/Pelea'
                            PASSING :NEW.datoev
                            COLUMNS 
                            pas1     NUMBER(20) PATH 'Pas1',
                            pas2     NUMBER(20) PATH 'Pas2',
                            ganador  VARCHAR2(100) PATH 'Ganador',
                            tecnica  VARCHAR2(100) PATH 'Tecnica'
                            ) xt) LOOP

        cont := cont + 1;

        IF cont > 5 THEN 
            raise_application_error(-20005, 'Hay más de 5 peleas.');
        END IF;

        IF pelea.pas1 = pelea.pas2 THEN
            raise_application_error(-20001, 'Hay peleador consigo mismo.');
        END IF;

        IF (pelea.ganador = 0 AND pelea.tecnica IS NOT NULL) THEN
            raise_application_error(-20002, 'Hay empate con técnica');
        END IF;

        IF (pelea.ganador != 0 AND pelea.tecnica IS NULL) THEN
            raise_application_error(-20003, 'Hay ganador sin técnica');
        END IF;

        IF (pelea.ganador != 0 AND pelea.ganador != 1 AND pelea.ganador = 2) THEN
            raise_application_error(-20006, 'El valor del campo ganador solo puede ser 0, 1 o 2.');
        END IF;
        
        IF CHECK_PASSPORT(pelea.pas1) THEN 
            raise_application_error(-20003, 'Pasaporte no encontrado: '||pelea.pas1);
        END IF;

        IF CHECK_PASSPORT(pelea.pas2) THEN 
            raise_application_error(-20003, 'Pasaporte no encontrado: '||pelea.pas2);
        END IF;

    END LOOP;

    IF cont < 1 THEN 
        raise_application_error(-20004, 'Hay menos de una pelea.');
    END IF;

END;
/

-- Se debe de usar el Rise application error para parar la ejecución de la inserción, si se hace con excepciones propias y se catchean de igual forma se ejecuta el insert.

delete from evento where code=991;
                 