from flask import Flask, request, jsonify
import psycopg2
from psycopg2 import sql
from app import app

DB_CONFIG = {
<<<<<<< HEAD
    "dbname": "test_online_db",
    "user": "test_online_db",
=======
    "dbname": "test_online_db_v2",
    "user": "test_online_db_v2",
>>>>>>> 40affd6 (Update some pages and style. Added admin and teacher panels)
    "password": "1234",
    "host": "localhost",
    "port": 5432
}

def get_db_connection():
    return psycopg2.connect(**DB_CONFIG)

    