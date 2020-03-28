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
CREATE TABLE IF NOT EXISTS posts (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255),
  created_at DATE NOT NULL
);

INSERT INTO posts VALUES
(NULL, 'первая запись', '2018-08-01'),
(NULL, 'вторая запись', '2018-08-04'),
(NULL, 'третья запись', '2018-08-16'),
(NULL, 'четвертая запись', '2018-08-17');

CREATE TEMPORARY TABLE last_days (
  day INT
);

INSERT INTO last_days VALUES
(0), (1), (2), (3), (4), (5), (6), (7), (8), (9), (10),
(11), (12), (13), (14), (15), (16), (17), (18), (19), (20),
(21), (22), (23), (24), (25), (26), (27), (28), (29), (30);

SELECT
  DATE(DATE('2018-08-31') - INTERVAL l.day DAY) AS day,
  NOT ISNULL(p.name) AS order_exist
FROM
  last_days AS l
LEFT JOIN
  posts AS p
ON
  DATE(DATE('2018-08-31') - INTERVAL l.day DAY) = p.created_at
ORDER BY
  day;

-- 4. (по желанию) Пусть имеется любая таблица с календарным полем created_at. Создайте запрос,
--     который удаляет устаревшие записи из таблицы, оставляя только 5 самых свежих записей.
DROP TABLE IF EXISTS posts;
CREATE TABLE IF NOT EXISTS posts (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255),
  created_at DATE NOT NULL
);

INSERT INTO posts VALUES
(NULL, 'первая запись', '2018-11-01'),
(NULL, 'вторая запись', '2018-11-02'),
(NULL, 'третья запись', '2018-11-03'),
(NULL, 'четвертая запись', '2018-11-04'),
(NULL, 'пятая запись', '2018-11-05'),
(NULL, 'шестая запись', '2018-11-06'),
(NULL, 'седьмая запись', '2018-11-07'),
(NULL, 'восьмая запись', '2018-11-08'),
(NULL, 'девятая запись', '2018-11-09'),
(NULL, 'десятая запись', '2018-11-10');

DELETE
  posts
FROM
  posts
JOIN
 (SELECT
    created_at
  FROM
    posts
  ORDER BY
    created_at DESC
  LIMIT 5, 1) AS delpst
ON
  posts.created_at <= delpst.created_at;

SELECT * FROM posts;