SHOW DATABASES;
USE vk_ex;
DESCRIBE users;
DESCRIBE profiles;
DESCRIBE likes;
DESCRIBE target_types ;
SELECT * FROM target_types;

-- 2. Подсчитать общее количество лайков, которые получили 10 самых молодых пользователей.
SELECT SUM(cnt) as total
FROM 
(SELECT
  (SELECT birthday FROM profiles p WHERE p.user_id = l.user_id) AS birthday,
  COUNT(*) AS cnt  
FROM likes l
WHERE target_type_id = 
  (SELECT id FROM target_types WHERE name = 'users')
GROUP BY user_id
ORDER BY birthday DESC
LIMIT 10) as tmp;
-- Правилное решение:
-- нужно было считать по target_id (кому потавили лайк), а не по user_id (кто поставил лайк)
SELECT SUM(total_per_id) AS total FROM (
  SELECT COUNT(*) as total_per_id
  FROM likes
  WHERE 
   target_id IN (
     SELECT * FROM (
       SELECT user_id FROM profiles ORDER BY birthday DESC LIMIT 10
     ) AS tmp
   ) 
   AND target_type_id = (SELECT id FROM target_types WHERE name = 'users') 
  GROUP BY target_id
) as tmp2;
-- упрощенный вариант тк интересует только общее кол-во, а не зарбивка по пользователям	
  SELECT  COUNT(*) as total
  FROM likes
  WHERE 
   target_id IN (
     SELECT * FROM (
       SELECT user_id FROM profiles ORDER BY birthday DESC LIMIT 10
     ) AS tmp
   ) 
   AND target_type_id = (SELECT id FROM target_types WHERE name = 'users');
 -- второй вариант: выносим limit из вложенного запроса
 SELECT SUM(total_per_user) FROM (
  SELECT (
     SELECT COUNT(*)  FROM likes
     WHERE target_id = profiles.user_id 
     AND target_type_id = (SELECT id FROM target_types WHERE name = 'users')
  ) AS total_per_user
  FROM profiles
  ORDER BY birthday DESC LIMIT 10
) AS tmp2;



-- 3. Определить кто больше поставил лайков (всего) - мужчины или женщины?
SELECT 
IF (
  (SELECT COUNT(*)
  FROM likes 
  WHERE user_id IN 
    (SELECT user_id FROM profiles WHERE gender='m')
  )
  >
  (SELECT COUNT(*) 
  FROM likes 
  WHERE user_id IN 
    (SELECT user_id FROM profiles WHERE gender='f')
  ),
  CONCAT(
    'men put more likes than women; total is ',
    (SELECT COUNT(*)
     FROM likes 
     WHERE user_id IN 
      (SELECT user_id FROM profiles WHERE gender='m')
     )
  ),
  CONCAT(
    'women put more likes than men; total is ',
     (SELECT COUNT(*) 
     FROM likes 
     WHERE user_id IN 
      (SELECT user_id FROM profiles WHERE gender='f')
     )
  )
) AS who_more;

-- Более простое и лаконичное решение
SELECT 
  (SELECT gender FROM profiles p WHERE p.user_id = l.user_id) AS sex,
  COUNT(*) as total
FROM likes l 
GROUP BY sex 
ORDER BY total DESC 
LIMIT 1;


-- 4. Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети.
-- чем меньше пользователь ставит лайков, тем менее он активен
SELECT
  (SELECT CONCAT(first_name,' ', last_name) FROM users WHERE id=user_id) AS user,
  COUNT(*) AS CNT 
FROM likes
GROUP BY user_id
ORDER BY cnt 
LIMIT 10;   
-- Правилное решение: нужно выбирать из таблице лайков пользователей, т.к. есть полбзователи, котроые не ставили лайки
-- и значит их нет в лайках и COUNT(*) = 0. В моём решении эти пользователи не учитываюися
SELECT CONCAT(first_name,' ', last_name) AS user,
  (SELECT COUNT(*)  FROM likes WHERE user_id = users.id) AS cnt
FROM users
ORDER BY cnt 
LIMIT 10;   






