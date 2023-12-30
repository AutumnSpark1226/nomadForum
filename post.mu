#!/usr/bin/python3
import os
import uuid

import main


def print_fields():
    print(f"Title: `B444`<title`{title}>`b")
    print(f"Content: `B444`<content`{content}>`b")
    print(f"`F00f`_`[Post`:{main.page_path}/post.mu`*]`_`f")


print("#!c=0")
try:
    link_id, remote_identity = main.handle_ids()
    main.print_header(link_id)
    title = ""
    content = ""
    for env_variable in os.environ:
        if env_variable == "field_title":
            title = os.environ[env_variable]
        elif env_variable == "field_content":
            content = os.environ[env_variable]
    if len(main.query_database(f"SELECT user_id FROM users WHERE link_id = '{link_id}'")) == 0:
        print("you are not logged in")
    elif title == "" and content == "":
        print_fields()
    elif len(title) < 4:
        print("title must be at least 4 characters")
        print_fields()
    else:
        title = main.prepare_title(title)
        content = main.prepare_content(content)
        username = main.query_database(f"SELECT username FROM users WHERE link_id = '{link_id}'")[0][0]
        if main.query_database(f"SELECT enabled FROM users WHERE username = '{username}'")[0][0] != 1:
            print("account disabled")
            main.close_database()
            exit(0)
        elif len(main.query_database(f"SELECT numeric_id FROM posts WHERE username = '{username}' AND unixepoch() < (changed + 30)")) != 0:
            print("spam protection triggered!")
            main.close_database()
            exit(0)
        elif len(main.query_database(f"SELECT numeric_id FROM posts WHERE (title = '{title}' OR content = '{content}') AND username = '{username}' AND unixepoch() < (changed + 600)")) != 0:
            print("spam protection triggered!")
            main.close_database()
            exit(0)
        post_id = str(uuid.uuid4())
        # this should not be very probable
        while len(main.query_database(f"SELECT numeric_id FROM posts WHERE post_id = '{post_id}'")) != 0:
            post_id = str(uuid.uuid4())
        main.execute_sql(f"INSERT INTO posts (post_id, username, title, content, changed) VALUES ('{post_id}', '{username}', '{title}', '{content}', unixepoch())")
        print(f"`F00f`_`[Visit post`:{main.page_path}/view.mu`post_id={post_id}]`_`f")
    main.close_database()
except:
    print("An error occured")
