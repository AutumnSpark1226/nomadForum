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


from argon2 import PasswordHasher
from argon2.exceptions import VerificationError
from getpass import getpass
import sys
import os


try:
    sys.path.extend([os.path.abspath(os.path.join(os.path.dirname(__file__), os.pardir))])
    import main
    main.setup_db()
    username = input("Enter a username: ")
    if len(main.query_database(f"SELECT user_id FROM users WHERE username = '{username}'")) != 0:
        print("This account already exists")
    elif main.check_username(username, allow_admin=True):
        print("This username is not allowed")
    else:
        main.execute_sql(f"INSERT INTO settings (key, value) VALUES ('admin_username', '{username}')")
        password = getpass("Please enter a password: ")
        if len(password) < 8:
            print("Your password must be at least 8 characters long.\n")
        hasher = PasswordHasher()
        hashed_password = hasher.hash(password)
        password = getpass("Please confirm your password: ")
        try:
            hasher.verify(hashed_password, password)
        except VerificationError:
            print("The entered passwords do not match.")
            main.close_database()
            exit(0)
        prepared_password = main.encrypt(hashed_password)
        main.execute_sql(f"INSERT INTO users (username, password) VALUES ('{username}', '{prepared_password}')")
        print("Registration successful!")
        print(f"The admin account '{username}' has been created")
    main.close_database()
except:
    print("An error occured")
