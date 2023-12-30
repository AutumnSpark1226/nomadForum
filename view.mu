#!/usr/bin/python3
import os

import main


def print_fields():
    print(f"Post ID: `B444`<post_id`{post_id}>`b")
    print(f"`F00f`_`[Visit post`:{main.page_path}/view.mu`*]`_`f")


def display_comment(parent: str, indent: int):
    comments = main.query_database(f"SELECT comment_id, username, content, datetime(changed, 'unixepoch') FROM comments WHERE post_id = '{post_id}' AND parent = '{parent}'")
    for comment_data in comments:
        print(">" * (2 + indent) + f"Posted {comment_data[3]} (UTC) by {comment_data[1]}")
        print(comment_data[2])
        if not comments_locked:
            print(f"`F00f`_`[Add a comment`:{main.page_path}/comment.mu`post_id={post_id}|parent={comment_data[0]}]`_`f")
        display_comment(comment_data[0], indent + 1)


try:
    link_id, remote_identity = main.handle_ids()
    main.print_header(link_id)
    post_id = ""
    for env_variable in os.environ:
        if env_variable == "var_post_id":
            post_id = os.environ[env_variable]
        elif env_variable == "field_post_id":
            post_id = os.environ[env_variable]
    if not main.check_uuid(post_id):
        print("invalid id")
        print_fields()
    elif post_id == "":
        print_fields()
    elif len(main.query_database(f"SELECT numeric_id FROM posts WHERE post_id = '{post_id}'")) == 0:
        print("post not found")
        print_fields()
    else:
        post_data = main.query_database(f"SELECT post_id, username, title, content, datetime(changed, 'unixepoch') FROM posts WHERE post_id = '{post_id}'")[0]
        print('`F222`B999')
        print(f"`!{post_data[2]}`!")
        print("``")
        print(f"Posted: {post_data[4]} (UTC) by {post_data[1]}")
        print("-")
        print(f"{post_data[3]}")
        print("``")
        print("-")
        if main.query_database(f"SELECT locked FROM posts WHERE post_id = '{post_id}'")[0][0] == 0:
            comments_locked = False
            comment_link = f"`F00f`_`[Add comment`:{main.page_path}/comment.mu`post_id={post_id}|parent=post]`_`f"
        else:
            comments_locked = True
            comment_link = "[LOCKED]"
        print(f"Comments    {comment_link}")
        # view comments
        display_comment("post", 0)
    main.close_database()
except:
    print("An error occured")
