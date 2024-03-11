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


import main
import os
import sys

from argon2.exceptions import VerificationError
from argon2 import PasswordHasher


def list_connections():
    query_results = main.query_database(f"SELECT remote_id, allow_login, send_notifications, public FROM connections WHERE username = '{username}'")
    for result in query_results:
        print(f">>Identity: {result[0]}")
        if result[1] == 1:
            print(f" Autologin: enabled  `F00f`_`[disable`:{main.page_path}/user_settings.mu`action=disable_autologin|value={result[0]}]`_`f")
        elif result[1] == 0:
            print(f" Autologin: disabled  `F00f`_`[enable`:{main.page_path}/user_settings.mu`action=enable_autologin|value={result[0]}]`_`f")
        # Notifications and profiles are not implemnted yet, so this is disabled
        # if result[2] == 1:
        #    print(f" Notifications: enabled  `F00f`_`[disable`:{main.page_path}/user_settings.mu`action=disable_notifications|value={result[0]}]`_`f")
        # elif result[2] == 0:
        #    print(f" Notifications: disabled  `F00f`_`[enable`:{main.page_path}/user_settings.mu`action=enable_notifications|value={result[0]}]`_`f")
        # if result[3] == 1:
        #    print(f" Show on profile: enabled  `F00f`_`[disable`:{main.page_path}/user_settings.mu`action=disable_public|value={result[0]}]`_`f")
        # elif result[3] == 0:
        #    print(f" Show on profile: disabled  `F00f`_`[enable`:{main.page_path}/user_settings.mu`action=enable_public|value={result[0]}]`_`f")
        print(f" `F00f`_`[Remove`:{main.page_path}/user_settings.mu`action=remove_connection|value={result[0]}]`_`f")
        print()


def print_fields():
    print(f">Settings    Username: {username}")
    print()
    list_connections()
    print(">>Password")
    if main.decrypt(main.query_database(f"SELECT password FROM users WHERE username = '{username}'")[0][0]) == "$nopassword$":
        print(" Disabled")
        print(" Set new password: `B444`<!|password`>`b")
        print(" Confirm password: `B444`<!|password_confirm`>`b")
        print(f" `F00f`_`[Enable password`:{main.page_path}/user_settings.mu`*|action=enable_password]`_`f")
    else:
        print(f" Enabled `F00f`_`[disable`:{main.page_path}/user_settings.mu`action=disable_password]`_`f")
        print(" Current password: `B444`<!|password_current`>`b")
        print(" Update password:  `B444`<!|password`>`b")
        print(" Confirm password: `B444`<!|password_confirm`>`b")
        print(f" `F00f`_`[Change password`:{main.page_path}/user_settings.mu`*|action=change_password]`_`f")
    print()
    print(">>Account deletion")
    print(f"`F00f`_`[Delete your account`:{main.page_path}/delete_account.mu]`_`f")


