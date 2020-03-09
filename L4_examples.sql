-- Урок 4
-- CRUD операции


-- Работа с БД vk
-- Загружаем дамп консольным клиентом
DROP DATABASE vk;
CREATE DATABASE vk;

-- Переходим в папку с дампом (/home/ubuntu)
-- mysql -u root -p vk < vk.dump.sql

-- Дорабатываем тестовые данные
-- Смотрим все таблицы
SHOW TABLES;

-- Анализируем данные пользователей
SELECT * FROM users LIMIT 10;

-- Удаляем столбец пароля
ALTER TABLE users DROP COLUMN password;

-- Приводим в порядок временные метки
UPDATE users SET updated_at = CURRENT_TIMESTAMP WHERE created_at > updated_at;

-- Смотрим структуру профилей
DESC profiles;

-- Добавляем столбец user_id
ALTER TABLE profiles 
  ADD COLUMN user_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST;
  
-- Изменяем имя столбца пола 
ALTER TABLE profiles CHANGE COLUMN sex gender CHAR(1) NOT NULL; 

-- Анализируем данные
SELECT * FROM profiles LIMIT 10;

-- Создаём временную таблицу полов
CREATE TEMPORARY TABLE gender (gender CHAR(1));

-- Заполняем значениями
INSERT INTO gender VALUES ('m'), ('f');

-- Проверяем
SELECT * FROM gender;

-- Заполняем профили случайным значением пола
UPDATE profiles SET gender = (SELECT gender FROM gender ORDER BY RAND() LIMIT 1);

-- Смотрим как работает функция RAND
SELECT RAND();

-- Собираем выражение для выборки числа из диапазона
SELECT FLOOR(1 + (RAND() * 100));

-- Обновляем ссылки на фото
UPDATE profiles SET photo_id = FLOOR(1 + (RAND() * 100));

-- Смотрим структуру таблицы профилей
DESC profiles;

-- Все таблицы
SHOW TABLES;

-- Смотрим структуру таблицы сообщений
DESC messages;

-- Анализируем данные
SELECT * FROM messages LIMIT 10;

-- Обновляем значения ссылок на отправителя и получателя сообщения
UPDATE messages SET 
  from_user_id = FLOOR(1 + (RAND() * 100)),
  to_user_id = FLOOR(1 + (RAND() * 100));

-- Смотрим структуру таблицы медиаконтента 
DESC media;

-- Анализируем данные
SELECT * FROM media LIMIT 10;

-- Анализируем типы медиаконтента
SELECT * FROM media_types;

-- Удаляем все типы
DELETE FROM media_types;

-- Добавляем нужные типы
INSERT INTO media_types (name) VALUES
  ('photo'),
  ('video'),
  ('audio')
;

-- DELETE не сбрасывает счётчик автоинкрементирования,
-- поэтому применим TRUNCATE
TRUNCATE media_types;

-- Анализируем данные
SELECT * FROM media LIMIT 10;

-- Обновляем данные для ссылки на тип и владельца
UPDATE media SET media_type_id = FLOOR(1 + (RAND() * 3));
UPDATE media SET user_id = FLOOR(1 + (RAND() * 100));

-- Обновляем ссылку на файл
UPDATE media SET filename = CONCAT('https://dropbox/vk/file_', filename);

-- Обновляем размер файла
UPDATE media SET size = FLOOR(10000 + (RAND() * 1000000)) WHERE size = 0;

-- Заполняем метаданные
UPDATE media SET metadata = CONCAT('{"owner":"', 
  (SELECT CONCAT(first_name, ' ', last_name) FROM users WHERE id = user_id),
  '"}');  

-- Возвращаем столбцу метеданных правильный тип
ALTER TABLE media MODIFY COLUMN metadata JSON;

-- Смотрим структуру таблицы дружбы
DESC friendship;

-- Анализируем данные
SELECT * FROM friendship;

-- Обновляем ссылки на друзей
UPDATE friendship SET 
  user_id = FLOOR(1 + (RAND() * 100)),
  friend_id = FLOOR(1 + (RAND() * 100));
 
-- Анализируем данные 
SELECT * FROM friendship_statuses;

-- Очищаем таблицу
TRUNCATE friendship_statuses;

-- Вставляем значения статусов дружбы
INSERT INTO friendship_statuses (name) VALUES
  ('Requested'),
  ('Confirmed'),
  ('Rejected');
 
-- Обновляем ссылки на статус 
UPDATE friendship SET status_id = FLOOR(1 + (RAND() * 3)); 

