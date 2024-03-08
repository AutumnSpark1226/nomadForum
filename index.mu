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


import main


try:
    link_id, remote_identity = main.handle_ids()
    main.print_header(link_id)
    print(main.main_page_info)
    print('`F222`Bddd')
    print(f"Latest `F00f`_`[posts:`:{main.page_path}/list.mu]`_`f       `F00f`_`[List all posts`:{main.page_path}/list.mu]`_`f  `F00f`_`[Delete your account`:{main.page_path}/delete_account.mu]`_`f")
    print("``")
    print()
    posts = main.query_database("SELECT post_id, username, title, datetime(changed, 'unixepoch') FROM posts ORDER BY changed DESC LIMIT 10")
    for post_data in posts:
        post_title = post_data[2].replace("\\`", "\'")  # "`" breaks the link
        # "]" breaks the link
        post_title = post_title.replace("[", "(")
        post_title = post_title.replace("]", ")")
        print("-")
        print(f"{post_data[1]}: `F00f`_`[{post_title}`:{main.page_path}/view.mu`post_id={post_data[0]}]`_`f   ({post_data[3]} (UTC))")
    print("-")
    main.close_database()
except:
    print("An error occured")
