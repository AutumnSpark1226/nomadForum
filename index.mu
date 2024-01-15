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
    print("Main page (still WIP)")
    print(f"`F00f`_`[List posts`:{main.page_path}/list.mu]`_`f")
    print(f"`F00f`_`[Create post`:{main.page_path}/post.mu]`_`f")
    print(f"`F00f`_`[Delete your account`:{main.page_path}/delete_account.mu]`_`f")
    main.close_database()
except:
    print("An error occured")
