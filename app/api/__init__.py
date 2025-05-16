from flask import Flask, request, jsonify
import psycopg2
from psycopg2 import sql
from app import app

DB_CONFIG = {
    "dbname": "t_onl_db",
    "user": "t_onl_db",
    "password": "1234",
    "host": "localhost",
    "port": 5432
}

def get_db_connection():
    return psycopg2.connect(**DB_CONFIG)

    