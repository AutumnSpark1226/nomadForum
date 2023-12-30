#!/usr/bin/python3
import os
import math

import main

try:
    link_id, remote_identity = main.handle_ids()
    main.print_header(link_id)
    page = 0
    sort = "new"
    for env_variable in os.environ:
        if env_variable == "var_page":
            page = int(os.environ[env_variable])
        elif env_variable == "var_sort":
            sort = os.environ[env_variable]
    if sort == "old":
        order_sql_statement = "changed ASC"
    elif sort == "title_asc":
        order_sql_statement = "title COLLATE NOCASE ASC"
    elif sort == "title_desc":
        order_sql_statement = "title COLLATE NOCASE DESC"
    else:
        order_sql_statement = "changed DESC"
    print()
    print(f"Sort: `F00f`_`[New`:{main.page_path}/list.mu`sort=new]`_`f  `F00f`_`[Old`:{main.page_path}/list.mu`sort=old]`_`f  `F00f`_`[Title`:{main.page_path}/list.mu`sort=title_asc]`_`f  `F00f`_`[Title (reverse)`:{main.page_path}/list.mu`sort=title_desc]`_`f")
    print()
    posts = main.query_database(f"SELECT post_id, username, title, datetime(changed, 'unixepoch') FROM posts ORDER BY {order_sql_statement}")
    posts_cut_to_page = posts[page * 25:(page + 1) * 25]
    for post_data in posts_cut_to_page:
        post_title = post_data[2].replace("\\`", "\'")  # "`" breaks the link
        # "]" breaks the link
        post_title = post_title.replace("[", "(")
        post_title = post_title.replace("]", ")")
        print("-")
        print(f"{post_data[1]}: `F00f`_`[{post_title}`:{main.page_path}/view.mu`post_id={post_data[0]}]`_`f   ({post_data[3]} (UTC))")
    print("-")
    max_page_count = math.floor((len(posts) - 1) / 25)
    print(f"`F00f`_`[<< Previous page`:{main.page_path}/list.mu`sort={sort}|page={str(max(0, page - 1))}]`_`f  Page {str(page + 1)}  `F00f`_`[Next page >>`:{main.page_path}/list.mu`sort={sort}|page={str(min(max_page_count, page + 1))}]`_`f")
    main.close_database()
except:
    print("An error occured")
