#!/usr/bin/python3
import os
import main
from argon2.exceptions import VerificationError
from argon2 import PasswordHasher


def print_fields():
    print("Username: `B444`<username`" + username + ">`b")
    print("Password: `B444`<!|password`>`b")
    print("Confirm Password: `B444`<!|password_confirm`>`b")
    print("`F00f`_`[Register`:" + main.page_path + "/register.mu`*]`_`f")
    print()
    print("Consider using a unique password. A malicious node owner could add a script that saves plaintext passwords because they cannot be hashed on the client.")


print("#!c=0")
try:
    username = ""
    password = ""
    password_confirm = ""
    link_id = ""
    for env_variable in os.environ:
        if env_variable == "field_username":
            username = os.environ[env_variable]
        elif env_variable == "field_password":
            password = os.environ[env_variable]
        elif env_variable == "field_password_confirm":
            password_confirm = os.environ[env_variable]
        elif env_variable == "link_id":
            link_id = os.environ[env_variable]
    main.setup_db()
    main.print_header(link_id, reload=True)
    if len(link_id) != 32 or not link_id.isalnum():
        print("something went wrong...")
        main.close_database()
        exit(0)
    if len(main.query_database(f"SELECT user_id FROM users WHERE link_id = '{link_id}'")) != 0:
        print("You are already logged in.")
    elif username == "":
        print_fields()
    elif len(username) < 4:
        print("Your username must be longer than 4 characters.\n")
        print_fields()
    elif len(username) > 64:
        print("Your username must not be longer than 64 characters.\n")
        print_fields()
    elif len(password) < 8:
        print("Your password must be at least 8 characters long.\n")
        print_fields()
    elif not main.check_username(username):
        print("Your username is not allowed due to forum policies.\n")
        print_fields()
    else:
        if len(main.query_database(f"SELECT user_id FROM users WHERE username = '{username}'")) != 0:
            print("This username already exists.\n")
            print_fields()
        else:
            hasher = PasswordHasher()
            hashed_password = hasher.hash(password)
            try:
                hasher.verify(hashed_password, password_confirm)
            except VerificationError:
                print("The entered passwords do not match.\n")
                print_fields()
                main.close_database()
                exit(0)
            prepared_password = main.encrypt(hashed_password)
            main.execute_sql(f"INSERT INTO users (username, password, link_id, login_time) VALUES ('{username}', '{prepared_password}', '{link_id}', unixepoch())")
            print("Registration successful!")
            print(f"Welcome to {main.forum_name}!")
            # submit a dummy value in order to force a reload
            print(f"`F00f`_`[Continue`:{main.page_path}/index.mu`reload=3542434]`_`f")
    main.close_database()
except:
    print("An error occured")
