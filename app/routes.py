from flask import render_template, flash, redirect, url_for
from app import app

@app.route('/')
def index():
    return render_template('enter.html')

@app.route('/auth')
def about():
    return render_template('auth.html')

@app.route('/main')
def main():
    return render_template('disciplineselect.html')

@app.route('/question')
def question():
    return render_template('question.html')

@app.route('/test_req')
def test_req():
    return render_template('index.html')

@app.route('/editor')
def editor():
    return render_template('editablequestion.html')