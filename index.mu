#!/usr/bin/python3
import os

import main


try:
    link_id = ""
    for env_variable in os.environ:
        if env_variable == "link_id":
            link_id = os.environ[env_variable]
    if len(link_id) != 32 or not link_id.isalnum():
        print("something went wrong...")
        exit(0)
    main.setup_db()
    main.print_header(link_id)
    print("Main page (still WIP)")
    print(f"`F00f`_`[List posts`:{main.page_path}/list.mu]`_`f")
    print(f"`F00f`_`[Create post`:{main.page_path}/post.mu]`_`f")
    print(f"`F00f`_`[Delete your account`:{main.page_path}/delete_account.mu]`_`f")
    main.close_database()
except:
    print("An error occured")
