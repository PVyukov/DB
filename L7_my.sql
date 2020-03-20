USE shop;
DESCRIBE TABLE users;
SELECT * FROM users LIMIT 10;
SELECT * FROM users ;
SELECT * FROM orders ;

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
-- вариант с JOIN
SELECT name
FROM users AS u
JOIN
orders AS o
ON o.user_id=u.id
GROUP BY name; 
-- 2.Выведите список товаров products и разделов catalogs, который соответствует товару.
SELECT 
  p.name, 
  p.description, 
  c.name AS catalogs 
FROM
  products AS p
LEFT JOIN
  catalogs AS c
ON
  p.catalog_id = c.id;

-- 3.(по желанию) Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name). Поля from, to и label содержат английские названия городов, поле name — русское. Выведите список рейсов flights с русскими названиями городов.
-- В результате назачение должны быть только на Русском языке
DROP DATABASE IF EXISTS flight;
CREATE DATABASE flight;
USE flight;
CREATE TABLE flights(
  id serial PRIMARY KEY,
  from_ VARCHAR (10),
  to_ VARCHAR (10)
);

INSERT INTO flights
  (from_, to_)
VALUES
  ('moscow', 'omsk'),
  ('novgorod', 'kazan'),
  ('irkutsk', 'moscow'), 
  ('omsk', 'irkutsk'),
  ('moscow', 'kazan');

CREATE TABLE cities(
  id serial PRIMARY KEY,
  label VARCHAR (10),
  name VARCHAR (10)
);

INSERT INTO cities
  (label, name)
VALUES
  ('moscow', 'москва'),
  ('irkutsk', 'иркутск'), 
  ('novgorod', 'новгород'),
  ('kazan', 'казань'),
  ('omsk', 'омск');

SELECT 
  f.id,
  c.name AS from_name,
  c2.name AS to_name 
FROM flights AS f
  LEFT JOIN cities AS c 
    ON f.from_ = c.label
  LEFT JOIN cities AS c2
    ON f.to_ = c2.label;

   

