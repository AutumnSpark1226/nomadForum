#!/usr/bin/python3

# nomadForum - a forum on the NomadNetwork
# Copyright (C) 2023-2024  AutumnSpark1226
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.


import os
import main
from argon2.exceptions import VerificationError
from argon2 import PasswordHasher


def print_fields():
    print("Please read the `F00f`_`[rules`:" + main.page_path + "/rules.mu`*]`_`f")
    print("Username:        `B444`<username`" + username + ">`b")
    print("Password:        `B444`<!|password`>`b")
    print("Repeat password: `B444`<!|password_confirm`>`b")
    print("`F00f`_`[Register`:" + main.page_path + "/register.mu`*]`_`f  `F00f`_`[Register and stay logged in`:" + main.page_path + "/register.mu`*|keep_login=yes]`_`f")
    print()
    print("Consider using a unique password. A malicious node owner could add a script that saves plaintext passwords because they cannot be hashed on the client.")


try:
    link_id, remote_identity = main.handle_ids()
    main.print_header(link_id, reload=True)
    username = ""
    password = ""
    password_confirm = ""
    keep_login = False
    for env_variable in os.environ:
        if env_variable == "field_username":
            username = os.environ[env_variable]
        elif env_variable == "field_password":
            password = os.environ[env_variable]
        elif env_variable == "field_password_confirm":
            password_confirm = os.environ[env_variable]
        elif env_variable == "var_keep_login" and os.environ[env_variable] == "yes":
            keep_login = True
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
            if keep_login and remote_identity != "":
                main.execute_sql(f"UPDATE users SET remote_identity = '{remote_identity}' WHERE username = '{username}'")
            print(">Registration successful!")
            print(f"Welcome to {main.forum_name}!")
            print()
            # submit a dummy value in order to force a reload
            print(f"`F00f`_`[Continue`:{main.page_path}/index.mu`reload=3542434]`_`f")
    main.close_database()
except:
    print("An error occured")
