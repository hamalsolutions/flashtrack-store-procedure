CREATE DEFINER=`root`@`localhost` PROCEDURE `getRFIDrecords2`(IN numOrder VARCHAR(50),IN imprimir INT)
BEGIN
DECLARE fin INT DEFAULT 0;
DECLARE var VARCHAR(50);
DECLARE CADENA VARCHAR (500) DEFAULT '';
DECLARE QUERYT VARCHAR (1000) DEFAULT '';
DECLARE nombreCursor CURSOR FOR SELECT SUBSTRING_INDEX(TRIM(vals),':',1) FROM temp_string;
DECLARE CONTINUE HANDLER FOR  NOT FOUND SET fin=1;

SET @COL = CONCAT("SELECT @sel := REPLACE(REPLACE(REPLACE(DATOS,'\"',''),'{',''),'}','') FROM PRINT where ORDER_ID='",numOrder,"' LIMIT 1;");
PREPARE stmt FROM @COL;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
CALL splitString(@sel,',');
/************************************* IF imprimir=1 *************************************/
IF(imprimir=1) THEN
OPEN nombreCursor;
ciclo_loop: LOOP
FETCH nombreCursor INTO var;
IF (fin=1) THEN
  LEAVE ciclo_loop;
END IF;
/*----------------------------------------------------------------------*/
    SET CADENA = CONCAT(CADENA," ",var," VARCHAR(50) PATH '$.",var,"'," );
/*----------------------------------------------------------------------*/
end LOOP ciclo_loop ;
CLOSE nombreCursor;
SET CADENA = SUBSTRING(CADENA,     1,    CHAR_LENGTH(CADENA) - 1);
SET @QUERYT = CONCAT("SELECT PRINT.ID as REG,r.* FROM PRINT, JSON_TABLE(DATOS,'$'COLUMNS (",CADENA,")) AS r where PROD_STATUS='1' and ORDER_ID='",numOrder,"' ORDER BY ID;");
PREPARE stmt FROM @QUERYT;
EXECUTE stmt;
SET @QUERYT = CONCAT("UPDATE PRINT SET PROD_STATUS='2' WHERE PROD_STATUS='1' and ORDER_ID='",numOrder,"' ORDER BY ID;");
PREPARE stmt FROM @QUERYT;
EXECUTE stmt;
SET @QUERYT = CONCAT("UPDATE PRINT SET PROD_STATUS='1' WHERE PROD_STATUS='0' and ORDER_ID='",numOrder,"' ORDER BY ID LIMIT 2000;");
PREPARE stmt FROM @QUERYT;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
END IF;
/****************************************** IF imprimir=0 ********************************/
IF(imprimir=0) THEN
OPEN nombreCursor;
ciclo_loop: LOOP
FETCH nombreCursor INTO var;
IF (fin=1) THEN
  LEAVE ciclo_loop;
END IF;
/*----------------------------------------------------------------------*/
 IF(var!='EPC_1'and var!='EPC_2') THEN
    SET CADENA = CONCAT(CADENA," ",var," VARCHAR(50) PATH '$.",var,"'," );
 END IF;   
/*----------------------------------------------------------------------*/
end LOOP ciclo_loop ;
CLOSE nombreCursor;
SET CADENA = SUBSTRING(CADENA,     1,    CHAR_LENGTH(CADENA) - 1);
SET @QUERYT = CONCAT("SELECT PRINT.ID as REG,r.* FROM PRINT, JSON_TABLE(DATOS,'$'COLUMNS (",CADENA,")) AS r where PROD_STATUS='1' and ORDER_ID='",numOrder,"' ORDER BY ID LIMIT 3;");
PREPARE stmt FROM @QUERYT;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
END IF;
END