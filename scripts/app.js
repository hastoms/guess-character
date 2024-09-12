let session_id = null;
let question_order = 0;
let currentQuestionId = null;  // Track current question ID
let character_guess = null;

function startGame() {
    fetch('https://cmxsilzill.execute-api.us-east-1.amazonaws.com/dev/start_game3', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ player_id: 1 })
    })
    .then(response => response.json())
    .then(data => {
        session_id = data.session_id;
        currentQuestionId = data.question_id;  // Set initial question ID
        displayQuestion(data.question_text);
    });
}

function displayQuestion(question) {
    document.getElementById('question-box').innerHTML = `<h2>${question}</h2>`;
}

function submitAnswer(answer) {
    if (session_id && currentQuestionId) {
        question_order++;
        fetch('https://cmxsilzill.execute-api.us-east-1.amazonaws.com/dev/submit_answer3', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                session_id: session_id,
                question_id: currentQuestionId,  // Use the tracked question ID
                user_response: answer,
                question_order: question_order
            })
        })
        .then(response => response.json())
        .then(data => {
            if (data.guessed_character) {
                // The game is guessing the character
                character_guess = data.guessed_character;
                displayGuess(character_guess);
            } else if (data.next_question) {
                // Continue with the next question
                currentQuestionId = data.next_question.question_id;  // Update to the next question ID
                displayQuestion(data.next_question.question_text);
            }
        });
    }
}

function displayGuess(character) {
    document.getElementById('question-box').innerHTML = `<h2>Are you ${character}?</h2>`;
    document.getElementById('response-box').innerHTML = `
        <button id="correct-button" onclick="submitGuessResponse(true)">Correct</button>
        <button id="incorrect-button" onclick="submitGuessResponse(false)">Incorrect</button>
    `;
}

function submitGuessResponse(isCorrect) {
    fetch('https://cmxsilzill.execute-api.us-east-1.amazonaws.com/dev/end_game3', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            session_id: session_id,
            is_correct: isCorrect
        })
    })
    .then(response => response.json())
    .then(data => {
        if (isCorrect) {
            document.getElementById('question-box').innerHTML = `<h2>Great! The game guessed correctly.</h2>`;
            document.getElementById('response-box').innerHTML = '';  // Clear response buttons
        } else {
            document.getElementById('question-box').innerHTML = `<h2>You win! Add your character details below.</h2>`;
            displayNewCharacterForm();
        }
    });
}

function displayNewCharacterForm() {
    document.getElementById('response-box').innerHTML = `
        <form id="new-character-form">
            <label for="character-name">Character Name:</label><br>
            <input type="text" id="character-name" name="character-name" required><br>
            <label for="new-question">New Question:</label><br>
            <input type="text" id="new-question" name="new-question" required><br>
            <button type="submit" onclick="submitNewCharacter(event)">Submit</button>
        </form>
    `;
}

function submitNewCharacter(event) {
    event.preventDefault();
    const characterName = document.getElementById('character-name').value;
    const newQuestion = document.getElementById('new-question').value;

    fetch('https://cmxsilzill.execute-api.us-east-1.amazonaws.com/dev/add_character3', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            character_name: characterName,
            new_question: newQuestion,
            previous_character: character_guess  // Include the previously guessed character
        })
    })
    .then(response => response.json())
    .then(data => {
        document.getElementById('question-box').innerHTML = `<h2>Thanks! Your character has been added.</h2>`;
        document.getElementById('response-box').innerHTML = '';  // Clear the form
    });
}

window.onload = startGame;
