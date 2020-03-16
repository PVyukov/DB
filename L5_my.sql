-- “Операторы, фильтрация, сортировка и ограничение”

-- 1) Пусть в таблице users поля created_at и updated_at оказались незаполненными. 
--    Заполните их текущими датой и временем.

UPDATE users SET  created_at= NOW() WHERE created_at IS NULL;
UPDATE users SET  updated_at= NOW() WHERE updated_at IS NULL;

-- 2)Таблица users была неудачно спроектирована. Записи created_at и updated_at были 
--   заданы типом VARCHAR и в них долгое время помещались значения в формате "20.10.2017 8:10".
--   Необходимо преобразовать поля к типу DATETIME, сохранив введеные ранее значения.

CREATE TABLE new_users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(10),
  created_at DATETIME,
  updated_at DATETIME
);

/* мой вариант
INSERT INTO new_users SELECT id, name, STR_TO_DATE(created_at, '%d.%m.%Y %H:%i'), STR_TO_DATE(updated_at, '%d.%m.%Y %H:%i')  FROM users;
DROP TABLE users;
ALTER TABLE new_users RENAME users;
*/

-- правильный вариант
UPDATE users SET created_at = STR_TO_DATE(created_at, '%d.%m.%Y %H:%i'), updated_at = STR_TO_DATE(updated_at, '%d.%m.%Y %H:%i');
ALTER TABLE users CHANGE created_at created_at DATETIME DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE users CHANGE updated_at updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

-- 3) В таблице складских запасов storehouses_products в поле value могут встречаться самые
--    разные цифры: 0, если товар закончился и выше нуля, если на складе имеются запасы.
--    Необходимо отсортировать записи таким образом, чтобы они выводились в порядке увеличения
--    значения value. Однако, нулевые запасы должны выводиться в конце, после всех записей.

CREATE DATABASE tmp;
DROP TABLE IF EXISTS storehouses_products;
CREATE TABLE storehouses_products (
  id SERIAL PRIMARY KEY,
  value INT UNSIGNED
);

INSERT INTO storehouses_products (value) VALUES
 (0),
 (3),
 (0),
 (5),
 (2),
 (1);

SELECT 
 *
-- чтобы не появился ненужный лишний стоблец, данное условие нужно перенсти в ORDER BY  IF (value=0, 1, 0) as is_zero
FROM storehouses_products 
ORDER by   IF (value=0, 1, 0) , value;
 
 
-- 4) (по желанию) Из таблицы users необходимо извлечь пользователей, родившихся в августе и мае.
--    Месяцы заданы в виде списка английских названий ('may', 'august')
ALTER TABLE users ADD COLUMN month_birthday VARCHAR (10);
UPDATE  users	SET  month_birthday = 'may' ;
INSERT INTO users 
  (name, month_birthday)
VALUES
  ('Olga', 'june'),  
  ('Pavel','june'), 
  ('Roman','august'),
  ('Mihail', 'may');

-- 1 вариант
 SELECT * FROM users WHERE month_birthday RLIKE 'may|august';
-- 2 вариант
 SELECT * FROM users WHERE month_birthday IN ('may', 'august');

-- 5) (по желанию) Из таблицы catalogs извлекаются записи при помощи запроса.
--    SELECT * FROM catalogs WHERE id IN (5, 1, 2); Отсортируйте записи в порядке, заданном в списке IN.
SELECT * FROM users WHERE id IN (5, 1, 2) GROUP BY id ORDER BY FIELD  (id, 5, 1, 2);

-- “Агрегация данных”
-- 1) Подсчитайте средний возраст пользователей в таблице users
SELECT 
  AVG ((TO_DAYS(NOW())-TO_DAYS(created_at))/365.25) AS avg_age
-- целое значение:AVG (TIMESTAMPDIFF(YEAR, created_at, NOW())) AS avg_age
 FROM users;
 
-- 2) Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели.
--    Следует учесть, что необходимы дни недели текущего года, а не года рождения.
SELECT
  COUNT(*),
  DATE_FORMAT(CONCAT('2020-', DATE_FORMAT(created_at, '%m-%d')), '%W') AS day_of_week
FROM
  users
GROUP BY day_of_week;

-- 3) (по желанию) Подсчитайте произведение чисел в столбце таблицы
SELECT 
 EXP(SUM(LOG(id))) as production
FROM 
 users;
GROUP BY id;