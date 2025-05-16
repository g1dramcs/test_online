<<<<<<< HEAD
const totalQuestions = 5;
let currentQuestion = 1;

const questions = Array.from({ length: totalQuestions }, (_, i) => ({
  text: `${i + 1}. Текст вопроса номер`,
  answers: [
    `Вариант ответа 1`,
    `Вариант ответа 2`,
    `Вариант ответа 3`,
    `Вариант ответа 4`,
  ],
}));

// типо загрузка всех вопросов
=======
let currentQuestion = 1;


// const questions = Array.from({ length: totalQuestions }, (_, i) => ({
//   text: `${i + 1}. Текст вопроса номер`,
//   answers: [
//     `Вариант ответа 1`,
//     `Вариант ответа 2`,
//     `Вариант ответа 3`,
//     `Вариант ответа 4`,
//   ],
// }));

const data = {
  "questions": [
      {
          "id": 4,
          "text": "Ответ 1",
          "answers": [
              {
                  "id": 1,
                  "text": "Ответ 1"
              },
              {
                  "id": 2,
                  "text": "ответ 2"
              },
              {
                  "id": 3,
                  "text": "ответ 3"
              },
              {
                  "id": 4,
                  "text": "ответ 4"
              }
          ]
      },
      {
          "id": 5,
          "text": "Ответ 2",
          "answers": [
              {
                  "id": 5,
                  "text": "ответ 5.1"
              },
              {
                  "id": 6,
                  "text": "ответ 5.2"
              },
              {
                  "id": 7,
                  "text": "ответ 5.3"
              },
              {
                  "id": 8,
                  "text": "ответ 5.4"
              }
          ]
      },
      {
          "id": 6,
          "text": "Ответ 3",
          "answers": [
              {
                  "id": 9,
                  "text": "ответ 6.4"
              },
              {
                  "id": 10,
                  "text": "ответ 6.3"
              },
              {
                  "id": 11,
                  "text": "ответ 6.2"
              },
              {
                  "id": 12,
                  "text": "ответ 6.1"
              }
          ]
      },
      {
          "id": 7,
          "text": "не связан с тестом",
          "answers": null
      }
  ]
};

const totalQuestions = data.questions.length - 1;

const questions = data.questions.filter(q => Array.isArray(q.answers));
const container = document.getElementById('questions-container');

// типо загрузка всех вопросов от старой страницы
>>>>>>> 40affd6 (Update some pages and style. Added admin and teacher panels)

function loadQuestion(index) {
  const questionData = questions[index - 1];
  document.getElementById('question-text').innerText = questionData.text;

  const form = document.getElementById('answers-form');
  form.innerHTML = questionData.answers.map((ans, i) => `
<<<<<<< HEAD
    <label><input type="radio" name="answer" value="${i}"> ${ans}</label>
=======
    <label><input type="radio" name="answer" value="${i}"> ${ans.text}</label>
>>>>>>> 40affd6 (Update some pages and style. Added admin and teacher panels)
  `).join('');

  updateNav(index);
  updateButton(index);
}

<<<<<<< HEAD
=======

// скрипт от новой страницы
// questions.forEach((question, qIndex) => {
//   const questionDiv = document.createElement('div');
//   questionDiv.classList.add('question-block');
//   questionDiv.innerHTML = `
//     <div class="question-text">${qIndex + 1}. ${question.text}</div>
//     <form class="answers" data-question-id="${question.id}">
//       ${question.answers.map(answer => `
//         <label>
//           <input type="radio" name="question_${question.id}" value="${answer.id}">
//           ${answer.text}
//         </label>
//       `).join('')}
//     </form>
//   `;
//   container.appendChild(questionDiv);
// });


>>>>>>> 40affd6 (Update some pages and style. Added admin and teacher panels)
const send_req = (req_data) => {
  return new Promise((resolve, reject) => {
    const xhr = new XMLHttpRequest();
    xhr.open('POST', 'api/send_req', true);
    xhr.setRequestHeader('Content-Type', 'application/json; charset=UTF-8');

    xhr.onreadystatechange = () => {
      if (xhr.readyState === 4) {
        if (xhr.status >= 200 && xhr.status < 300) { // Исправлена проверка статуса
          try {
            const response = JSON.parse(xhr.responseText);
            resolve(response); // Возвращаем результат через Promise
          } catch (e) {
            reject(new Error('Failed to parse JSON'));
          }
        } else {
          reject(new Error(xhr.statusText || 'Request failed'));
        }
      }
    };

    xhr.onerror = () => {
      reject(new Error('Network error interrupt'));
    };

    xhr.send(JSON.stringify(req_data));
  });
};

let get_test = () => {

  data = {
      'Oper': 'Get Test',
      'Params': {
          'id': 1
      }
  }

  send_req(data);
}

// варианты ответа на вопрос

function updateNav(current) {
  const nav = document.getElementById('nav-questions');
  nav.innerHTML = '';
  for (let i = 1; i <= totalQuestions; i++) {
    const btn = document.createElement('button');
    btn.textContent = i;
    if (i === current) btn.classList.add('active');
    btn.addEventListener('click', () => {
      currentQuestion = i;
      loadQuestion(currentQuestion);
    });
    nav.appendChild(btn);
  }
}

function updateButton(index) {
  const btn = document.getElementById('next-btn');
  if (index === totalQuestions) {
    btn.textContent = 'Готово';
    btn.onclick = () => alert('Тест завершён!');
  } else {
    btn.textContent = 'Далее';
    btn.onclick = () => {
      currentQuestion++;
      loadQuestion(currentQuestion);
    };
  }
} 

loadQuestion(currentQuestion);
