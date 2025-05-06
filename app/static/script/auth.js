// document.getElementById('auth').addEventListener('submit', (event) => {
//     // event.preventDefault(); // Предотвращаем отправку формы по умолчанию
//     console.log(event)
//     let formData = new FormData(this); // Создаем объект FormData из формы
//     let data = {};
//     for(let pair of formData.entries()) {
//         data[pair[0]] = pair[1];
//     }
//     let jsonData = JSON.stringify(data)
//     console.log(jsonData)
//   });

form = document.getElementById('auth').addEventListener('submit', function(e) {
    e.preventDefault();
    let formData = new FormData(form);
    let data = {};
    formData.forEach(function(value, key){
        data[key] = value
    })
    let jsonData = JSON.stringify(data)
    console.log(jsonData)
    console.log(formData.entries)
})

