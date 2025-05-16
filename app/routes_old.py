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
    return render_template('question_old.html')

@app.route('/test_req')
def test_req():
    return render_template('test_req.html')

@app.route('/editor')
def editor():
    return render_template('editablequestion.html')

@app.route('/teacher')
def teacher():
    return render_template('teacher.html')


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
        print(user_data)
        
        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute('SELECT public.test_api(%s)', (json.dumps(user_data),))
                res = cur.fetchone()[0]
    return redirect(url_for('admin'))

                
