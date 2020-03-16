-- Урок 6
-- Операторы, фильтрация, сортировка и ограничение


-- Разбор ДЗ

-- Тема Операции, задание 1
-- Пусть в таблице users поля created_at и updated_at оказались незаполненными.
-- Заполните их текущими датой и временем.
DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at DATETIME,
  updated_at DATETIME
) COMMENT = 'Покупатели';

INSERT INTO
  users (name, birthday_at, created_at, updated_at)
VALUES
  ('Геннадий', '1990-10-05', NULL, NULL),
  ('Наталья', '1984-11-12', NULL, NULL),
  ('Александр', '1985-05-20', NULL, NULL),
  ('Сергей', '1988-02-14', NULL, NULL),
  ('Иван', '1998-01-12', NULL, NULL),
  ('Мария', '2006-08-29', NULL, NULL);

UPDATE
  users
SET
  created_at = NOW(),
  updated_at = NOW();
  
  
-- Тема Операции, задание 2
-- Таблица users была неудачно спроектирована.
-- Записи created_at и updated_at были заданы типом VARCHAR и в них долгое время помещались
-- значения в формате "20.10.2017 8:10".
-- Необходимо преобразовать поля к типу DATETIME, сохранив введеные ранее значения.
DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at VARCHAR(255),
  updated_at VARCHAR(255)
) COMMENT = 'Покупатели';

INSERT INTO
  users (name, birthday_at, created_at, updated_at)
VALUES
  ('Геннадий', '1990-10-05', '07.01.2016 12:05', '07.01.2016 12:05'),
  ('Наталья', '1984-11-12', '20.05.2016 16:32', '20.05.2016 16:32'),
  ('Александр', '1985-05-20', '14.08.2016 20:10', '14.08.2016 20:10'),
  ('Сергей', '1988-02-14', '21.10.2016 9:14', '21.10.2016 9:14'),
  ('Иван', '1998-01-12', '15.12.2016 12:45', '15.12.2016 12:45'),
  ('Мария', '2006-08-29', '12.01.2017 8:56', '12.01.2017 8:56');

UPDATE
  users
SET
  created_at = STR_TO_DATE(created_at, '%d.%m.%Y %k:%i'),
  updated_at = STR_TO_DATE(updated_at, '%d.%m.%Y %k:%i');

ALTER TABLE
  users
CHANGE
  created_at created_at DATETIME DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE
  users
CHANGE
  updated_at updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

DESCRIBE users;


