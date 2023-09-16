#!/usr/bin/python3
import os
import main
import hashlib
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
    link_id = ""
    for env_variable in os.environ:
        if env_variable == "username":
            username = os.environ[env_variable]
        elif env_variable == "password":
            password = os.environ[env_variable]
        elif env_variable == "password_confirm":
            password_confirm = os.environ[env_variable]
        elif env_variable == "link_id":
            link_id = os.environ[env_variable]
    if len(link_id) != 32:
        print("something went wrong...")
    elif username == "":
        print_fields()
    elif len(username) < 4:
        print("username must be longer than 4 characters")
        print_fields()
    elif len(username) > 64:
        print("username must not be longer than 64 characters")
        print_fields()
    elif len(password) < 8:
        print("password must be longer than 8 characters")
        print_fields()
    elif not compare_digest(password, password_confirm):
        print("passwords do not match")
        print_fields()
    elif main.check_string_for_not_allowed_characters(username):
        print("character not allowed in username")
        print_fields()
    else:
        print("registering...")
        hashed_password = hashlib.blake2b(password).hexdigest()
        main.setup_db()
        main.execute_sql("INSERT INTO users (username, enabled, password, link_id) VALUES (%(username)s, 1, "
                         "%(hashed_password)s, %(link_id)s", {"username": username, "hashed_password":
            hashed_password, "link_id": link_id})
except:
    print("An error occured")
