-- Eligible characters remaining; submit_answer3
-- 132 is Chewbacca
SELECT COUNT(DISTINCT cqm.character_id) 
	FROM Character_Question_Map cqm
	JOIN User_Answers ua
	  ON cqm.question_id = ua.question_id
	  AND cqm.answer = ua.user_response
	WHERE ua.session_id = 132 -- session_id
	  AND cqm.is_flagged = 0
	  AND cqm.character_id IS NOT NULL
	  AND cqm.character_id != 1;
      
SELECT DISTINCT cqm.character_id, c.character_name
	FROM Character_Question_Map cqm
	JOIN User_Answers ua
	  ON cqm.question_id = ua.question_id
	  AND cqm.answer = ua.user_response
	JOIN Characters c
      ON cqm.character_id = c.character_id
	WHERE ua.session_id = 132 -- session_id
	  AND cqm.is_flagged = 0
	  AND cqm.character_id IS NOT NULL
	  AND cqm.character_id != 1;
      
SELECT COUNT(DISTINCT cqm.character_id)
FROM Character_Question_Map cqm
JOIN User_Answers ua ON cqm.question_id = ua.question_id
WHERE ua.session_id = 132  -- session_id
  AND cqm.is_flagged = 0
  AND cqm.character_id IS NOT NULL
  AND cqm.character_id != 1  -- Exclude corrupt character 1
  AND NOT EXISTS (
      SELECT 1
      FROM Character_Question_Map cqm2
      WHERE cqm2.character_id = cqm.character_id
        AND cqm2.question_id = ua.question_id
        AND (
          (ua.user_response = 'Yes' AND cqm2.answer = 'No') OR
          (ua.user_response = 'No' AND cqm2.answer = 'Yes') OR
          (ua.user_response = 'Yes' AND cqm2.answer = 'Yes' AND cqm2.is_flagged = 1) -- Exclude if flagged
        )
  );

SELECT DISTINCT cqm.character_id, c.character_name
FROM Character_Question_Map cqm
JOIN User_Answers ua ON cqm.question_id = ua.question_id
JOIN Characters c ON cqm.character_id = c.character_id
WHERE ua.session_id = 132  -- session_id
  AND cqm.is_flagged = 0
  AND cqm.character_id IS NOT NULL
  AND cqm.character_id != 1  -- Exclude corrupt character 1
  AND NOT EXISTS (
      SELECT 1
      FROM Character_Question_Map cqm2
      WHERE cqm2.character_id = cqm.character_id
        AND cqm2.question_id = ua.question_id
        AND (
          (ua.user_response = 'Yes' AND cqm2.answer = 'No') OR
          (ua.user_response = 'No' AND cqm2.answer = 'Yes') OR
          (ua.user_response = 'Yes' AND cqm2.answer = 'Yes' AND cqm2.is_flagged = 1) -- Exclude if flagged
        )
  );

-- 3rd attempt;
SELECT cqm.character_id, c.character_name
FROM Character_Question_Map cqm
JOIN User_Answers ua ON cqm.question_id = ua.question_id
JOIN Characters c ON cqm.character_id = c.character_id
WHERE ua.session_id = 148  -- session_id
  AND cqm.is_flagged = 0
  AND cqm.character_id IS NOT NULL
  AND cqm.character_id != 1  -- Exclude corrupt character 1
  AND (
    (ua.user_response = 'Yes' AND cqm.answer = 'Yes') OR
    (ua.user_response = 'No' AND cqm.answer = 'No') OR
    (ua.user_response = 'Don\'t Know')
  )
GROUP BY cqm.character_id, c.character_name
HAVING COUNT(cqm.question_id) = (
    SELECT COUNT(ua2.question_id)
    FROM User_Answers ua2
    WHERE ua2.session_id = 148 -- session_id
);

