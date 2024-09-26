SELECT MIN(question_id) AS master_question_id, MAX(question_id) AS duplicate_question_id
    FROM Questions
    GROUP BY question_text
    HAVING COUNT(*) > 1