let session_id = null;

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
        displayQuestion(data.question_text);
    });
}

function displayQuestion(question) {
    document.getElementById('question-box').innerHTML = `<h2>${question}</h2>`;
}

function submitAnswer(answer) {
    if (session_id) {
        fetch('https://cmxsilzill.execute-api.us-east-1.amazonaws.com/dev/submit_answer3', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                session_id: session_id,
                question_id: 1,  // Update with the current question ID
                user_response: answer,
                question_order: 1  // Update with the correct question order
            })
        })
        .then(response => response.json())
        .then(data => {
            displayQuestion(data.next_question.question_text);
        });
    }
}

window.onload = startGame;
