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

// OnChartEvent helper. © FXcoder

class CChartEvent
{
private:

	int    id_;
	long   lparam_;
	double dparam_;
	string sparam_;

public:

	int    id()     const { return id_;     }
	long   lparam() const { return lparam_; }
	double dparam() const { return dparam_; }
	string sparam() const { return sparam_; }

	void update(const int id, const long &lparam, const double &dparam, const string &sparam)
	{
		id_ = id;
		lparam_ = lparam;
		dparam_ = dparam;
		sparam_ = sparam;
	}

	bool is_click_event()        const { return id_ == CHARTEVENT_CLICK; }
	bool is_chart_change_event() const { return id_ == CHARTEVENT_CHART_CHANGE; }
	bool is_mouse_move_event() const
	{
		return id_ == CHARTEVENT_MOUSE_MOVE;
	}

	bool is_custom_event() const
	{
		return id_ >= (int)CHARTEVENT_CUSTOM && id_ <= (int)CHARTEVENT_CUSTOM_LAST;
	}

	bool is_custom_event(int event_n) const
	{
		return is_custom_event() && id_ == CHARTEVENT_CUSTOM + event_n;
	}

	bool is_object_create_event() const
	{
		return id_ == CHARTEVENT_OBJECT_CREATE;
	}

	bool is_object_drag_event() const
	{
		return id_ == CHARTEVENT_OBJECT_DRAG;
	}

	bool is_object_delete_event() const
	{
		return id_ == CHARTEVENT_OBJECT_DELETE;
	}

	// подразумеваются все действия, изменяющие координаты, включая создание и удаление объекта
	bool is_object_event() const
	{
		return
			id_ == CHARTEVENT_OBJECT_CREATE ||
			id_ == CHARTEVENT_OBJECT_CHANGE ||
			id_ == CHARTEVENT_OBJECT_DRAG   ||
			id_ == CHARTEVENT_OBJECT_DELETE ||
			id_ == CHARTEVENT_OBJECT_ENDEDIT ||
			id_ == CHARTEVENT_OBJECT_CLICK;
	}

	// подразумеваются все действия, изменяющие координаты, включая создание и удаление объекта
	bool is_object_event(string name) const
	{
		return is_object_event() && sparam_ == name;
	}

	bool is_key_down_event() const
	{
		return id_ == CHARTEVENT_KEYDOWN;
	}

	bool is_key_down_event(ushort key) const
	{
		return is_key_down_event() && key == lparam_;
	}

	bool is_object_click_event()
	{
		return id_ == CHARTEVENT_OBJECT_CLICK;
	}
	int mouse_x() const { return (int)lparam_; }
	int mouse_y() const { return (int)dparam_; }
	ushort key() const
	{
		return (ushort)lparam_;
	}

} _chartevent;
