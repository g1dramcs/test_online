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

function loadQuestion(index) {
  const questionData = questions[index - 1];
  document.getElementById('question-text').innerText = questionData.text;

  const form = document.getElementById('answers-form');
  form.innerHTML = questionData.answers.map((ans, i) => `
    <label><input type="radio" name="answer" value="${i}"> ${ans}</label>
  `).join('');

  updateNav(index);
  updateButton(index);
}

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
