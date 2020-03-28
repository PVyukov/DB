USE vk_ex;

-- 2. Подсчитать общее количество лайков, которые получили 10 самых молодых пользователей
SELECT COUNT(l.user_id) AS total 
FROM likes AS l
	 JOIN profiles AS p
       ON l.target_id = p.user_id
     JOIN target_types AS t 
       ON l.target_type_id = t.id 
     WHERE t.name = 'users' AND 
           l.target_id IN 
             (SELECT * FROM (SELECT user_id FROM profiles ORDER BY birthday DESC LIMIT 10) AS tmp); 
            
-- улучшенная версия
SELECT COUNT(l.user_id) AS total 
FROM likes AS l
	 JOIN (SELECT user_id FROM profiles ORDER BY birthday DESC LIMIT 10) AS yongest
       ON l.target_id = yongest.user_id
     JOIN target_types AS t 
       ON l.target_type_id = t.id 
     WHERE t.name = 'users';

            
 -- 3. Определить кто больше поставил лайков (всего) - мужчины или женщины?
SELECT p.gender , COUNT(p.gender ) AS total
 FROM likes AS l 
      JOIN profiles AS p 
      ON l.user_id = p.user_id
GROUP BY p.gender
ORDER BY total DESC LIMIT 1;

-- 4. Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети.
-- чем меньше пользователь ставит лайков, тем менее он активен
SELECT CONCAT (u.first_name, ' ', u.last_name ) AS user , COUNT(l.user_id ) AS total_u
  FROM profiles AS p  
  LEFT JOIN likes AS l 
       ON p.user_id = l.user_id 
  JOIN users AS u 
  	   ON u.id=p.user_id 
 GROUP BY p.user_id
 ORDER BY total_u LIMIT 10
 ;
 