try:
    link_id, remote_identity = main.handle_ids()
    main.print_header(link_id, reload=True)
    action = ""
    value = ""
    password = ""
    password_confirm = ""
    password_current = ""
    for env_variable in os.environ:
        if env_variable == "var_action":
            action = os.environ[env_variable]
        elif env_variable == "var_value":
            value = os.environ[env_variable]
        elif env_variable == "field_password":
            password = os.environ[env_variable]
        elif env_variable == "field_password_confirm":
            password_confirm = os.environ[env_variable]
        elif env_variable == "field_password_current":
            password_current = os.environ[env_variable]
    query_result = main.query_database(f"SELECT username FROM users WHERE link_id = '{link_id}'")
    if len(query_result) != 1:
        print(">You are not logged in.")
    else:
        username = query_result[0][0]
        if action == "remove_connection":
            if len(value) != 32 or not value.isalnum():
                print("something went wrong...")
                main.close_database()
                sys.exit(0)
            query = main.query_database(f"SELECT allow_login FROM connections WHERE remote_id = '{value}' AND username = '{username}'")
            if len(query) != 1:
                print("something went wrong...")
                print(f"`F00f`_`[Reload`:{main.page_path}/user_settings.mu]`_`f")
                main.close_database()
                sys.exit(0)
            elif query[0][0] == 1:
                print(">This identity is used for logging in. You can't remove it. (Disable autologin first.)")
                print()
                print_fields()
            elif query[0][0] == 0:
                main.execute_sql(f"DELETE FROM connections WHERE remote_id = '{value}' AND allow_login = 0 AND username = '{username}'")
                print(">The identity has been removed.")
                print()
                print_fields()
            else:
                print("something went wrong...")
                main.close_database()
                sys.exit(0)
        elif action == "disable_autologin":
            if len(value) != 32 or not value.isalnum():
                print("something went wrong...")
                main.close_database()
                sys.exit(0)
            if main.decrypt(main.query_database(f"SELECT password FROM users WHERE username = '{username}'")[0][0]) == "$nopassword$" and value == remote_identity:
                print(">Deactivating autologin would lock you out of your account and is not permitted.")
                print()
                print_fields()
            else:
                main.execute_sql(f"UPDATE connections SET allow_login = 0 WHERE remote_id = '{value}' AND allow_login = 1 AND username = '{username}'")
                print(">Autologin disabled.")
                print()
                print_fields()
        elif action == "enable_autologin":
            if len(value) != 32 or not value.isalnum():
                print("something went wrong...")
                main.close_database()
                sys.exit(0)
            main.execute_sql(f"UPDATE connections SET allow_login = 1 WHERE remote_id = '{value}' AND allow_login = 0 AND username = '{username}'")
            print(">Autologin enabled.")
            print()
            print_fields()
        elif action == "enable_notifications":
            if len(value) != 32 or not value.isalnum():
                print("something went wrong...")
                main.close_database()
                sys.exit(0)
            main.execute_sql(f"UPDATE connections SET send_notifications = 1 WHERE remote_id = '{value}' AND send_notifications = 0 AND username = '{username}'")
            print(">Notifications enabled.")
            print()
            print_fields()
        elif action == "disable_notifications":
            if len(value) != 32 or not value.isalnum():
                print("something went wrong...")
                main.close_database()
                sys.exit(0)
            main.execute_sql(f"UPDATE connections SET send_notifications = 0 WHERE remote_id = '{value}' AND send_notifications = 1 AND username = '{username}'")
            print(">Notifications disabled.")
            print()
            print_fields()
        elif action == "enable_public":
            if len(value) != 32 or not value.isalnum():
                print("something went wrong...")
                main.close_database()
                sys.exit(0)
            main.execute_sql(f"UPDATE connections SET public = 1 WHERE remote_id = '{value}' AND public = 0 AND username = '{username}'")
            print(">This identity will be shown on your profile.")
            print()
            print_fields()
        elif action == "disable_public":
            if len(value) != 32 or not value.isalnum():
                print("something went wrong...")
                main.close_database()
                sys.exit(0)
            main.execute_sql(f"UPDATE connections SET public = 0 WHERE remote_id = '{value}' AND public = 1 AND username = '{username}'")
            print(">This identity will not be shown on your profile.")
            print()
            print_fields()
        elif action == "disable_password":
            if len(main.query_database(f"SELECT remote_id FROM connections WHERE remote_id = '{remote_identity}' AND username = '{username}' AND allow_login = 1")) == 1:
                main.execute_sql("UPDATE users SET password = '" + main.encrypt("$nopassword$") + f"' WHERE link_id = '{link_id}' AND username = '{username}'")
                print(">Your password has been disabled.")
                print()
                print_fields()
            else:
                print(">Disabling your password would lock you out of your account and is not permitted.")
                print()
                print_fields()
        elif action == "enable_password":
            if main.query_database(f"SELECT username FROM connections WHERE remote_id = '{remote_identity}' AND allow_login = 1")[0][0] == username:
                if len(password) < 8:
                    print(">Your password must be at least 8 characters long.\n")
                    print_fields()
                    main.close_database()
                    sys.exit(0)
                hasher = PasswordHasher()
                hashed_password = hasher.hash(password)
                try:
                    hasher.verify(hashed_password, password_confirm)
                except VerificationError:
                    print(">The entered passwords do not match.\n")
                    print_fields()
                    main.close_database()
                    sys.exit(0)
                prepared_password = main.encrypt(hashed_password)
                main.execute_sql(f"UPDATE users SET password = '{prepared_password}' WHERE link_id = '{link_id}' AND username = '{username}'")
                print(">Your password has been enabled.")
                print()
                print_fields()
            else:
                print(">Verification failed")
                print()
                print_fields()
        elif action == "change_password":
            hasher = PasswordHasher()
            hashed_password = main.decrypt(main.query_database(f"SELECT password FROM users WHERE username = '{username}'")[0][0])
            try:
                hasher.verify(hashed_password, password_current)
            except VerificationError:
                print(">You entered a wrong password.\n")
                print_fields()
                main.close_database()
                exit(0)
            if len(password) < 8:
                print(">Your password must be at least 8 characters long.\n")
                print_fields()
                main.close_database()
                sys.exit(0)
            hasher = PasswordHasher()
            hashed_password = hasher.hash(password)
            try:
                hasher.verify(hashed_password, password_confirm)
            except VerificationError:
                print(">The entered passwords do not match.\n")
                print_fields()
                main.close_database()
                sys.exit(0)
            prepared_password = main.encrypt(hashed_password)
            main.execute_sql(f"UPDATE users SET password = '{prepared_password}' WHERE link_id = '{link_id}' AND username = '{username}'")
            print(">Your password has been changed.")
            print()
            print_fields()
        else:
            print_fields()
    main.close_database()
except Exception:
    print("An error occured")
