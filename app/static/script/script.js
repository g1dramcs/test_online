let xhr = new XMLHttpRequest();


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
          alert('Ошибка! Сервер не отвечает')
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

let create_test = () => {

  data = {
      'Oper': 'Create Test',
      'Params': {
        'subject_id': 1
      }
  }

  send_req(data);
}

let delete_test = () => {

  data = {
      'Oper': 'Delete Test',
      'Params': {
          'id': 6
      }
  };

  send_req(data);
}

let create_question = () => {
  data = {
    'Oper': 'Create Question',
    'Params': {
        'test_id': 1,
        'text': "a",
        'answer': "a",
        'key': 1
    }
    };

  send_req(data);
} 

let delete_question = () => {
  data = {
    'Oper': 'Delete Question',
    'Params': {
        'id': 1
    }
  };

  send_req(data);
} 

let create_answer = () => {
  data = {
    'Oper': 'Create Answer',
    'Params': {
        'question_id': 2,
        'text': 'aaa'
    }
  };

  send_req(data);
} 


let delete_answer = () => {
  data = {
    'Oper': 'Delete Answer',
    'Params': {
        'id': 2
    }
  };

  send_req(data);
} 

async function auth_user() {
  
  let login = document.getElementById('login').value
  let password = document.getElementById('password').value
  let role = document.getElementById('role').value

  data = {
    'Oper': 'Auth User',
    'Params': {
      'login': login,
      'password': password,
      'role': role
    }
  }

  const res = await send_req(data)
  console.log(res)
  
  // check valid
  if (res.data.status) {
    console.log("Login success!")
    window.location.href = role;
  }
}




