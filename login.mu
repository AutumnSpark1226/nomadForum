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
import sys

from argon2.exceptions import VerificationError
from argon2 import PasswordHasher


def print_fields():
    print("Username: `B444`<username`" + username + ">`b")
    print("Password: `B444`<!|password`>`b")
    print("`F00f`_`[Login`:" + main.page_path + "/login.mu`*]`_`f  `F00f`_`[Login and stay logged in`:" + main.page_path + "/login.mu`*|keep_login=yes]`_`f")


try:
    link_id, remote_identity = main.handle_ids()
    main.print_header(link_id, reload=True)
    username = ""
    password = ""
    keep_login = False
    for env_variable in os.environ:
        if env_variable == "field_username":
            username = os.environ[env_variable]
        elif env_variable == "field_password":
            password = os.environ[env_variable]
        elif env_variable == "var_keep_login" and os.environ[env_variable] == "yes":
            keep_login = True
    if len(main.query_database(f"SELECT user_id FROM users WHERE link_id = '{link_id}'")) != 0:
        print(">You are already logged in.")
    elif username == "":
        print_fields()
    elif len(username) < 4:
        print(">Your username must be longer than 4 characters.\n")
        print_fields()
    elif len(username) > 64:
        print(">Your username must not be longer than 64 characters.\n")
        print_fields()
    elif not main.check_username(username, allow_admin=True):
        print(">Your username is not allowed due to forum policies.\n")
        print_fields()
    else:
        if len(main.query_database(f"SELECT user_id FROM users WHERE username = '{username}'")) == 0:
            print(">You entered a wrong username or password.\n")
            print_fields()
        else:
            hasher = PasswordHasher()
            hashed_password = main.decrypt(main.query_database(
                f"SELECT password FROM users WHERE username = '{username}'")[0][0])
            try:
                hasher.verify(hashed_password, password)
            except VerificationError:
                print(">You entered a wrong username or password.\n")
                print_fields()
                main.close_database()
                sys.exit(0)
            # TODO rehash and/or reencrypt if needed
            if hasher.check_needs_rehash(hashed_password):
                hashed_password = hasher.hash(password)
                main.execute_sql("UPDATE users SET password = '" + main.encrypt(hashed_password) + f"' WHERE username = '{username}'")
            main.execute_sql(f"UPDATE users SET link_id = '{link_id}', login_time = unixepoch() WHERE username = '{username}'")
            print(">You logged in successfully.")
            if keep_login:
                if remote_identity != "":
                    if len(main.query_database(f"SELECT remote_id FROM connections WHERE username = '{username}' AND remote_id = '{remote_identity}'")) == 0:
                        if len(main.query_database(f"SELECT remote_id FROM connections WHERE remote_id = '{remote_identity}'")) != 0:
                            print("\n>This identity is already connected to an account. You won't stay logged in.")
                        else:
                            main.execute_sql(f"INSERT INTO connections (username, remote_id, allow_login) VALUES ('{username}', '{remote_identity}', 1)")
                    else:
                        main.execute_sql(f"UPDATE connections SET allow_login = 1 WHERE username = '{username}' AND remote_id = '{remote_identity}'")
                else:
                    print("\n>You are not identified.")
            print()
            print(f"`F00f`_`[Continue`:{main.page_path}/index.mu]`_`f")
    main.close_database()
except Exception:
    print("An error occured")
