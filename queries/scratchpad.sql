-- Scratchpad

SELECT COUNT(1) 
FROM (
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
    )
) AS subquery;
