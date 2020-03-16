SHOW DATABASES;
USE vk_ex;
-- 2. Подсчитать общее количество лайков, которые получили 10 самых молодых пользователей.
SELECT
  (SELECT CONCAT(first_name,' ', last_name) FROM users WHERE id=user_id) AS user,
  (SELECT birthday FROM profiles p WHERE p.user_id = l.user_id) AS birthday,
  COUNT(*) AS cnt  
FROM likes l
GROUP BY user_id
ORDER BY birthday DESC
LIMIT 10;
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
-- 4. Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети.
-- чем меньше пользователь ставит лайков, тем менее он активен
SELECT
  (SELECT CONCAT(first_name,' ', last_name) FROM users WHERE id=user_id) AS user,
  COUNT(*) AS CNT 
FROM likes
GROUP BY user_id
ORDER BY cnt
LIMIT 10;   






