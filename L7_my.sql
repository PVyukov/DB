USE shop;
DESCRIBE TABLE users;

SELECT * FROM users LIMIT 10;

SELECT * FROM orders 



-- 1.Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.
INSERT INTO orders
  (user_id) 
VALUES 
  (2), (4), (2), (1), (3);


SELECT name
FROM users
WHERE id IN (
  SELECT user_id
  FROM orders
  GROUP BY user_id
);

 
-- 2.Выведите список товаров products и разделов catalogs, который соответствует товару.
SELECT p.name, p.description, c.name AS catalogs 
FROM products AS p
JOIN
catalogs AS c
WHERE p.catalog_id = c.id
AND  p.name LIKE 'INTEL%';

-- 3.(по желанию) Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name). Поля from, to и label содержат английские названия городов, поле name — русское. Выведите список рейсов flights с русскими названиями городов.

SELECT f.*, c.name AS to_name 
FROM flights AS f
JOIN
cities AS c
WHERE f.to = c.label;