select * from Questions order by entropy_score desc, times_asked ASC;

UPDATE Questions 
SET times_asked = 5
WHERE question_id in (5,6,8,9,11,14,17,16,19,22);
