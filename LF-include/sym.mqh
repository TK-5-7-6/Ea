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

// Symbol. © FXcoder

#include "str.mqh"

class CSymbolUtil
{
public:

	static const string current;

	static bool is_current(string symbol)
	{
		return real(symbol) == current;
	}

	// return current if empy
	static string real(string symbol = NULL)
	{
		return _str.is_empty(symbol) ? current : symbol;
	}
};

const string CSymbolUtil::current = _Symbol;

CSymbolUtil _sym;
