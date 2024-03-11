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
import uuid
import sys

import main


def print_fields():
    print(f"Title:   `B444`<40|title`{title}>`b")
    print()
    print(f"Content: `B444`<70|content`{content}>`b")
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
    if len(main.query_database(f"SELECT user_id FROM users WHERE link_id = '{link_id}'")) != 1:
        print(">You need to login first.")
    elif title == "" and content == "":
        print_fields()
    elif len(title) < 4:
        print(">The title must be at least 4 characters long.\n")
        print_fields()
    else:
        title = main.prepare_title(title)
        content = main.prepare_content(content)
        username = main.query_database(f"SELECT username FROM users WHERE link_id = '{link_id}'")[0][0]
        if main.query_database(f"SELECT enabled FROM users WHERE username = '{username}'")[0][0] != 1:
            print(">Your account is disabled.")
            main.close_database()
            sys.exit(0)
        elif len(main.query_database(f"SELECT numeric_id FROM posts WHERE username = '{username}' AND unixepoch() < (changed + 20)")) != 0:
            print(">Spam protection triggered!")
            main.close_database()
            sys.exit(0)
        elif len(main.query_database(f"SELECT numeric_id FROM posts WHERE (title = '{title}' OR content = '{content}') AND unixepoch() < (changed + 600)")) != 0:
            print(">Spam protection triggered!")
            main.close_database()
            sys.exit(0)
        post_id = str(uuid.uuid4())
        # this should not be very probable
        while len(main.query_database(f"SELECT numeric_id FROM posts WHERE post_id = '{post_id}'")) != 0:
            post_id = str(uuid.uuid4())
        main.execute_sql(f"INSERT INTO posts (post_id, username, title, content, changed) VALUES ('{post_id}', '{username}', '{title}', '{content}', unixepoch())")
        print(">Your post has been added.")
        print()
        print(f"`F00f`_`[Visit`:{main.page_path}/view.mu`post_id={post_id}]`_`f")
    main.close_database()
except:
    print("An error occured")
