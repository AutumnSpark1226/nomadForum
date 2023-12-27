#!/usr/bin/python3
import os

import main


try:
    link_id = ""
    type = ""
    content_id = ""
    delete_as_admin = "no"
    for env_variable in os.environ:
        if env_variable == "link_id":
            link_id = os.environ[env_variable]
        elif env_variable == "type":
            type = os.environ[env_variable]
        elif env_variable == "content_id":
            content_id = os.environ[env_variable]
        elif env_variable == "delete_as_admin":
            delete_as_admin = os.environ[env_variable]
    if len(link_id) != 32 or not link_id.isalnum():
        print("something went wrong...")
        exit(0)
    main.setup_db()
    main.print_header(link_id)
    print("Delete a post or comment")
    main.close_database()
except:
    print("An error occured")
