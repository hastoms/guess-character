-- Iteration 1
CREATE DATABASE `guess-characters3-db`;
use `guess-characters3-db`;

-- Characters Table
CREATE TABLE Characters (
    character_id SERIAL PRIMARY KEY,
    character_name VARCHAR(255) NOT NULL,
    character_show VARCHAR(255),
    image_url VARCHAR(255),
    is_flagged BOOLEAN DEFAULT 0,
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    creating_player_id INT
);

-- Questions Table
CREATE TABLE Questions (
    question_id SERIAL PRIMARY KEY,
    question_text TEXT NOT NULL,
    category VARCHAR(255),
    times_asked INT DEFAULT 0,
    yes_count INT DEFAULT 0,
    no_count INT DEFAULT 0,
    entropy_score FLOAT DEFAULT 0,
    is_flagged BOOLEAN DEFAULT 0,
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    creating_player_id INT
);

-- Character-Question Mapping Table
CREATE TABLE Character_Question_Map (
    map_id SERIAL PRIMARY KEY,
    character_id INT REFERENCES Characters(character_id),
    question_id INT REFERENCES Questions(question_id),
    session_id INT REFERENCES Game_Sessions(session_id),
    answer ENUM('Yes', 'No', 'Don\'t Know', 'Probably', 'Probably Not'),
    weight FLOAT DEFAULT 1.0,
    is_flagged BOOLEAN DEFAULT 0,
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    creating_player_id INT
);

-- Game Sessions Table
CREATE TABLE Game_Sessions (
    session_id SERIAL PRIMARY KEY,
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP,
    character_guessed_id INT REFERENCES Characters(character_id),
    is_successful BOOLEAN
);

-- User Answers Table
CREATE TABLE User_Answers (
    answer_id SERIAL PRIMARY KEY,
    session_id INT REFERENCES Game_Sessions(session_id),
    question_id INT REFERENCES Questions(question_id),
    user_response ENUM('Yes', 'No', 'Don\'t Know', 'Probably', 'Probably Not'),
    question_order INT
);

/////////////////;

-- Switch to the correct database
USE `guess-characters3-db`;

-- Populate the Characters table
INSERT INTO Characters (character_name, character_show, image_url, is_flagged, creating_player_id)
VALUES 
('Character 1', 'Show A', 'http://example.com/char1.jpg', 0, 1),
('Character 2', 'Show B', 'http://example.com/char2.jpg', 0, 2),
('Character 3', 'Show C', 'http://example.com/char3.jpg', 0, 3);

-- Populate the Questions table
INSERT INTO Questions (question_text, category, times_asked, yes_count, no_count, entropy_score, is_flagged, creating_player_id)
VALUES
('Is the character male?', 'Gender', 5, 3, 2, 0.5, 0, 1),
('Is the character from a TV show?', 'Category', 4, 2, 2, 0.4, 0, 2),
('Does the character wear glasses?', 'Appearance', 3, 1, 2, 0.3, 0, 3);

-- Populate the Game_Sessions table
INSERT INTO Game_Sessions (start_time, end_time, character_guessed_id, is_successful)
VALUES
(NOW(), NOW() + INTERVAL 5 MINUTE, 1, 1),
(NOW(), NOW() + INTERVAL 10 MINUTE, 2, 0),
(NOW(), NOW() + INTERVAL 7 MINUTE, 3, 1);

-- Populate the Character_Question_Map table
INSERT INTO Character_Question_Map (character_id, question_id, session_id, answer, weight, is_flagged, creating_player_id)
VALUES
(1, 1, 1, 'Yes', 1.0, 0, 1),
(2, 2, 2, 'No', 1.0, 0, 2),
(3, 3, 3, 'Probably', 1.0, 0, 3);

-- Populate the User_Answers table
INSERT INTO User_Answers (session_id, question_id, user_response, question_order)
VALUES
(1, 1, 'Yes', 1),
(2, 2, 'No', 1),
(3, 3, 'Probably', 1);

select * from Characters;
select * from Game_Sessions;
select * from Questions;
select * from User_Answers;
CREATE INDEX idx_question_id ON Questions(question_id);
CREATE INDEX idx_yes_count ON Questions(yes_count);
CREATE INDEX idx_no_count ON Questions(no_count);
show index from Questions;
show grants for 'admin';
INSERT INTO User_Answers (session_id, question_id, user_response, question_order) 
VALUES (4, 1, 'Yes', 1);

DELETE FROM User_Answers
WHERE answer_id = 4;
