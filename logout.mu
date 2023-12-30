#!/usr/bin/python3
import os
import main


def print_fields():
    print("`F00f`_`[Logout`:" + main.page_path + "/logout.mu`confirm=yes]`_`f")


try:
    link_id, remote_identity = main.handle_ids()
    main.print_header(link_id, reload=True)
    confirm = ""
    for env_variable in os.environ:
        if env_variable == "var_confirm":
            confirm = os.environ[env_variable]
    if len(main.query_database(f"SELECT user_id FROM users WHERE link_id = '{link_id}'")) == 0:
        print("\nyou are not logged in")
    elif confirm != "yes":
        print_fields()
    elif confirm == "yes":
        main.execute_sql(f"UPDATE users SET link_id = '0', remote_identity = '0', login_time = 0 WHERE link_id = '{link_id}'")
        print("\nLogged out")
        # submit a dummy value in order to force a reload
        print(f"`F00f`_`[Continue`:{main.page_path}/index.mu`reload=62323]`_`f")
    main.close_database()
except:
    print("An error occured")
