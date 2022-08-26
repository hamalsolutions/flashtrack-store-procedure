CREATE DEFINER=`root`@`localhost` PROCEDURE `set_records_to_reprint`(IN numOrder VARCHAR(50))
BEGIN
   SET @query = CONCAT("UPDATE PRINT SET PROD_STATUS='4' WHERE ORDER_ID='",numOrder,"';");
   PREPARE stmt FROM @query;
   EXECUTE stmt;
   SET @query = CONCAT("SELECT * FROM PRINT WHERE ORDER_ID='",numOrder,"'");
   PREPARE stmt FROM @query;
   EXECUTE stmt;
   DEALLOCATE PREPARE stmt;
END