-- Тема Операции, задание 3
-- В таблице складских запасов storehouses_products в поле value могут встречаться самые
-- разные цифры: 0, если товар закончился и выше нуля, если на складе имеются запасы.
-- Необходимо отсортировать записи таким образом, чтобы они выводились в порядке увеличения
-- значения value. Однако, нулевые запасы должны выводиться в конце, после всех записей.
DROP TABLE IF EXISTS storehouses_products;
CREATE TABLE storehouses_products (
  id SERIAL PRIMARY KEY,
  storehouse_id INT UNSIGNED,
  product_id INT UNSIGNED,
  value INT UNSIGNED COMMENT 'Запас товарной позиции на складе',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Запасы на складе';

INSERT INTO
  storehouses_products (storehouse_id, product_id, value)
VALUES
  (1, 543, 0),
  (1, 789, 2500),
  (1, 3432, 0),
  (1, 826, 30),
  (1, 719, 500),
  (1, 638, 1);

SELECT
  *
FROM
  storehouses_products
ORDER BY
  IF(value > 0, 0, 1),
  value;


SELECT
  *
FROM
  storehouses_products
ORDER BY
  value = 0, value;


-- Тема Операции, задание 4
-- (по желанию) Из таблицы users необходимо извлечь пользователей, родившихся в
-- августе и мае. Месяцы заданы в виде списка английских названий ('may', 'august')

SELECT name  
  FROM users
  WHERE DATE_FORMAT(birthday_at, '%M') IN ('may', 'august');

-- Тема Операции, задание 5
-- (по желанию) Из таблицы catalogs извлекаются записи при помощи запроса.
-- SELECT * FROM catalogs WHERE id IN (5, 1, 2);
-- Отсортируйте записи в порядке, заданном в списке IN.

INSERT INTO catalogs VALUES
  (NULL, 'Процессоры'),
  (NULL, 'Материнские платы'),
  (NULL, 'Видеокарты'),
  (NULL, 'Жесткие диски'),
  (NULL, 'Оперативная память');

SELECT
  *
FROM
  catalogs
WHERE
  id IN (5, 1, 2)
ORDER BY
  FIELD(id, 5, 1, 2);

-- Тема Агрегация, задание 1
-- Подсчитайте средний возраст пользователей в таблице users
SELECT
  AVG(TIMESTAMPDIFF(YEAR, birthday_at, NOW())) AS age
FROM
  users;
	  
-- Тема Агрегация, задание 2
-- Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели.
-- Следует учесть, что необходимы дни недели текущего года, а не года рождения.
SELECT
  DATE_FORMAT(DATE(CONCAT_WS('-', YEAR(NOW()), MONTH(birthday_at), DAY(birthday_at))), '%W') AS day,
  COUNT(*) AS total
FROM
  users
GROUP BY
  day
ORDER BY
  total DESC;

-- Тема Агрегация, задание 3
-- (по желанию) Подсчитайте произведение чисел в столбце таблицы
INSERT INTO catalogs VALUES
  (NULL, 'Процессоры'),
  (NULL, 'Материнские платы'),
  (NULL, 'Видеокарты'),
  (NULL, 'Жесткие диски'),
  (NULL, 'Оперативная память');

SELECT ROUND(EXP(SUM(LN(id)))) FROM catalogs;


-- Предложенные варианты реализации лайков и доработки (только для анализа, не для создания!)

-- Вариант 1
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS likes;
CREATE TABLE posts (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	author_id INT UNSIGNED NOT NULL,  -- может быть user или communities
	media_id INT UNSIGNED , -- ссылка может быть а может нет
	body TEXT NOT NULL,
  	created_at DATETIME DEFAULT NOW()
	);
	
CREATE TABLE likes (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	author_id INT UNSIGNED NOT NULL,
	id_type_content_like INT UNSIGNED NOT NULL, 
  	created_at DATETIME DEFAULT NOW()
	);

CREATE TABLE type_content_like (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	id_media INT UNSIGNED NOT NULL,
	id_users INT UNSIGNED NOT NULL,
	id_posts INT UNSIGNED NOT NULL
);


-- Вариант 2
Создание таблицы постов:
CREATE TABLE posts (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  community_id INT UNSIGNED,
  body TEXT NOT NULL,
  media_id INT UNSIGNED,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Вариант 2
-- Вариант реализации лайков:
-- В принципе лайкнуть у нас могут только либо медиа, либо посты.
-- Так что можно сделать две таблицы
-- По аналогии с таблицей friendship можно установить составной PRIMARY KEY
-- чтобы два раза лайкнуть один контент было нельзя.
-- Допустим, если пользователь лайкает медиа в таблицу like_media добавляется
-- строчка, если он убирает свой лайк - строчка оттуда удаляется.

CREATE TABLE likes_posts (
post_id INT UNSIGNED NOT NULL,
user_id INT UNSIGNED NOT NULL,
PRIMARY KEY (post_id, user_id)
);

CREATE TABLE likes_media(
media_id INT UNSIGNED NOT NULL,
user_id INT UNSIGNED NOT NULL,
PRIMARY KEY (media_id, user_id)
);

-- Вариант 3
По лайкам я бы вывела отдельную таблицу media_profile колонками:
id 
media_type_id (из media убрать)
filename (из media убрать)
size INT NOT NULL (из media убрать),
metadata JSON (из media убрать),
created_at
updated_at

и таблица media (сами связи):
media_id
user_id
user_id_status (лайкнул, запостил к себе..., загрузил)
created_at
updated_at


-- Вариант 4
-- Таблица лайков (таблица репостов аналогичная)
CREATE TABLE `likes` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `subject_id` int(10) unsigned NOT NULL,
  `user_id` int(10) unsigned NOT NULL, 
  `liked_at` datetime DEFAULT current_timestamp(),
  `disliked_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
);

-- Таблица того, что лайкается (репостится)
CREATE TABLE `subjects` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `subject_type` varchar(150) NOT NULL,
  PRIMARY KEY (`id`),
);

-- Добавляем в предыдущую таблицу типы объектов, которые лайкаются (репостятся)
INSERT INTO `subjects` (`subject_type`) VALUES
  (`photo`),
  (`video`),
  (`audio`),
  (`post`)
;

-- Таблица Постов (на стене Пользователей, Сообществ)
CREATE TABLE `posts` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT, 
  `user_id` int(10) unsigned NOT NULL, 
  `community_id` int(10) unsigned, 
  `body` text NOT NULL, 
  `media_id` int(10) unsigned, 
  `posted_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(), 
  `deleted_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
);


-- Вариант 5
-- В файле posts_and_likes.sql написал скрипт по созданию трех
-- таблиц для Постов и Лайков. Третью таблицу - на случай, если
-- бизнесс-логика подразумевает несколько видов лайков, как на Фейсбуке.
-- Если у нас будет только один вид лайка, то третья таблица не нужна
-- и из таблицы likes надо удалить поле like_type_id.

-- ТАБЛИЦА С ПОСТАМИ, которые создают пользователи
DROP TABLE IF EXISTS posts; 
CREATE TABLE posts (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL, -- Пользователь, написавший Пост
  title VARCHAR(255) NOT NULL, -- Заголовок
  description VARCHAR(500), -- Краткое описание
  content TEXT, -- Большой текст
  media_id INT UNSIGNED, -- Картинка к Посту
  created_at DATETIME DEFAULT NOW(), -- Дата создания
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW() -- Дата обновления
)

-- ТАБЛИЦА С ЛАЙКАМИ, которые Пользователи ставят Постам
DROP TABLE IF EXISTS likes; 
CREATE TABLE likes (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  post_id INT UNSIGNED NOT NULL, -- id Поста, к которому ставится лайк 
  user_id INT UNSIGNED NOT NULL, -- Пользователь, который поставил лайк
  comment VARCHAR(255), -- Небольшой текст, если к Лайку можно добавить комментарий по бизнес-логике
  like_type_id INT UNSIGNED, -- Тип лайка, если можно ставить разные лайки, как на Фейсбуке 
  created_at DATETIME DEFAULT NOW(), -- Дата создания
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW() -- Дата обновления
)

-- ТАБЛИЦА С ТИПАМИ ЛАЙКОВ, если используется разнолайковый подход
DROP TABLE IF EXISTS like_types; 
CREATE TABLE like_types (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  picture_id INT UNSIGNED NOT NULL, -- id на картинку этого вида лайка (или текстовая ссылка) 
  description VARCHAR(255), -- Описание вида Лайка
  created_at DATETIME DEFAULT NOW(), -- Дата создания
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW() -- Дата обновления


-- Вариант 6
CREATE TABLE posts (
  id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id INT UNSIGNED NOT NULL,
  targer_user_id INT UNSIGNED,
  target_group_id INT UNSIGNED,
  post TEXT
);

-- По аналоги с постом: можно лайкнуть у себя на странице, либо у другого человека, либо в группе
-- Лайкнуть можно пост или медиа, но не оба стразу--> одно из значения в строчке должно быть NULL
CREATE TABLE likes (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT UNSIGNED NOT NULL,
  target_user_id INT UNSIGNED,
  target_group_id INT UNSIGNED,
  target_post_id INT UNSIGNED,
  target_media_id INT UNSIGNED
);

-- Вариант 7
-- Организацию лайков от пользователе реализую таким образом:
-- таблтца содержит в себе каждый лайк.
CREATE TABLE approves(
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	id_users INT NOT NULL,
	id_media INT NOT NULL,
	value_like INT NOT NULL,
	created_like DATETIME DEFAULT NOW()
	);
  

-- Вариант 8 (финальный)
-- Немного изменим и применим (применяем к базе vk только этот вариант лайков!)
-- Таблица лайков
DROP TABLE IF EXISTS likes;
CREATE TABLE likes (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  target_id INT UNSIGNED NOT NULL,
  target_type_id INT UNSIGNED NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Таблица типов лайков
DROP TABLE IF EXISTS target_types;
CREATE TABLE target_types (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO target_types (name) VALUES 
  ('messages'),
  ('users'),
  ('media'),
  ('posts');

-- Заполняем лайки
INSERT INTO likes 
  SELECT 
    id, 
    FLOOR(1 + (RAND() * 100)), 
    FLOOR(1 + (RAND() * 100)),
    FLOOR(1 + (RAND() * 4)),
    CURRENT_TIMESTAMP 
  FROM messages;

-- Проверим
SELECT * FROM likes LIMIT 10;

-- Создадим таблицу постов
CREATE TABLE posts (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  community_id INT UNSIGNED,
  head VARCHAR(255);
  body TEXT NOT NULL,
  media_id INT UNSIGNED,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Примеры на основе базы данных vk
USE vk;

-- Получаем данные пользователя
SELECT * FROM users WHERE id = 8;

SELECT first_name, last_name, 'main_photo', 'city' FROM users WHERE id = 8;

SELECT
  first_name,
  last_name,
  (SELECT filename FROM media WHERE id = 
    (SELECT photo_id FROM profiles WHERE user_id = 8)
  ) AS filename,
  (SELECT city FROM profiles WHERE user_id = 8) AS city
  FROM users
    WHERE id = 8;  

-- Дорабатывем условия    
SELECT
  first_name,
  last_name,
  (SELECT filename FROM media WHERE id = 
    (SELECT photo_id FROM profiles WHERE user_id = users.id)
  ) AS filename,
  (SELECT city FROM profiles WHERE user_id = users.id) AS city
  FROM users
    WHERE id = 8;          

-- Получаем фотографии пользователя
SELECT filename FROM media
  WHERE user_id = 8
    AND media_type_id = (
      SELECT id FROM media_types WHERE name = 'photo'
    );
    
SELECT * FROM media_types;

-- Выбираем историю по добавлению фотографий пользователем
SELECT CONCAT(
  'Пользователь добавил фото ', 
  filename, 
  ' ', 
  created_at) AS news 
    FROM media 
    WHERE user_id = 8 AND media_type_id = (
        SELECT id FROM media_types WHERE name LIKE 'photo'
);

-- Улучшаем запрос
SELECT CONCAT(
  'Пользователь ', 
  (SELECT CONCAT(first_name, ' ', last_name) FROM users WHERE id = media.user_id),
  ' добавил фото ', 
  filename, ' ', 
  created_at) AS news 
    FROM media 
    WHERE user_id = 8 AND media_type_id = (
        SELECT id FROM media_types WHERE name LIKE 'photo'
);

-- Найдём кому принадлежат 10 самых больших медиафайлов
SELECT user_id, filename, size 
  FROM media 
  ORDER BY size DESC
  LIMIT 10;

-- Улучшим запрос, используем алиасы для имён таблиц
SELECT 
  (SELECT CONCAT(first_name, ' ', last_name) 
    FROM users u WHERE u.id = m.user_id) AS owner,
  filename, 
  size 
    FROM media m
    ORDER BY size DESC
    LIMIT 10;
  
 -- Выбираем друзей пользователя с двух сторон отношения дружбы
(SELECT friend_id FROM friendship WHERE user_id = 8)
UNION
(SELECT user_id FROM friendship WHERE friend_id = 8);

-- Выбираем только друзей с активным статусом
SELECT * FROM friendship_statuses;

(SELECT friend_id 
  FROM friendship 
  WHERE user_id = 8 AND status_id IN (
      SELECT id FROM friendship_statuses WHERE name = 'Confirmed'
    )
)
UNION
(SELECT user_id 
  FROM friendship 
  WHERE friend_id = 8 AND status_id IN (
      SELECT id FROM friendship_statuses WHERE name = 'Confirmed'
    )
);


-- Выбираем медиафайлы друзей
SELECT filename FROM media WHERE user_id IN (
  (SELECT friend_id 
  FROM friendship 
  WHERE user_id = 8 AND status_id IN (
      SELECT id FROM friendship_statuses WHERE name = 'Confirmed'
    )
  )
  UNION
  (SELECT user_id 
    FROM friendship 
    WHERE friend_id = 8 AND status_id IN (
      SELECT id FROM friendship_statuses WHERE name = 'Confirmed'
    )
  )
);

-- Объединяем медиафайлы пользователя и его друзей для создания ленты новостей
SELECT filename, user_id, created_at FROM media WHERE user_id = 8
UNION
SELECT filename, user_id, created_at FROM media WHERE user_id IN (
  (SELECT friend_id 
  FROM friendship 
    WHERE user_id = 8 AND status_id IN (
      SELECT id FROM friendship_statuses WHERE name = 'Confirmed'
    )
  )
  UNION
  (SELECT user_id 
    FROM friendship 
    WHERE friend_id = 8 AND status_id IN (
      SELECT id FROM friendship_statuses WHERE name = 'Confirmed'
    )
  )
);

-- Определяем пользователей, общее занимаемое место медиафайлов которых 
-- превышает 100МБ
SELECT user_id, SUM(size) AS total
  FROM media
  GROUP BY user_id
  HAVING total > 100000000
  ORDER BY total DESC;

-- Подсчитываем лайки для медиафайлов пользователя и его друзей
SELECT target_id AS mediafile, COUNT(*) AS likes 
  FROM likes 
    WHERE target_id IN (
      SELECT id FROM media WHERE user_id = 3
        UNION
      (SELECT id FROM media WHERE user_id IN (
        SELECT friend_id 
          FROM friendship WHERE user_id = 8 AND status_id IN (
                SELECT id FROM friendship_statuses WHERE name = 'Confirmed'
              )))
        UNION
      (SELECT id FROM media WHERE user_id IN (
        SELECT user_id 
          FROM friendship WHERE friend_id = 8 AND status_id IN (
                SELECT id FROM friendship_statuses WHERE name = 'Confirmed'
              ))) 
    )
    AND target_type_id = (SELECT id FROM target_types WHERE name = 'media')
    GROUP BY target_id;


-- Начинаем создавать архив новостей для медиафайлов по месяцам
SELECT COUNT(id) AS arhive, MONTHNAME(created_at) AS month 
  FROM media
  GROUP BY month;
  
-- Архив с правильной сортировкой новостей по месяцам
SELECT COUNT(id) AS news, 
  MONTHNAME(created_at) AS month,
  MONTH(created_at) AS month_num 
    FROM media
      WHERE YEAR(created_at) = YEAR(NOW())
    GROUP BY month_num, month
    ORDER BY month_num DESC;

SELECT COUNT(id) AS news, 
  MONTHNAME(created_at) AS month,
  MONTH(created_at) AS month_num 
    FROM media
    GROUP BY month_num, month
    ORDER BY month_num DESC;   
    

-- Выбираем сообщения от пользователя и к пользователю
SELECT from_user_id, to_user_id, body, is_delivered, created_at 
  FROM messages
    WHERE from_user_id = 8 OR to_user_id = 8
    ORDER BY created_at DESC;
    
-- Сообщения со статусом
SELECT from_user_id, 
  to_user_id, 
  body, 
  IF(is_delivered, 'delivered', 'not delivered') AS status 
    FROM messages
      WHERE (from_user_id = 8 OR to_user_id = 8)
    ORDER BY created_at DESC;
    
 -- Выводим друзей пользователя с преобразованием пола и возраста 
SELECT 
    (SELECT CONCAT(first_name, ' ', last_name) 
      FROM users 
      WHERE id = user_id) AS friend,            -- имя пользователя
    CASE (gender)                       
      WHEN 'm' THEN 'man'
      WHEN 'f' THEN 'women'
    END AS sex,                                  -- пол
    TIMESTAMPDIFF(YEAR, birthday, NOW()) AS age -- возраст
  FROM profiles
  WHERE user_id IN (
    SELECT friend_id FROM friendship
      WHERE user_id = 8 
        AND confirmed_at IS NOT NULL
        AND status_id IN (
          SELECT id FROM friendship_statuses WHERE name = 'Confirmed'
          )
      UNION
      SELECT user_id 
      FROM friendship
      WHERE friend_id = 8
        AND confirmed_at IS NOT NULL
        AND status_id IN (
          SELECT id FROM friendship_statuses WHERE name = 'Confirmed'
          )
  );
    
-- Поиск пользователя по шаблонам имени  
SELECT CONCAT(first_name, ' ', last_name) AS fullname  
  FROM users
  WHERE first_name LIKE 'M%';
  
-- Используем регулярные выражения
SELECT CONCAT(first_name, ' ', last_name) AS fullname  
  FROM users
  WHERE last_name RLIKE '^S.*t$';
  
  
  