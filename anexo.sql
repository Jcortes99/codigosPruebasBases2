select table_name from user_tables order by table_name;

DROP TABLE karateca;
CREATE TABLE karateca(
  pasaporte NUMBER(20) PRIMARY KEY,
  datoka XMLTYPE);

INSERT INTO karateca VALUES 
(55, XMLTYPE('<Karateca>  
               <Nombre>Paula Abdul</Nombre>
               <Nickname>Knocked Out</Nickname>
             </Karateca>'));

INSERT INTO karateca VALUES 
(66, XMLTYPE('<Karateca>  
               <Nombre>Rhian Teasdale</Nombre>
               <Nickname>Wet Leg</Nickname>
             </Karateca>'));

INSERT INTO karateca VALUES 
(29, XMLTYPE('<Karateca>  
               <Nombre>Ariana Grande</Nombre>
               <Nickname>Mor</Nickname>
             </Karateca>'));

DROP TABLE evento;
CREATE TABLE evento(
  code NUMBER(8) PRIMARY KEY,
  datoev XMLTYPE);

INSERT INTO evento VALUES 
(991, XMLTYPE('<Evento>  
               <Fecha>11/12/2024</Fecha>
               <Nombre>Artes marciales de Namek</Nombre>
               <Peleas>
                 <Pelea>
                 <Pas1>29</Pas1>
                 <Pas2>66</Pas2>
                 <Ganador>1</Ganador>
                 <Tecnica>Kame hame ha</Tecnica>
                 </Pelea>
               </Peleas>
             </Evento>'));

------------------------------------

DROP TABLE peleador;
CREATE TABLE peleador(
  pasaporte  NUMBER(20) PRIMARY KEY,
  datope JSON NOT NULL
);

-- FOR ORACLE LIVE
DROP TABLE peleador;
CREATE TABLE peleador(
  pasaporte  NUMBER(20) PRIMARY KEY,
  datope BLOB NOT NULL
);

alter table peleador 
	add constraint datope
	check (datope is json)

---------------------------------------------------------

INSERT INTO peleador VALUES (55,
'{
  "nombre": "Paula Adul",
  "nickname": "Knocked out",
  "peleas": [
    {
      "fecha": "25/01/2023",
      "pasrival": 500,
      "ganador": 0
    },
    {
      "fecha": "26/01/2023",
      "pasrival": "666",
      "ganador": 1,
      "tecnica": "Llave del dragon"     
    }
  ]
}'
);

INSERT INTO peleador VALUES (500,
'{
  "nombre": "Cathy Dennis",
  "nickname": "Touch me",
  "peleas": [
    {
      "fecha": "25/01/2023",
      "pasrival": 55,
      "ganador": 0
    }
  ]
}'
);

INSERT INTO peleador VALUES (666,
'{
  "nombre": "Charli XCX",
  "nickname": "Boom Clap",
  "peleas": [
    {
      "fecha": "26/01/2023",
      "pasrival": 55,
      "ganador": 2,
      "tecnica": "Llave del dragon"  
    }
  ]
}'
);

--Note que en la base de datos JSON hay cierta redundancia en cuanto a las peleas:
--La información de cada pelea se repite dos veces (una vez en cada peleador), 
--pero en la base de datos relacional la pelea se almacenará una sola vez. 
--Se asegura que los datos de las peleas son consistentes en cuanto a contrincantes 
--(por ejemplo, que existan sus pasaportes), fecha, resultado y técnica.






