CREATE DATABASE paralimpia characterSET utf8 COLLATE utf8_hungarian_ci;


DELIMITER // CREATE FUNCTION versenyszamokszama(
  sportagneve varchar(255)) returns int deterministic BEGINDECLARE db INT;
SELECT Count(*) INTO db
FROM versenyszamok v 
JOIN sportagak s ON v.sportagid = s.id 
WHERE s.sportag = sportagneve;RETURN db;
END // delimiter;


DELIMITER // CREATE PROCEDURE olimpikonversenyszamai(in olimpikonnev varchar(255)) BEGINDECLARE db INT;
SELECT Count(*) INTO db FROM olimpikonok WHERE nev = olimpikonnev;
IF db = 0 then 
SELECT 'Nincs ilyen olimpikon!' AS uzenet;
else 
SELECT v.versenyszam 
FROM eredmenyek e 
JOIN olimpikonok o ON e.olimikonid = o.id 
JOIN versenyszamok v ON e.versenyszamid = v.id 
WHERE o.nev = olimpikonnev;
ENDIF;
END // delimiter;

DELIMITER // CREATE TRIGGER check_eredmeny_before_insert beforeINSERT on eredmenyek for each row BEGIN IF new.helyezes NOT BETWEEN 1 
AND 3 THEN SET new.helyezes = 0;
endIF;
END
// delimiter;


DELIMITER // CREATE TRIGGER check_eredmeny_before_update beforeUPDATE on eredmenyek for each row BEGINIF new.helyezes NOT BETWEEN 1 
AND 3 then 
SET new.helyezes = old.helyezes;
ENDIF;
END // delimiter;



DELIMITER // CREATE TRIGGER cascade_delete_sportagak beforeDELETE on sportagak for each row BEGINDELETE 
FROM eredmenyek 
WHERE 
  versenyszamid IN (SELECT id FROM versenyszamok WHERE sportagid = old.id);
DELETE FROM versenyszamok 
WHERE sportagid = old.id;

END   // delimiter;



DELIMITER // CREATE TRIGGER log_delete_eredmeny 
after DELETE ON eredmenyek FOR each row BEGININSERT INTO naplo (megjegyzes) 
VALUES (Concat('Törölve: ', old.id));
END 

// delimiter;


DELIMITER // CREATE TRIGGER log_update_eredmeny 
after 
UPDATE ON eredmenyek FOR each row BEGINIF old.helyezes <> new.helyezes then INSERT INTO naplo (megjegyzes) 
VALUES 
  
  (concat('Módosítva: id=', new.id, ', új helyezés=', new.helyezes));

ENDIF;
END
// delimiter;
