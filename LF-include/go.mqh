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

// Graphic object helper. © FXcoder

#define _GO_GET(N, T, P) T    N() const  { return (T)get(P); }
#define _GO_SET(N, T, P) CGO* N(T value) { return set(P, value); }

#define _GO_GET_MOD(N, T, P) T    N(int m = 0) const     { return (T)get(P, m); }
#define _GO_SET_MOD(N, T, P) CGO* N(T value, int m = 0)  { return set(P, m, value); }


class CGO
{
private:

	const long chart_id_;
	string name_;

public:

	void CGO(long chart_id, string name):
		chart_id_(chart_id),
		name_(name)
	{
	}

	void CGO(string name):
		chart_id_(0),
		name_(name)
	{
	}

	void CGO():
		chart_id_(0),
		name_("")
	{
	}

	string name() const { return name_; }

	CGO* name(string name)
	{
		name_ = name;
		return &this;
	}

	int    find   () const { return ObjectFind(chart_id_, name_); }
	bool   exists () const { return find() >= 0; }

	CGO* del()
	{
		ObjectDelete(chart_id_, name_);
		return &this;
	}

	// перерисовать объект на графике
	CGO* redraw(ENUM_OBJECT obj_type, int subwindow,
		datetime time1 = 0, double price1 = 0,
		datetime time2 = 0, double price2 = 0,
		datetime time3 = 0, double price3 = 0)
	{
		// удаление и создание быстрее поиска и переустановки свойств (5.2170)
		return del().draw(obj_type, subwindow, time1, price1, time2, price2, time3, price3);
	}

	// нарисовать объект на графике
	CGO* draw(ENUM_OBJECT obj_type, int subwindow,
		datetime time1 = 0, double price1 = 0,
		datetime time2 = 0, double price2 = 0,
		datetime time3 = 0, double price3 = 0)
	{
		ObjectCreate(chart_id_, name_, obj_type, subwindow, time1, price1, time2, price2, time3, price3);
		return &this;
	}

	// Standard properties

	// Object in the background
	_GO_GET(anchor, ENUM_ANCHOR_POINT, OBJPROP_ANCHOR)
	_GO_SET(anchor, ENUM_ANCHOR_POINT, OBJPROP_ANCHOR)

	// Object in the background
	_GO_SET(back, bool, OBJPROP_BACK)

	// Background color
	_GO_GET(bg_color, color, OBJPROP_BGCOLOR)
	_GO_SET(bg_color, color, OBJPROP_BGCOLOR)

	// Object in the background
	_GO_GET(corner, ENUM_BASE_CORNER, OBJPROP_CORNER)
	_GO_SET(corner, ENUM_BASE_CORNER, OBJPROP_CORNER)

	// Color (main, foreground)
	_GO_SET(fg_color, color, OBJPROP_COLOR)

	// Fill an object with color
	_GO_SET(fill, bool, OBJPROP_FILL)

	//
	_GO_SET(font_size, int, OBJPROP_FONTSIZE)

	//
	_GO_SET(font_name, string, OBJPROP_FONT)

	// Prohibit showing of the name of a graphical object in the list of objects
	_GO_SET(hidden, bool, OBJPROP_HIDDEN)

	//
	_GO_GET_MOD(price, double, OBJPROP_PRICE);
	_GO_SET_MOD(price, double, OBJPROP_PRICE);

	// Ray goes to the left
	_GO_SET(ray_left, bool, OBJPROP_RAY_LEFT)

	// Ray goes to the right
	_GO_SET(ray_right, bool, OBJPROP_RAY_RIGHT)

	// Object availability
	_GO_GET(selectable, bool, OBJPROP_SELECTABLE)
	_GO_SET(selectable, bool, OBJPROP_SELECTABLE)

	//
	_GO_GET(selected, bool, OBJPROP_SELECTED)

	//
	_GO_GET(state, bool, OBJPROP_STATE)
	_GO_SET(state, bool, OBJPROP_STATE)

	// Style
	_GO_SET(style, ENUM_LINE_STYLE, OBJPROP_STYLE)

	// Description of the object
	_GO_GET(text, string, OBJPROP_TEXT)
	_GO_SET(text, string, OBJPROP_TEXT)

	// Time coordinate
	_GO_GET_MOD(time, datetime, OBJPROP_TIME)
	_GO_SET_MOD(time, datetime, OBJPROP_TIME)

	// The text of a tooltip
	_GO_SET(tooltip, string, OBJPROP_TOOLTIP)

	// Object type
	_GO_GET(type, ENUM_OBJECT, OBJPROP_TYPE) // r/o

	//
	_GO_GET(xdistance, int, OBJPROP_XDISTANCE)
	_GO_SET(xdistance, int, OBJPROP_XDISTANCE)

	//
	_GO_SET(xsize, int, OBJPROP_XSIZE)

	//
	_GO_GET(ydistance, int, OBJPROP_YDISTANCE)
	_GO_SET(ydistance, int, OBJPROP_YDISTANCE)

	//
	_GO_SET(ysize, int, OBJPROP_YSIZE)

	// Line thickness
	_GO_SET(width, int, OBJPROP_WIDTH) // line width, see XSise for object width

	//
	_GO_GET(zorder, int, OBJPROP_ZORDER)
	_GO_SET(zorder, int, OBJPROP_ZORDER)

	// Helpers

	// LONG_MAX и LONG_MIN не работают? fxcoder/mki#1
	CGO* zorder_front() { return zorder(INT_MAX); }
	CGO* zorder_back()  { return zorder(INT_MIN); }

	CGO* xy(int x, int y)
	{
		return xdistance(x).ydistance(y);
	}

	CGO* xy_size(int x_size, int y_size)
	{
		return xsize(x_size).ysize(y_size);
	}

	CGO* tooltip_disable()
	{
		// \n - специальное значение для отключения подсказки
		return set(OBJPROP_TOOLTIP, "\n");
	}

private:

	// Универсальные функции доступа к свойствам
	CGO* set(ENUM_OBJECT_PROPERTY_INTEGER property_id, long   value) { ObjectSetInteger(chart_id_, name_, property_id, value); return &this; }
	CGO* set(ENUM_OBJECT_PROPERTY_DOUBLE  property_id, double value) { ObjectSetDouble (chart_id_, name_, property_id, value); return &this; }
	CGO* set(ENUM_OBJECT_PROPERTY_STRING  property_id, string value) { ObjectSetString (chart_id_, name_, property_id, value); return &this; }

	CGO* set(ENUM_OBJECT_PROPERTY_INTEGER property_id, int modifier, long   value) { ObjectSetInteger(chart_id_, name_, property_id, modifier, value); return &this; }
	CGO* set(ENUM_OBJECT_PROPERTY_DOUBLE  property_id, int modifier, double value) { ObjectSetDouble (chart_id_, name_, property_id, modifier, value); return &this; }
	CGO* set(ENUM_OBJECT_PROPERTY_STRING  property_id, int modifier, string value) { ObjectSetString (chart_id_, name_, property_id, modifier, value); return &this; }

	long   get(ENUM_OBJECT_PROPERTY_INTEGER property_id, int modifier = 0) const { return ObjectGetInteger(chart_id_, name_, property_id, modifier); }
	double get(ENUM_OBJECT_PROPERTY_DOUBLE  property_id, int modifier = 0) const { return ObjectGetDouble (chart_id_, name_, property_id, modifier); }
	string get(ENUM_OBJECT_PROPERTY_STRING  property_id, int modifier = 0) const { return ObjectGetString (chart_id_, name_, property_id, modifier); }
};
