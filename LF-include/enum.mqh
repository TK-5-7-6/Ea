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

// Перечисление. © FXcoder

template <typename E>
struct Enum
{
	E value;

	void Enum():
		value(E(0))
	{
	}

	void Enum(const Enum<E> &e):
		value(e.value)
	{
	}

	void operator=(E ev)              { value = ev;      }
	void operator=(const Enum<E> &e)  { value = e.value; }

	bool operator==(E ev)             const { return ev      == value; }
	bool operator==(const Enum<E> &e) const { return e.value == value; }

	bool operator!=(E ev)             const { return ev      != value; }
	bool operator!=(const Enum<E> &e) const { return e.value != value; }
};
