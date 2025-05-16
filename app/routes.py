from flask import render_template, flash, redirect, request, url_for
from app.api import get_db_connection
import json
from app import app

@app.route('/')
def index():
    return render_template('enter.html')

@app.route('/auth')
def about():
    return render_template('auth.html')

@app.route('/student')
def main():
    return render_template('disciplineselect.html')

@app.route('/question')
def question():
    return render_template('question.html')

@app.route('/test_req')
def test_req():
    return render_template('test_req.html')


@app.route('/admin')
def admin():
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute('SELECT public.test_api(%s)', (json.dumps({"Oper":"Get Users"}), ))
            res = cur.fetchone()[0]
    return render_template('admin.html', users=res)

@app.route('/admin/add_user',  methods=['GET', 'POST'])
def add_user():
    if request.method == 'POST':

        user_data = {
            "Oper": "Create User",
            "Params": {
                "login": request.form.get('login'),
                "password": request.form.get('password'),
                "name": request.form.get('name'),
                "surname": request.form.get('surname'),
                "role": request.form.get('role')
            }
        }
  
        
        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute('SELECT public.test_api(%s)', (json.dumps(user_data),))
                res = cur.fetchone()[0]
    return redirect(url_for('admin'))


@app.route('/admin/delete_user',  methods=['GET', 'POST'])
def delete_user():
    if request.method == 'POST':

        user_data = {
            "Oper": "Delete User",
            "Params": {
                "id": request.form.get('id'),
            }
        }
        
        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute('SELECT public.test_api(%s)', (json.dumps(user_data),))
                res = cur.fetchone()[0]
    return redirect(url_for('admin'))



@app.route('/teacher')
def teacher():
    with get_db_connection() as conn:
        with conn.cursor() as cur:

            cur.execute('SELECT public.test_api(%s)', (json.dumps({"Oper":"Get Subjects"}), ))
            subjects = cur.fetchone()[0].get('subjects', [])
            
            tests_by_subject = {}
            for subject in subjects:
                cur.execute('SELECT public.test_api(%s)', 
                           (json.dumps({
                               "Oper": "Get Tests By Subject",
                               "Params": {"subject_id": subject['id']}
                           }), ))
                res = cur.fetchone()[0]
                tests_by_subject[subject['id']] = res.get('tests', [])
    
    return render_template('teacher.html', 
                         subjects=subjects,
                         tests_by_subject=tests_by_subject)

@app.route('/editor/<int:test_id>')
def editor(test_id):
    print("Я родился")
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute('SELECT public.test_api(%s)', 
                       (json.dumps({
                           "Oper": "Get Test",
                           "Params": {"id": test_id}
                       }), ))
            res = cur.fetchone()[0]
    
    if 'error' in res:
        return "Тест не найден", 404
    
    if res["questions"] == None:
        questions = []
    
    questions = res.get('questions', [])
    return render_template('editor.html', questions=questions, test_id=test_id)

@app.route('/add_question', methods=['POST'])
def add_question():
    question_data = {
        "Oper": "Create Question",
        "Params": {
            "test_id": request.form.get('test_id'),
            "text": request.form.get('question_text'),
            "answer": "",
            "key": 0
        }
    }
    
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute('SELECT public.test_api(%s)', (json.dumps(question_data),))
            res = cur.fetchone()[0]
    
    return redirect(url_for('editor', test_id=request.form.get('test_id')))

@app.route('/delete_question', methods=['POST'])
def delete_question():
    question_data = {
        "Oper": "Delete Question",
        "Params": {
            "id": request.form.get('question_id')
        }
    }
    
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute('SELECT public.test_api(%s)', (json.dumps(question_data),))
            res = cur.fetchone()[0]
    
    return redirect(url_for('editor', test_id=request.form.get('test_id')))

@app.route('/add_answer', methods=['POST'])
def add_answer():
    answer_data = {
        "Oper": "Create Answer",
        "Params": {
            "question_id": request.form.get('question_id'),
            "text": request.form.get('answer_text'),
            "correct": request.form.get('correct', 'false') == 'true'
        }
    }
    
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute('SELECT public.test_api(%s)', (json.dumps(answer_data),))
            res = cur.fetchone()[0]
    
    return redirect(url_for('editor', test_id=request.form.get('test_id')))

@app.route('/delete_answer', methods=['POST'])
def delete_answer():
    answer_data = {
        "Oper": "Delete Answer",
        "Params": {
            "id": request.form.get('answer_id')
        }
    }
    
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute('SELECT public.test_api(%s)', (json.dumps(answer_data),))
            res = cur.fetchone()[0]
    
    return redirect(url_for('editor', test_id=request.form.get('test_id')))

