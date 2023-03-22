-- Database tests.
-- By Jairo Cortes - jcortesro99@gmail.com


INSERT INTO karateca VALUES (56, XMLTYPE('<Karateca>
<Nombre>Paula Abdul</Nombre>
<Nickname>Knocked Out</Nickname>
</Karateca>'));


CREATE TABLE karateca(pasaporte NUMBER(20) PRIMARY KEY, datoka XMLTYPE);

CREATE USER jairo IDENTIFIED BY hotmail;
GRANT CONNECT, RESOURCE TO jairo;
GRANT CREATE ANY TABLE TO jairo;
GRANT CREATE ANY PROCEDURE TO jairo;
GRANT CREATE ANY VIEW TO jairo;
ALTER USER jairo QUOTA UNLIMITED ON USERS; 



INSERT INTO karateca VALUES (55, XMLTYPE('<Karateca> <Nombre>Paula Abdul</Nombre><Nickname>Knocked Out</Nickname></Karateca>'));

DECLARE
fi emp.fecha_ing%TYPE;
nom VARCHAR2(20) := INITCAP('carmen electra');
BEGIN
fi := ADD_MONTHS(SYSDATE,-14);
INSERT INTO emp 
VALUES (4327, 
    SUBSTR(nom,1,7),
    fi,
    10000
);
END;
/

select table_name from user_tables;


DECLARE
    nom emp.nom%TYPE;
    sue emp.sueldo%TYPE;
    cuantos NUMBER(8);
BEGIN
    SELECT nom, sueldo INTO nom, sue
    FROM emp;
    DBMS_OUTPUT.PUT_LINE('El empleado ' || nom || ' tiene sueldo ' || sue);
    SELECT COUNT(*) INTO cuantos 
    FROM emp;
DBMS_OUTPUT.PUT_LINE('Total empleados ' || cuantos);
END;
/


DECLARE
    CURSOR ord_c IS --Se declara el cursor
    SELECT cod, dep FROM emp ORDER BY dep;
BEGIN
    FOR mi_e IN ord_c LOOP
        DBMS_OUTPUT.PUT_LINE(mi_e.cod || ' ' || mi_e.dep);
    END LOOP;
    -- DBMS_OUTPUT.PUT_LINE('Total: ' || ord_c%ROWCOUNT); ord_c is an error because is not open.
END;
/


DECLARE
suma NUMBER(8) := 0;
BEGIN
 FOR mi_w IN (SELECT ty.*,            
              EXTRACTVALUE(d,'/Warehouse/@whNo') AS wh,
              EXTRACTVALUE(d,'/Warehouse/Building') AS bu
              FROM bodega ty) LOOP
              DBMS_OUTPUT.PUT_LINE(mi_w.id || CHR(10) || 
              mi_w.d.EXTRACT('/*').                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              || 
              mi_w.fecha || ' ' || mi_w.nombre);
     suma := suma + mi_w.wh;
 END LOOP;
DBMS_OUTPUT.PUT_LINE('Total: ' || suma);
END;
/

SELECT depjson.dep_data.empleados FROM depjson;


DECLARE
mijson JSON;
BEGIN
SELECT dep_data INTO mijson
FROM depjson;
DBMS_OUTPUT.PUT_LINE(JSON_SERIALIZE(mijson));
END;
/


SELECT DBMS_XMLGEN.GETXML('SELECT * FROM evento') docxml
FROM dual; 

--===========================================================================================================================================
--====================================   Codigo funcional para la consulta del XML de evento    =============================================
--===========================================================================================================================================
DECLARE
-- suma NUMBER(8) := 0;
BEGIN
    FOR mi_w IN (SELECT b.*,            
                EXTRACTVALUE(datoev,'/Evento/Fecha') AS fecha,
                EXTRACTVALUE(datoev,'/Evento/Nombre') AS nombre
                FROM evento b) LOOP
    DBMS_OUTPUT.PUT_LINE(mi_w.code || CHR(10) || 
            mi_w.datoev.EXTRACT('/*').getStringVal() || 
            mi_w.fecha || ' ' || mi_w.nombre);
    --  suma := suma + mi_w.fecha;
END LOOP;
-- DBMS_OUTPUT.PUT_LINE('Total: ' || suma);
END;
/
--===========================================================================================================================================
--====================================   Codigo funcional para la consulta del XML de evento    =============================================
--===========================================================================================================================================

SELECT cod, sueldo,
    LAG(sueldo,2) OVER 
    (ORDER BY sueldo, cod) AS ant
FROM emp
ORDER BY sueldo, cod;


CREATE TABLE apuesta(cod NUMBER(8) PRIMARY KEY, 
                    cant NUMBER(8) NOT NULL);

DECLARE
    cod_apta apuesta.cod%TYPE; 
    nro_ale apuesta.cant%TYPE;
BEGIN
    FOR i IN 1..20 LOOP 
    BEGIN
        cod_apta := ABS(MOD(DBMS_RANDOM.RANDOM,10));
        nro_ale := ABS(MOD(DBMS_RANDOM.RANDOM,20));
        INSERT INTO apuesta VALUES(cod_apta, nro_ale);
        EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN 
            UPDATE apuesta SET cant = cant + nro_ale 
            WHERE cod = cod_apta;
    END;
    END LOOP;
END;
/




-- =========================================================================================================================================================================================
-- =========================================================================================================================================================================================
-- =======================================================      Pruebas punto 2      ===========================================================================
-- =========================================================================================================================================================================================
-- =========================================================================================================================================================================================


CREATE TABLE KaratecaPeleador (pasaporte NUMBER PRIMARY KEY NOT NULL,
                            nom VARCHAR2(256) NOT NULL,
                            otronom VARCHAR2(256),
                            nick VARCHAR2(256) NOT NULL,
                            otronick VARCHAR2(256));

CREATE TABLE Pelea (consecutivo INTEGER GENERATED BY DEFAULT ON NULL AS IDENTITY,
                            pas1 NUMBER NOT NULL,
                            pas2 NUMBER NOT NULL,
                            fecha DATE NOT NULL,
                            ganador NUMBER(1) NOT NULL,
                            tecnica VARCHAR2(256),
                            evento VARCHAR2(256),
                            PRIMARY KEY(consecutivo),
                            FOREIGN KEY(pas1) REFERENCES karatecaPeleador (pasaporte),
                            FOREIGN KEY(pas2) REFERENCES karatecaPeleador (pasaporte));

-- ==================================================================================================================
-- ===================================================   Code task2    ==============================================
-- ==================================================================================================================


CREATE TABLE prueba (id NUMBER(2), eso VARCHAR2(1000), PRIMARY KEY(id));

-- stored procedure for get attibutes from karateca

CREATE OR REPLACE PROCEDURE tablemerge IS
    nombre VARCHAR2(256);
    nick VARCHAR2(256);
BEGIN
    prueba2(29, nombre, nick);
END;
/

CREATE OR REPLACE PROCEDURE getkarateca (pasaport IN karateca.pasaporte%TYPE, nombreout OUT VARCHAR2, nickout OUT VARCHAR2) IS
    cadena VARCHAR2(1000);
BEGIN
    FOR persona IN (SELECT b.*,
        EXTRACTVALUE (datoka, '/Karateca/Nombre') AS nombreKarateca,
        EXTRACTVALUE (datoka, '/Karateca/Nickname') AS nickKarateca
        FROM karateca b WHERE pasaporte = pasaport) LOOP
        cadena := (persona.nombreKarateca || ' ' || persona.nickKarateca);
        nombreout := persona.nombreKarateca;
        nickout := persona.nickKarateca;
    END LOOP;
END;
/


CREATE OR REPLACE PROCEDURE getevento (codein IN evento.code%TYPE, fecha OUT DATE, pas1 OUT VARCHAR2, 
                                    pas2 OUT karateca.pasaporte%TYPE, winner OUT karateca.pasaporte%TYPE, tecnica OUT VARCHAR2, nombre OUT VARCHAR2) IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Entro a getEvento');
    FOR evento IN (SELECT b.*,
        EXTRACTVALUE (datoev, '/Evento/Fecha') AS fechaE,
        EXTRACTVALUE (datoev, '/Evento/Nombre') AS nombreE,
        EXTRACT (datoev, '/Evento/Peleas').getStringVal() AS pas1E
        FROM evento b WHERE code = codein) LOOP
        fecha:= TO_DATE(evento.fechaE,'DD/MM/YY');
        nombre := evento.nombreE;
        pas1 := evento.pas1E;
        DBMS_OUTPUT.PUT_LINE('El codigo es: ' || codein);
        DBMS_OUTPUT.PUT_LINE('La fecha es: ' || fecha);
        DBMS_OUTPUT.PUT_LINE('El nombre es: ' || nombre);
        DBMS_OUTPUT.PUT_LINE('El segundo es: ' || pas2);
        -- FOR i IN (SELECT EXTRACTVALUE (datoev, '/Evento/Fecha/Pleas'))
    END LOOP;
END;
/

CREATE OR REPLACE PROCEDURE prueba4 IS
    -- codigo NUMBER;
    fecha DATE;
    pas1 VARCHAR2(256);
    pas2 karateca.pasaporte%TYPE;
    winner karateca.pasaporte%TYPE;
    tecnica VARCHAR2(256);
    nombre VARCHAR2(256);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Ejecuto prueba4');
    getevento(990, fecha, pas1, pas2, winner, tecnica, nombre);
END;
/



FOR pelea IN (SELECT xt.*
                    FROM XMLTABLE('/Evento/Peleas/Pelea'
                            PASSING :NEW.datoev
                            COLUMNS 
                            pas1     NUMBER(20) PATH 'Pas1',
                            pas2     NUMBER(20) PATH 'Pas2',
                            ganador  VARCHAR2(100) PATH 'Ganador',
                            tecnica  VARCHAR2(100) PATH 'Tecnica'
                            ) xt) LOOP



CREATE OR REPLACE PROCEDURE getevento IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Entro a getEvento');
    FOR pelea IN (SELECT xt.*
                    FROM evento e, XMLTABLE('/Evento/Peleas/Pelea'
                            PASSING e.datoev
                            COLUMNS 
                            pas1     NUMBER(20) PATH 'Pas1',
                            pas2     NUMBER(20) PATH 'Pas2',
                            ganador  VARCHAR2(100) PATH 'Ganador',
                            tecnica  VARCHAR2(100) PATH 'Tecnica'
                            ) xt) LOOP
        DBMS_OUTPUT.PUT_LINE(pas1);
    END LOOP;
END;
/