-- Смотрим структуру таблицы групп
DESC communities;

-- Анализируем данные
SELECT * FROM communities;

-- Оставим только 20 групп
DELETE FROM communities WHERE id > 20;

-- Анализируем таблицу связи пользователей и групп
SELECT * FROM communities_users;

-- Обновляем ссылки на группы
UPDATE communities_users SET community_id = FLOOR(1 + (RAND() * 20)); 



-- Предложения по доработке структуры БД vk (только для ознакомления и анализа)

-- Вариант 1

-- 1) если таблица users нужна нам только для логина, чтобы максимально
-- ускорить процесс, то first_name и last_name думаю можно перенести в
-- таблицу profiles, поскольку в вк нет опции логина по имени фамилии -
-- только имэйл телефон.

-- 2) исходя из нашей структуры загрузить медиа контент может только юзер,
-- хотя и сообщество может делать аплоад файлов. можно разделить их на две
-- таблицы (допустим media_by_user и media_by_community).

-- Применяем к БД vk
ALTER TABLE media ADD COLUMN community_id INT UNSIGNED AFTER user_id;
DESC media;

-- 3) в нашей структуре есть медиа, но в таблице отражается лишь информация
-- о том, кто загрузил, однако нет информации о том, добавил ли кто-то
-- себе этот медиа файл. хотя здесь видимо все же случай расширения
-- функционала, все-таки это очень базовая опция. едва ли кто-то знает
-- кто изначально загружал те файлы, из которых состоит собственный аудио
-- плейлист, но такой плейлист у всех есть)) это можно реализовать
-- отдельными таблицами например (media_users и media_comminities по
-- типу users_communities).


-- Вариант 2
-- В общем структура БД более-менее понятна, за исключением таблицы messages.
-- В текущем формате получается "свалка" всех сообщений всех пользователей в
-- одну таблицу. Предложение для оптимизации: разделить таблицу messages на
-- две таблицы dialogs и messages.

CREATE TABLE dialogs (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, 
  first_user_id INT UNSIGNED NOT NULL,
  second_user_id INT UNSIGNED NOT NULL,
  created_at DATETIME DEFAULT NOW()
);

CREATE TABLE messages (
  dialog_id INT UNSIGNED NOT NULL PRIMARY KEY,, 
  from_user_id INT UNSIGNED NOT NULL,
  to_user_id INT UNSIGNED NOT NULL,
  body TEXT NOT NULL,
  is_important BOOLEAN,
  is_delivered BOOLEAN,
  created_at DATETIME DEFAULT NOW()
);

SELECT * FROM messages 
  WHERE (from_user_id = 1 AND to_user_id = 3)
    OR (from_user_id = 3 AND to_user_id = 1);

DESC messages;

-- Применяем к БД vk
ALTER TABLE messages ADD COLUMN community_id INT UNSIGNED AFTER to_user_id;

-- Вариант 3

-- 1) В таблице profiles есть поля:
-- city VARCHAR(100),
-- country VARCHAR(100)
-- В них планируется текстом заносить город и страну. Будет правильнее,
-- если мы вынесем сущности «страна» и «город» в отдельные таблицы
-- countries и cities, в таблице profiles сделаем ссылки на эти id:
 
-- city_id INT UNSIGNED NOT NULL
-- country_id INT UNSIGNED NOT NULL

-- 2) В таблице media мы завели поле:
-- size INT NOT NULL
-- К нему можно добавить опцию UNSIGNED, т.к. отрицательного размера файла не будет.

-- Применяем к БД vk
ALTER TABLE media MODIFY COLUMN size INT UNSIGNED;

DESC media;

-- 3) В ряд таблиц можно добавить поле состояния, которое будет говорить
-- о текущем статусе записи/строчки таблицы (активная, архивная, удалена).
-- Такую идею можно применить, например, к таблицам:
-- users, friendship_statuses, communities, media.

-- 4) С таблицей friendship как-то интуитивно не удобно работать из-за того,
-- что в ней нет id записи. При обновлении таблицы приходится ссылаться
-- на два поля: WHERE user_id = .. AND friend_id = ..

SELECT * FROM friendship;

DESC friendship;


-- Вариант 4
-- Думаю можно добавить в медиа и группы лайки и комментарии, а в
-- сообщения команды удалить и отредактировать. Не писала команды в
-- файле для них, могу к следующему дз приложить.

SELECT * FROM media;


