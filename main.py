import sqlite3
from sqlite3 import Connection, Cursor

connection: Connection
cursor: Cursor


def setup_db():
    global connection, cursor
    print("setup")
    # TODO check for data folders
    # TODO database cleanup
    connection = sqlite3.connect("tutorial.db")
    cursor = connection.cursor()


def execute_sql(command: str):
    # TODO sanitize the sql query
    cursor.execute(command)
    connection.commit()


def query_database(command: str):
    # TODO sanitize the sql query
    result = cursor.execute(command)
    return result.fetchall()


def print_header():
    print("> WIP")
