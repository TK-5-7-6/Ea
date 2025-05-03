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

// Terminal helper. © FXcoder

#define _TERMINAL_GET(N, T, P) static T N() { return (T)get(P); }

class CTerminal
{
public:
	_TERMINAL_GET(max_bars, int, TERMINAL_MAXBARS); // The maximal bars count on the chart
	// keys
	static bool is_shift_key_pressed      () { return is_key_pressed(TERMINAL_KEYSTATE_SHIFT    ); }
	static bool is_control_key_pressed    () { return is_key_pressed(TERMINAL_KEYSTATE_CONTROL  ); }
	static bool is_end_key_pressed        () { return is_key_pressed(TERMINAL_KEYSTATE_END      ); }
	static bool is_escape_key_pressed     () { return is_key_pressed(TERMINAL_KEYSTATE_ESCAPE   ); }
private:

	static int    get(ENUM_TERMINAL_INFO_INTEGER property_id) { return TerminalInfoInteger (property_id); }
	static double get(ENUM_TERMINAL_INFO_DOUBLE  property_id) { return TerminalInfoDouble  (property_id); }
	static string get(ENUM_TERMINAL_INFO_STRING  property_id) { return TerminalInfoString  (property_id); }

	// Check if the key is pressed (not held down like *Lock keys, they sould be checked on the low bit)
	static bool is_key_pressed(ENUM_TERMINAL_INFO_INTEGER key) { return (TerminalInfoInteger(key) & 0x8000) != 0; }

} _terminal;
