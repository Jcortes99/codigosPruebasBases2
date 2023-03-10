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
              mi_w.d.EXTRACT('/*').getStringVal() || 
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