#!/usr/bin/python3
import os
import main
from argon2.exceptions import VerificationError
from argon2 import PasswordHasher


def print_fields():
    print("Username: `B444`<username`" + username + ">`b")
    print("Password: `B444`<!|password`>`b")
    print("`F00f`_`[Login`:" + main.page_path + "/login.mu`*]`_`f")


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
        elif env_variable == "link_id":
            link_id = os.environ[env_variable]
    if len(link_id) != 32 and not link_id.isalnum():
        print("something went wrong...")
        exit(0)
    main.setup_db()
    main.print_header(link_id, reload=True)
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
    elif not main.check_username(username):
        print("Your username is not allowed due to forum policies.\n")
        print_fields()
    else:
        if len(main.query_database(f"SELECT user_id FROM users WHERE username = '{username}'")) == 0:
            print("You entered a wrong username or password.\n")
            print_fields()
        elif main.query_database(f"SELECT enabled FROM users WHERE username = '{username}'")[0][0] != 1:
            print("Your account is disabled. You are not allowed to log in.")
            main.close_database()
            exit(0)
        else:
            hasher = PasswordHasher()
            hashed_password = main.decrypt(main.query_database(f"SELECT password FROM users WHERE username = '{username}'")[0][0])
            try:
                hasher.verify(hashed_password, password)
            except VerificationError:
                print("You entered a wrong username or password.\n")
                print_fields()
                main.close_database()
                exit(0)
            if hasher.check_needs_rehash(hashed_password):
                hashed_password = hasher.hash(password)
                main.execute_sql(f"UPDATE users SET password = '{main.encrypt(hashed_password)}' WHERE username = '{username}'")
            main.execute_sql(f"UPDATE users SET link_id = '{link_id}', login_time = unixepoch() WHERE username = '{username}'")
            # TODO rehash and/or reencrypt
            print("You logged in successfully.")
            # submit a dummy value in order to force a reload
            print("`F00f`_`[Continue`:" + main.page_path + "/index.mu`reload=376]`_`f")
    main.close_database()
except:
    print("An error occured")
