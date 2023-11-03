#!/usr/bin/python3
import os
import main


def print_fields():
    print("`F00f`_`[Logout`:" + main.page_path + "/logout.mu`confirm=yes]`_`f")


print("#!c=0")
try:
    confirm = ""
    link_id = ""
    for env_variable in os.environ:
        if env_variable == "var_confirm":
            confirm = os.environ[env_variable]
        elif env_variable == "link_id":
            link_id = os.environ[env_variable]
    main.setup_db()
    if len(link_id) != 32 and not link_id.isalnum():
        print("something went wrong...")
        exit(0)
    if len(main.query_database(f"SELECT user_id FROM users WHERE link_id = '{link_id}'")) == 0:
        main.print_header(link_id)
        print("\nyou are not logged in")
    elif confirm != "yes":
        main.print_header(link_id)
        print_fields()
    else:
        main.execute_sql(f"UPDATE users SET link_id = '0', login_time = 0 WHERE link_id = '{link_id}'")
        main.print_header(link_id, reload=True)
        print("\nLogged out")
        # submit a dummy value in order to force a reload
        print("`F00f`_`[Continue`:" + main.page_path + "/index.mu`reload=62323]`_`f")
    main.close_database()
except Exception:
    print("An error occured")
