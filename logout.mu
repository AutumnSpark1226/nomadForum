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
        print("\n>You are not logged in.")
    elif confirm != "yes":
        print_fields()
    elif confirm == "yes":
        username = main.query_database(f"SELECT username FROM users WHERE link_id = '{link_id}'")[0][0]
        if main.decrypt(main.query_database(f"SELECT password FROM users WHERE username = '{username}'")[0][0]) != "$nopassword$":
            main.execute_sql(f"UPDATE users SET link_id = '0', login_time = 0 WHERE link_id = '{link_id}'")
            if len(main.query_database(f"SELECT username FROM connections WHERE remote_id = '{remote_identity}' AND allow_login = 1 AND username = '{username}'")) == 1:
                main.execute_sql(f"UPDATE connections SET allow_login = 0 WHERE remote_id = '{remote_identity}' AND allow_login = 1 AND username = '{username}'")
            print(">Logged out")
        else:
            print(">Can't log out. You have set no password.")
        print()
        # submit a dummy value in order to force a reload
        print(f"`F00f`_`[Continue`:{main.page_path}/index.mu`reload=62323]`_`f")
    main.close_database()
except:
    print("An error occured")
