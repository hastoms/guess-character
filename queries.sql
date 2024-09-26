use `guess-characters3-db`;
select * from Character_Question_Map order by map_id DESC;
select * from Characters;
select * from Game_Sessions order by session_id desc;
select * from Questions order by entropy_score desc, times_asked ASC;
select * from User_Answers;
Select session_id, count(question_id) from User_Answers group by 1 order by 1 desc;
select character_id, count(question_id) from Character_Question_Map group by 1 order by 1 desc;
select question_id, answer, count(character_id) from Character_Question_Map group by 1,2 order by 3 desc;
select question_id, count(character_id) from Character_Question_Map group by 1 order by 2 desc;

INSERT INTO User_Answers (session_id, question_id, user_response, question_order) VALUES
(62, 1, 'Yes', 1),
(62, 2, 'No', 2),
(62, 3, 'Yes', 3),
(62, 4, 'No', 4),
(62, 5, 'Yes', 5),
(62, 6, 'No', 6),
(62, 7, 'Yes', 7),
(62, 8, 'No', 8);

INSERT INTO Characters (character_name, character_show, image_url, is_flagged, creating_player_id)
VALUES 
('Sven', 'Frozen', 'http://example.com/char1.jpg', 0, 1);
SHOW TABLE STATUS LIKE 'User_Answers';

UPDATE Questions SET question_text = 'Is the character 13 years or older?', category = "age" WHERE question_id = 4;
UPDATE Questions SET question_text = 'Does the character often wear a hat?', category = "Appearance" WHERE question_id = 18;
update Characters set image_url = 'https://th.bing.com/th/id/OIG4.B8JzG55aK0P7O_JfJnYA?w=270&h=270&c=6&r=0&o=5&dpr=2&pid=ImgGn' where character_id =1;

SELECT cqm.character_id, COUNT(*) as match_count
	FROM Character_Question_Map cqm
	JOIN User_Answers ua
	  ON cqm.question_id = ua.question_id
	  AND cqm.answer = ua.user_response
	WHERE ua.session_id = 71
	  AND cqm.session_id != 71
	  AND cqm.character_id IS NOT NULL
	  AND cqm.is_flagged = FALSE
	GROUP BY cqm.character_id
	ORDER BY match_count DESC
	LIMIT 1;
    
    SELECT cqm.character_id 
    FROM Character_Question_Map cqm
    JOIN User_Answers ua ON cqm.question_id = ua.question_id AND cqm.answer = ua.user_response
    WHERE ua.session_id = 79 AND cqm.character_id IS NOT NULL
    GROUP BY cqm.character_id
    HAVING COUNT(*) = (SELECT COUNT(*) FROM User_Answers WHERE session_id = 79);

ALTER USER 'admin'@'localhost' WITH MAX_QUERIES_PER_HOUR 0;
FLUSH PRIVILEGES;
explain questions;

UPDATE mysql.user SET max_questions=0 WHERE User='admin';
flush privileges;