#!/usr/bin/python3
import os
import uuid

import main


def print_fields() -> None:
    print(f"Comment: `B444`<content`{content}>`b")
    print(f"`F00f`_`[Post comment`:{main.page_path}/comment.mu`*|post_id={post_id}|parent={parent}]`_`f")


try:
    link_id, remote_identity = main.handle_ids()
    main.print_header(link_id, reload=True)
    content = ""
    post_id = ""
    parent = ""
    for env_variable in os.environ:
        if env_variable == "field_content":
            content = os.environ[env_variable]
        elif env_variable == "var_post_id":
            post_id = os.environ[env_variable]
        elif env_variable == "var_parent":
            parent = os.environ[env_variable]
    if len(main.query_database(f"SELECT user_id FROM users WHERE link_id = '{link_id}'")) == 0:
        print("you are not logged in")
    elif content == "":
        print_fields()
    elif post_id == "" or parent == "":
        print("something went wrong...")
        main.close_database()
        exit(0)
    elif not main.check_uuid(post_id):
        print("something went wrong...")
        main.close_database()
        exit(0)
    elif not (main.check_uuid(parent) or parent == "post"):
        print("something went wrong...")
        main.close_database()
        exit(0)
    elif main.query_database(f"SELECT locked FROM posts WHERE post_id = '{post_id}'")[0][0] != 0:
        print("This post is locked. You aren't allowed to leave a comment.")
        main.close_database()
        exit(0)
    elif len(main.query_database(f"SELECT numeric_id FROM posts WHERE post_id = '{post_id}'")) == 0:
        print("post not found")
    elif not (parent == "post" or len(main.query_database(f"SELECT numeric_id FROM comments WHERE comment_id = '{parent}' AND post_id = '{post_id}'")) == 1):
        print("comment not found")
    else:
        content = main.prepare_content(content)
        username = main.query_database(f"SELECT username FROM users WHERE link_id = '{link_id}'")[0][0]
        if main.query_database(f"SELECT enabled FROM users WHERE username = '{username}'")[0][0] != 1:
            print("Your account is disabled.")
            main.close_database()
            exit(0)
        elif len(main.query_database(f"SELECT numeric_id FROM comments WHERE content = '{content}' AND username = '{username}' AND unixepoch() < (changed + 600)")) != 0:
            print("spam protection triggered!")
            main.close_database()
            exit(0)
        elif len(main.query_database(f"SELECT numeric_id FROM comments WHERE username = '{username}' AND unixepoch() < (changed + 20)")) != 0:
            print("spam protection triggered!")
            main.close_database()
            exit(0)
        comment_id = str(uuid.uuid4())
        # this should not be very probable
        while len(main.query_database(f"SELECT numeric_id FROM comments WHERE comment_id = '{comment_id}'")) != 0:
            comment_id = str(uuid.uuid4())
        main.execute_sql(f"INSERT INTO comments (comment_id, post_id, parent, username, content, changed) VALUES ('{comment_id}', '{post_id}', '{parent}', '{username}', '{content}', unixepoch())")
        print(f"`F00f`_`[Visit post`:{main.page_path}/view.mu`post_id={post_id}]`_`f")
    main.close_database()
except:
    print("An error occured")
