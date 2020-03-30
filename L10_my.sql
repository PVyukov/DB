-- 1. Проанализировать какие запросы могут выполняться наиболее часто в процессе работы приложения и добавить необходимые индексы.
CREATE INDEX users_first_name_idx ON users(first_name);
CREATE INDEX users_last_name_idx ON users(last_name);
CREATE UNIQUE INDEX profiles_birthday_idx ON profiles(user_id);
CREATE INDEX media_size_media_tupe_id ON media(size, media_tupe_id);


/*2. Задание на оконные функции.
Провести аналитику в разрезе групп.
Построить запрос, который будет выводить следующие столбцы:
имя группы
среднее количество пользователей в группах
самый молодой пользователь в группе
самый пожилой пользователь в группе
количество пользователей в группе
всего пользователей в системе
отношение в процентах (количество пользователей в группе / всего пользователей в системе) * 100
*/

SELECT COUNT(profiles.user_id)/COUNT (communities.id) AS average_per_group
  FROM profiles
  JOIN communities
  ON profiles.user_id = communities_users.user_id; 

USE vk_ex;
SHOW TABLES;
SELECT 
	DISTINCT communities.name,
--    COUNT(DISTINCT profiles.user_id)  /COUNT(DISTINCT communities.id)  AS average_per_group
	MIN(profiles.birthday) OVER w AS min_age,
    MAX(profiles.birthday) OVER w AS max_age,
    COUNT(profiles.user_id) OVER w AS total_per_group,
    COUNT(profiles.user_id) OVER () AS total,
    COUNT(profiles.user_id) OVER w / COUNT(profiles.user_id) OVER() * 100 AS "%"
FROM communities
	JOIN communities_users
		ON communities.id = communities_users.community_id
	JOIN profiles
		ON profiles.user_id = communities_users.user_id
	WINDOW w AS (PARTITION BY communities_users.community_id);

/*3. (по желанию) Задание на денормализацию
Разобраться как построен и работает следующий запрос:
Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети.
ВЫБЕРИТЕ users.id,
COUNT (DISTINCT messages.id) +
COUNT (DISTINCT likes.id) +
COUNT (DISTINCT media.id) AS деятельность
ОТ пользователей
LEFT JOIN сообщения
ON users.id = messages.from_user_id
LEFT JOIN нравится
ON users.id = likes.user_id
LEFT JOIN СМИ
ON users.id = media.user_id
GROUP BY users.id
ЗАКАЗАТЬ ПО ДЕЯТЕЛЬНОСТИ
LIMIT 10;

Правильно-ли он построен?
Какие изменения, включая денормализацию, можно внести в структуру БД чтобы существенно повысить скорость работы этого запроса?

*/