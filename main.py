import os
import sqlite3
from sqlite3 import Connection, Cursor

connection: Connection
cursor: Cursor


def does_table_exist(table_name: str):
    tables = query_database("SELECT name FROM sqlite_schema WHERE type ='table' AND name NOT LIKE 'sqlite_%'")
    return table_name in tables


def setup_db():
    global connection, cursor
    print("setup")
    if not os.path.isdir("~/.nomadForum"):
        os.mkdir("~/.nomadForum")
    connection = sqlite3.connect("~/.nomadForum/database.db")
    cursor = connection.cursor()
    if not does_table_exist("users"):
        execute_sql(
            "CREATE TABLE users (userid INTEGER NOT NULL UNIQUE PRIMARY KEY AUTOINCREMENT, username TEXT NOT NULL, "
            "enabled INTEGER NOT NULL, password TEXT NOT NULL, link_id TEXT)")
    # TODO database cleanup


def execute_sql(command: str):
    cursor.execute(command)
    connection.commit()


def query_database(command: str):
    result = cursor.execute(command)
    return result.fetchall()


def check_string_for_not_allowed_characters(string: str):
    return "," in string or ";" in string or ")" in string or "(" in string or "'" in string or '"' in string


def print_header():
    print("> WIP")
