// Симуляция получения данных с сервера
const fetchResults = () => {
    return new Promise(resolve => {
      setTimeout(() => {
        resolve({
          recommended: [3, 5, 8],
          selfStudy: [24, 56, 88],
          score: 8,
          total: 10,
          conclusion: 'Вывод'
        });
      }, 400); 
    });
  };
  
  async function renderResults() {
    const data = await fetchResults();
  
    const container = document.getElementById('results-content');
    container.innerHTML = `
      <p>Рекомендованные задания: ${data.recommended.join(', ')}</p>
      <p>Задания для самостоятельной работы: ${data.selfStudy.join(', ')}</p>
      <p>Набрано ${data.score} баллов из ${data.total}</p>
      <p>${data.conclusion}</p>
    `;
  }
  
  renderResults();
  