-- Вариант 5
-- Таблица profiles. Ввиду современного многообразия гендеров, ввести
-- отдельну таблицу (genders) с описанием возможных вариантов, а в
-- profiles.gender указывать лишь id из таблицы genders.

SELECT * FROM profiles;

-- Таблица messages. Добавить возможность отправки не только текста, но
-- и медиа. Сделать таблицу не общей для всех пользователей, а для каждого
-- пользователя свою таблицу.
 
DESC messages; 

-- Применяем к БД vk
ALTER TABLE messages ADD column media_id INT UNSIGNED AFTER body;
 
-- Правильно ли понял таблицу friendship_statuses? В ней задается
-- "уровень" дружбы, например: родственник, коллега, друг, - так?
-- Потому что, если пользователи незнакомы, то и нет смысла их указывать
-- в таблице friendship?

SELECT * FROM friendship;
SELECT * FROM friendship_statuses;

-- Может быть стоит для каждого юзера делать отдельную таблицу с его
-- друзьями и уже там указывать статус дружбы, потому как если указывать
-- статус дружбы всех пользователей в одной таблице, то она в какой-то
-- момент разрастется до немыслимых размеров и поиск по ней будет
-- весьма затруднен. Столбцы например такие: 
-- 0) id; 
-- 1) user_id (с кем установлены отношения у владельца таблицы);
-- 2) status_id (каждый владелец таблицы сможет сам задавать какие у
-- него отношения с другим пользователем, ведь вполне может быть разное
-- восприятие дружбы (например, первый считает второго коллегой,
-- в то время как второй первого - другом); 
-- 3) blocked (False, True - черный список); 
-- 4) requested_at; 5) confirmed_at.
 
-- Таблица communities_users. Назначение ролей(прав) пользователей,
-- например: админ, модер, юзер

SELECT * FROM communities_users;

-- Применяем к БД vk
ALTER TABLE communities_users ADD COLUMN is_admin BOOLEAN AFTER user_id;
ALTER TABLE communities_users ADD COLUMN is_moderator BOOLEAN AFTER is_admin;

-- Таблица media. Возможность сортировки контента, например фото(картинки)
-- по альбомам.



-- Вариант 6
-- Добавить описания сообществ.
-- Добавить "аватарку" пользователя из таблицы медиа.

-- Применяем к БД vk
DESC communities;
ALTER TABLE communities ADD COLUMN description TEXT;


-- Вариант 7
-- Подозреваю, что таблицу media можно немного оптимизировать.
-- Например, множество пользователей хранит одни и те же медиа файлы.
-- Следовательно, т.к. used_id у нас является одидним из полей
-- таблицы media, в таблице будет много одинаковых строк с
-- объемными данными (meta в json).
-- Решение - построить отдельную таблицу user.id + media.id для
-- хранения инф о том, какие медиа есть у каждого пользователя.
-- Тем самым сократим кол-во строк в таблице media.


-- Вариант 8
-- На мой взгляд можно переработать логику таблицы сообщений.
-- Создать отдельную таблицу для сообщений каждого чата, с точки
-- зрения скорости построении ветки чата это плюс, но мне не известно
-- насколько это будет эффективно с точки зрения скорости БД в целом,
-- так как количество таблиц значительно выростает при использовании
-- этой логики.
-- Для выделения ветки чата между пользователями необходимо
-- динамически создавать таблицу чата в случае нового чата,
-- так же для нормализации таблиц должен быть реестр уже
-- существующих чатов, который будет содержать индексы пользователей
-- и самой таблицы чата.

--Пример:
CREATE TABLE dialogs (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  id_users_1 INT NOT NULL,
  id_users_2 INT NOT NULL,
  name_table_chat VARCHAR(150) NOT NULL
  created_at
);

CREATE TABLE messages_users_from_1_to_5 (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  autor_id INT NOT NULL, 
  body TEXT NOT NULL,
  is_important BOOLEAN,
  is_delivered BOOLEAN,
  created_at DATETIME DEFAULT NOW()
);

-- Так же стоит отметить увелечение сложности формирования запросов. 



-- Замена первичного ключа в случае такой необходимости
CREATE INDEX id_pk_unique ON smsusers (id)
ALTER TABLE parent DROP PRIMARY KEY;
ALTER TABLE parent ADD PRIMARY KEY (userid);



-- Использование справки в терминальном клиенте
HELP SELECT;

-- Документация
-- https://dev.mysql.com/doc/refman/8.0/en/
-- http://www.rldp.ru/mysql/mysql80/index.htm

