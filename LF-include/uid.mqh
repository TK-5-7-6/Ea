/*
Copyright 2024 FXcoder

This file is part of LF.

LF is free software: you can redistribute it and/or modify it under the terms of the GNU General
Public License as published by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

LF is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
Public License for more details.

You should have received a copy of the GNU General Public License along with LF. If not, see
http://www.gnu.org/licenses/.
*/

// Уникальный идентификатор. © FXcoder

#include "gv.mqh"

class CUID
{
public:

	static int get(const string &name, int limit = 1000)
	{
		CGV gv_id(name);
		CGV gv_mutex(name + ".mutex");

		gv_id.temp();
		gv_mutex.temp();

		while (!gv_mutex.set_on_condition(1, 0))
		{
		}

		int uid = (int)(gv_id.get_or_default(0.0) + 0.5) % limit;
		gv_id.set(uid + 1);
		gv_mutex.set(0);
		return uid;
	}

} _uid;
