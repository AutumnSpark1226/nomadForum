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
    print("Confirm this action by typing: 'Yes, I am sure!'")
    print("Confirmation: `B444`<confirmation`>`b")
    print("`F00f`_`[Delete account`:"
          + main.page_path + "/delete_account.mu`*]`_`f")
    print("`F00f`_`[Delete account and content`:"
          + main.page_path + "/delete_account.mu`*|delete_content=yes]`_`f")


def delete_comment_chain(comment_ids):
    for comment_id in comment_ids:
        main.execute_sql(f"DELETE FROM comments WHERE comment_id = '{comment_id[0]}'")
        comment_chain = main.query_database(f"SELECT comment_id FROM comments WHERE parent = '{comment_id[0]}'")
        delete_comment_chain(comment_chain)


try:
    link_id, remote_identity = main.handle_ids()
    main.print_header(link_id, reload=True)
    username = ""
    password = ""
    confirmation = ""
    delete_content = False
    for env_variable in os.environ:
        if env_variable == "field_username":
            username = os.environ[env_variable]
        elif env_variable == "field_password":
            password = os.environ[env_variable]
        elif env_variable == "field_confirmation":
            confirmation = os.environ[env_variable]
        elif env_variable == "var_delete_content" and os.environ[env_variable] == "yes":
            delete_content = True
    if username == "":
        print_fields()
    elif len(username) < 4:
        print(">Your username must be longer than 4 characters.\n")
        print_fields()
    elif len(username) > 64:
        print(">Your username must not be longer than 64 characters.\n")
        print_fields()
    elif not main.check_username(username):
        print(">This username is not allowed due to forum policies.\n")
        print_fields()
    else:
        if len(main.query_database(f"SELECT user_id FROM users WHERE username = '{username}'")) == 0:
            print(">You entered a wrong username or password.\n")
            print_fields()
            main.close_database()
            sys.exit(0)
        else:
            confirmed = False
            query_result = main.query_database(f"SELECT username FROM connections WHERE remote_id = '{remote_identity}' AND allow_login = 1")
            if len(query_result) == 1:
                if username == query_result[0][0]:
                    confirmed = True
            if len(password) >= 8:
                hasher = PasswordHasher()
                try:
                    hasher.verify(main.decrypt(main.query_database(f"SELECT password FROM users WHERE username = '{username}'")[0][0]), password)
                    confirmed = True
                except VerificationError:
                    print(">You entered a wrong username or password.\n")
                    print_fields()
                    main.close_database()
                    sys.exit(0)
            if main.query_database(f"SELECT enabled FROM users WHERE username = '{username}'")[0][0] != 1:
                print(">This account is disabled and cannot be deleted.")
                main.close_database()
                sys.exit(0)
            if confirmation != 'Yes, I am sure!':
                print(">Please confirm the deletion by typing: Yes, I am sure!\n")
                print_fields()
                main.close_database()
                sys.exit(0)
            if not confirmed:
                print(">Verification error\n")
                print_fields()
                main.close_database()
                sys.exit(0)
            else:
                main.execute_sql(f"DELETE FROM users WHERE username = '{username}'")
                main.execute_sql(f"DELETE FROM connections WHERE username = '{username}'")
                # modify / delete posts their comments
                if delete_content:
                    posts = main.query_database(f"SELECT post_id FROM posts WHERE username = '{username}'")
                    for post_id in posts:
                        main.execute_sql(f"DELETE FROM posts WHERE post_id = '{post_id[0]}'")
                        main.execute_sql(f"DELETE FROM comments WHERE post_id = '{post_id[0]}'")
                else:
                    main.execute_sql(f"UPDATE posts SET username = '[DELETED]' WHERE username = '{username}'")
                # modify / delete comment chains started by this user
                if delete_content:
                    comments = main.query_database(f"SELECT comment_id FROM comments WHERE username = '{username}'")
                    delete_comment_chain(comments)
                else:
                    main.execute_sql(f"UPDATE comments SET username = '[DELETED]' WHERE username = '{username}'")
                print(">Your account has been deleted.\n")
                # submit a dummy value in order to force a reload
                print(f"`F00f`_`[Home`:{main.page_path}/index.mu`reload=132]`_`f")
    main.close_database()
except:
    print("An error occured")
