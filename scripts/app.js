let session_id = null;
let question_order = 0;
let character_guess = null;
let currentQuestionId = null;
let character_show = null;
let image_url = null;  // Add a variable to track the image URL

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
        question_order = 0;  // Reset question order
        currentQuestionId = data.question_id;  // Set the first question's ID
        displayQuestion(data.question_text);
        displayResponseButtons();  // Show buttons for Yes, No, and Don't Know
    })
    .catch(error => {
        console.error('Error starting the game:', error);
    });
}

function displayQuestion(question) {
    document.getElementById('question-box').innerHTML = `<h2>${question}</h2>`;
}

function displayResponseButtons() {
    document.getElementById('response-box').innerHTML = `
        <button id="yes-button" onclick="submitAnswer('Yes')">Yes</button>
        <button id="no-button" onclick="submitAnswer('No')">No</button>
        <button id="dont-know-button" onclick="submitAnswer('Dont Know')">Don't Know</button>
    `;
    const responseBox = document.getElementById('response-box');
    responseBox.style.display = 'flex';
    responseBox.style.justifyContent = 'center';
    responseBox.style.gap = '20px';  // Adds spacing between buttons
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
                question_id: currentQuestionId,
                user_response: answer,
                question_order: question_order
            })
        })
        .then(response => response.json())
        .then(data => {
            if (data.message === 'stumped') {
                // Display the "stumped" form when no eligible characters remain
                displayStumpedForm(data.prompt);
            } else if (data.guessed_character) {
                // Display guessed character, character show, and image if available
                character_guess = data.guessed_character;
                character_show = data.character_show;
                image_url = data.image_url ? data.image_url : null;

                document.getElementById('question-box').innerHTML = `
                    <h2>Are you ${character_guess} from ${character_show}?</h2>
                    ${image_url ? `<div id="image-container" style="text-align: center;">
                        <img src="${image_url}" alt="Character Image" style="width: 200px; height: 200px; object-fit: cover;">
                    </div>` : ''}
                `;

                document.getElementById('response-box').innerHTML = `
                    <button id="correct-button" onclick="submitGuessResponse(true)">Correct</button>
                    <button id="incorrect-button" onclick="submitGuessResponse(false)">Incorrect</button>
                `;
            } else {
                // Continue asking questions
                displayQuestion(data.next_question.question_text);
                currentQuestionId = data.next_question.question_id;  // Update to the new question ID
            }
        })
        .catch(error => {
            console.error('Error submitting answer:', error);
        });
    }
}

function displayStumpedForm(promptMessage) {
    document.getElementById('question-box').innerHTML = `<h2>${promptMessage}</h2>`;
    document.getElementById('response-box').innerHTML = `
        <form id="stumped-form">
            <label for="character-name">Your Character's Name:</label><br>
            <input type="text" id="character-name" name="character-name"><br>
            <label for="character-show">What show/film are they in?:</label><br>
            <input type="text" id="character-show" name="character-show"><br>
            <label for="new-question">What new question should I ask that is true for you?:</label><br>
            <input type="text" id="new-question" name="new-question"><br>
            <button type="submit" onclick="submitNewCharacter(event)">Submit</button>
        </form>
    `;
}

function validateForm() {
    const characterName = document.getElementById('character-name').value;
    const characterShow = document.getElementById('character-show').value;
    const newQuestion = document.getElementById('new-question').value;
    
    const allowedCharacters = /^[A-Za-z0-9 ,.!?'-]+$/;

    if (!allowedCharacters.test(characterName)) {
        alert("Character name contains invalid characters. Please avoid special characters like quotes.");
        return false;
    }
    
    if (!allowedCharacters.test(characterShow)) {
        alert("Character show contains invalid characters. Please avoid special characters like quotes.");
        return false;
    }

    if (!allowedCharacters.test(newQuestion)) {
        alert("Question contains invalid characters. Please avoid special characters like quotes.");
        return false;
    }

    return true;
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
            displayNewGameButton();
        } else {
            document.getElementById('question-box').innerHTML = `<h2>You win! Add your character details below.</h2>`;
            displayNewCharacterForm(character_guess, character_show);
        }
    })
    .catch(error => {
        console.error('Error submitting guess response:', error);
    });
}

function displayNewGameButton() {
    document.getElementById('response-box').innerHTML = `
        <button id="new-game-button" onclick="startGame()">New Game</button>
    `;
}

function displayNewCharacterForm(guessed_character, guessed_show) {
    document.getElementById('response-box').innerHTML = `
        <h3>I guessed that you are: ${guessed_character} from ${guessed_show}</h3>
        <form id="new-character-form">
            <label for="character-name">Your Character's Name:</label><br>
            <input type="text" id="character-name" name="character-name"><br>
            <label for="character-show">What show/film are they in?:</label><br>
            <input type="text" id="character-show" name="character-show"><br>
            <label for="new-question">What question is true for you but not ${guessed_character} from ${guessed_show}?:</label><br>
            <input type="text" id="new-question" name="new-question"><br>
            <button type="submit" onclick="submitNewCharacter(event)">Submit</button>
        </form>
    `;
}

function submitNewCharacter(event) {
    event.preventDefault();

    if (!validateForm()) {
        return;
    }

    const characterName = document.getElementById('character-name').value;
    const newQuestion = document.getElementById('new-question').value;
    const characterShow = document.getElementById('character-show').value;

    fetch('https://cmxsilzill.execute-api.us-east-1.amazonaws.com/dev/add_character3', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            character_name: characterName,
            new_question: newQuestion,
            character_show: characterShow,
            session_id: session_id,
            previous_character: character_guess
        })
    })
    .then(response => response.json())
    .then(data => {
        document.getElementById('question-box').innerHTML = `<h2>Thanks! Your character has been added.</h2>`;
        document.getElementById('response-box').innerHTML = '';  // Clear the form
        displayNewGameButton();
    })
    .catch(error => {
        console.error('Error adding new character or question:', error);
    });
}

window.onload = startGame;

