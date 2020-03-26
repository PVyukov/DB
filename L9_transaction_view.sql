-- 1. В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных.
--    Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.

START TRANSACTION;
INSERT INTO sample.users VALUES 
  (SELECT * FROM shop.users WHERE shop.users.id = 1);
DELETE FROM shop.users WHERE shop.users.id = 1 ;
COMMIT;

-- 2.Создайте представление, которое выводит название name товарной позиции из таблицы products и
--   соответствующее название каталога name из таблицы catalogs.
CREATE VIEW products_catalogs AS
  SELECT p.name AS name, c.name AS current_catalog
  FROM products AS p 
  LEFT JOIN catalogs AS c
  ON p.catalog_id = c.id;
  
SELECT * FROM products_catalogs;
-- 3.(по желанию) Пусть имеется таблица с календарным полем created_at. В ней размещены разряженые календарные
--  записи за август 2018 года '2018-08-01', '2016-08-04', '2018-08-16' и 2018-08-17. Составьте запрос, 
--  который выводит полный список дат за август, выставляя в соседнем поле значение 1, если дата присутствует
--  в исходном таблице и 0, если она отсутствует.

-- 4. (по желанию) Пусть имеется любая таблица с календарным полем created_at. Создайте запрос,
--     который удаляет устаревшие записи из таблицы, оставляя только 5 самых свежих записей.
