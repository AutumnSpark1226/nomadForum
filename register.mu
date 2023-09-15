#!/usr/bin/python3
import os
from tinydb import TinyDB
import main
from secrets import compare_digest


def print_fields():
    print("Username: `B444`<username`" + username + ">`b")
    print("Password: `B444`<!|password`>`b")
    print("Confirm Password: `B444`<!|password_confirm`>`b")
    print("`!`[Register`:/page/register.mu`*]`..")


main.print_header()
try:
    username = ""
    password = ""
    password_confirm = ""
    for env_variable in os.environ:
        if env_variable == "username":
            username = os.environ[env_variable]
        elif env_variable == "password":
            password = os.environ[env_variable]
        elif env_variable == "password_confirm":
            password_confirm = os.environ[env_variable]
    if len(username) < 4:
        print("username too short")
        print_fields()
    elif len(password) < 8:
        print("password too short")
        print_fields()
    elif not compare_digest(password, password_confirm):
        print("passwords do not match")
        print_fields()
    elif len(username) >= 4 and len(password) >= 8 and compare_digest(password, password_confirm):
        print("registering...")
        main.setup()
        userdb = TinyDB('~/.nomadForum/databases/users.json')
        # TODO register user
except:
    print("An error occured")
