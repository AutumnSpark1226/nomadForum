#!/usr/bin/python3
import os

import main

try:
    link_id = ""
    for env_variable in os.environ:
        if env_variable == "link_id":
            link_id = os.environ[env_variable]
    if len(link_id) != 32 and not link_id.isalnum():
        print("something went wrong...")
        exit(0)
    main.setup_db()
    main.print_header(link_id)
    print("User profile")
    main.close_database()
except:
    print("An error occured")
