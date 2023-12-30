#!/usr/bin/python3
import main


try:
    link_id, remote_identity = main.handle_ids()
    main.print_header(link_id)
    print("Main page (still WIP)")
    print(f"`F00f`_`[List posts`:{main.page_path}/list.mu]`_`f")
    print(f"`F00f`_`[Create post`:{main.page_path}/post.mu]`_`f")
    print(f"`F00f`_`[Delete your account`:{main.page_path}/delete_account.mu]`_`f")
    main.close_database()
except:
    print("An error occured")
