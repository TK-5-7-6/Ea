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

// MQL helper. © FXcoder


#define _MQL_GET(N, T, P) static T N() { return (T)get(P); }

class CMQL
{
public:

	// Name of the running mql5-program
	_MQL_GET(program_name, string, MQL_PROGRAM_NAME)

	// Возвращает название скрипта с возможным обрезанием суффикса с номером версии (Index-v7 -> Index).
	static string program_name(bool remove_version)
	{
		string name = _mql.program_name();
		if (!remove_version)
			return name;

		int trim_pos = -1;
		int pos = 0;

		while (pos > -1)
		{
			pos = StringFind(name, "-v", pos + 1); // можно начинать с символа 1, т.к. иначе имя индикатора пусто, чего не должно быть

			if (pos != -1)
				trim_pos = pos;
		}

		if (trim_pos != -1)
			name = StringSubstr(name, 0, trim_pos);

		return name;
	}

private:
	static string get(ENUM_MQL_INFO_STRING  property_id) { return MQLInfoString (property_id); }

} _mql;
