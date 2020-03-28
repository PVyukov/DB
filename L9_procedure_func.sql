-- 1. Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток.
--    С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать фразу "Добрый день",
--    с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".

DELIMITER //

DROP FUNCTION IF EXISTS hello//
CREATE FUNCTION hello()
RETURNS VARCHAR(20) NO SQL -- Вместо DETERMINISTIC (результат кешируется и при вызове с одними и теми же папраметрами возвращает сохранненое значение в кеше) можно использовать NO SQL (значит даные не читаются из таблиц и каждый раз возвращаемое значение будет высчитываться заново)
BEGIN
  DECLARE str VARCHAR(20);
  DECLARE var INT;
  SET var = HOUR(CURRENT_TIME());
   IF(6 < var and var < 11) THEN 
   		SET str = "Доброе утро";
   ELSEIF (12 < var and var < 17) THEN 
   		SET str = "Добрый день";
   ELSEIF (18 < var and var < 24) THEN 
   		SET str = "Добрый вечер";
   ELSE 
   		SET str =  "Доброй ночи";
   END IF;
   RETURN str; 
END//


-- 2. В таблице products есть два текстовых поля: name с названием товара и description с его описанием. Допустимо присутствие обоих
--    полей или одно из них. Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема. Используя триггеры, добейтесь
--    того, чтобы одно из этих полей или оба поля были заполнены. При попытке присвоить полям NULL-значение необходимо отменить операцию.
DROP TRIGGER IF EXISTS check//
CREATE TRIGGER check BEFORE INSERT ON products
FOR EACH ROW
BEGIN
  DECLARE name_var, description_var VARCHAR(10) ;
  SET name_var = "Undefind name"
  SET description_var = "Undefind description"
  SET NEW.name = COALESCE (NEW.name, name_var);
  SET NEW.description = COALESCE (NEW.description, description_var);
END //


-- правильный вариант
DELIMITER //

CREATE TRIGGER validate_name_description_insert BEFORE INSERT ON products
FOR EACH ROW BEGIN
  IF NEW.name IS NULL AND NEW.description IS NULL THEN
    SIGNAL SQLSTATE '45000'  -- вызвать ошибку
    SET MESSAGE_TEXT = 'Both name and description are NULL'; -- текст ошибки
  END IF;
END//

-- 3. (по желанию) Напишите хранимую функцию для вычисления произвольного числа Фибоначчи. Числами Фибоначчи называется последовательность 
--    в которой число равно сумме двух предыдущих чисел. Вызов функции FIBONACCI(10) должен возвращать число 55.
DELIMITER //

CREATE FUNCTION FIBONACCI(num INT)
RETURNS INT DETERMINISTIC -- всегду получаем одно и тоже значение при запуске с тем же ургкментом (num)
BEGIN
  DECLARE fs DOUBLE;
  SET fs = SQRT(5);

  RETURN (POW((1 + fs) / 2.0, num) + POW((1 - fs) / 2.0, num)) / fs;
END//

SELECT FIBONACCI(10)//
