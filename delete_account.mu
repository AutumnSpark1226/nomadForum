#!/usr/bin/python3
import os
import main
from argon2.exceptions import VerificationError
from argon2 import PasswordHasher


def print_fields():
    print("Username: `B444`<username`" + username + ">`b")
    print("Password: `B444`<!|password`>`b")
    print("`F00f`_`[Delete account`:"
          + main.page_path + "/delete_account.mu`*]`_`f")
    print("`F00f`_`[Delete account and content`:"
          + main.page_path + "/delete_account.mu`*|delete_content=yes]`_`f")


def delete_comment_chain(comment_ids):
    for comment_id in comment_ids:
        main.execute_sql(f"DELETE FROM comments WHERE comment_id = '{comment_id[0]}'")
        comment_chain = main.query_database(f"SELECT comment_id FROM comments WHERE parent = '{comment_id[0]}'")
        delete_comment_chain(comment_chain)


print("#!c=0")
try:
    username = ""
    password = ""
    password_confirm = ""
    link_id = ""
    delete_content = False
    for env_variable in os.environ:
        if env_variable == "field_username":
            username = os.environ[env_variable]
        elif env_variable == "field_password":
            password = os.environ[env_variable]
        elif env_variable == "var_delete_content" and os.environ[env_variable] == "yes":
            delete_content = True
        elif env_variable == "link_id":
            link_id = os.environ[env_variable]
    main.setup_db()
    main.print_header(link_id, reload=True)
    if len(link_id) != 32 or not link_id.isalnum():
        print("something went wrong...")
        main.close_database()
        exit(0)
    if username == "":
        print_fields()
    elif len(username) < 4:
        print("Your username must be longer than 4 characters.\n")
        print_fields()
    elif len(username) > 64:
        print("Your username must not be longer than 64 characters.\n")
        print_fields()
    elif not main.check_username(username):
        print("This username is not allowed due to forum policies.\n")
        print_fields()
    else:
        if len(main.query_database(f"SELECT user_id FROM users WHERE username = '{username}'")) == 0:
            print("You entered a wrong username or password.\n")
            print_fields()
        else:
            hasher = PasswordHasher()
            try:
                hasher.verify(main.decrypt(main.query_database(f"SELECT password FROM users WHERE username = '{username}'")[0][0]), password)
            except VerificationError:
                print("You entered a wrong username or password.\n")
                print_fields()
                main.close_database()
                exit(0)
            if main.query_database(f"SELECT enabled FROM users WHERE username = '{username}'")[0][0] != 1:
                print("This account is disabled and cannot be deleted.")
                main.close_database()
                exit(0)
            main.execute_sql(f"DELETE FROM users WHERE username = '{username}'")
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
            print("Your account has been deleted.\n")
            # submit a dummy value in order to force a reload
            print(f"`F00f`_`[Home`:{main.page_path}/index.mu`reload=132]`_`f")
    main.close_database()
except:
    print("An error occured")
