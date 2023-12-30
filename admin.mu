#!/usr/bin/python3
import main


try:
    link_id, remote_identity = main.handle_ids()
    main.print_header(link_id)
    print("Admin page")
    main.close_database()
except:
    print("An error occured")
