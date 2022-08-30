-- create a trigger that gets fired when we delete a payment

USE sql_invoicing; 

CREATE TABLE payments_audit
(
	client_id 		INT 			NOT NULL, 
    date 			DATE 			NOT NULL,
    amount 			DECIMAL(9, 2) 	NOT NULL,
    action_type 	VARCHAR(50) 	NOT NULL,
    action_date 	DATETIME 		NOT NULL
)
; 

DROP TRIGGER IF EXISTS payments_after_delete
DELIMITER $$
	CREATE TRIGGER payments_after_delete
	AFTER DELETE ON payments
	FOR EACH ROW
	BEGIN 
 UPDATE invoices
 SET payment_total = payment_total - OLD.amount
 WHERE invoice_id = OLD.invoice_id ; 
 
 INSERT INTO payment_audit 
 VALUES (OLD.client_id, OLD.date, OLD.amount,'delete', NOW()); 
 
END $$
DELIMITER ;



DROP TRIGGER IF EXISTS payments_after_insert
DELIMITER $$
CREATE TRIGGER payments_after_insert
AFTER INSERT ON payments
FOR EACH ROW
BEGIN 
 UPDATE invoices
 SET payment_total = payment_total + NEW.amount
 WHERE invoice_id = NEW.invoice_id ; 
 
 INSERT INTO payments_audit
 VALUES(NEW.client_id, NEW.date, NEW.amount,'insert',NOW());
 
END $$
DELIMITER ;



INSERT INTO payments
VALUES(Default,5,3,'2019-01-01', 1000, 1) ; 

DELETE FROM payments
WHERE payment_id = 3; 