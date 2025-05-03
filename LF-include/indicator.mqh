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

// Класс и его глобальный экземпляр для доступа к свойствам индикатора. © FXcoder

#include "map.mqh"
#include "mql.mqh"

#define _INDICATOR_GET_CACHED(N, T)    T           N()  const { return N##_; }
#define _INDICATOR_SET_CACHED(N, T, P) CIndicator* N(T value) { N##_ = value; return set(P, value); }

#define _INDICATOR_GET_CACHED_I(N, T)    T           N(int index)          { return N##_.GetOrDefault(index, (T)NULL); }
#define _INDICATOR_SET_CACHED_I(N, T, P) CIndicator* N(int index, T value) { N##_.TrySetValue(index, value); return(set(P, index, value)); }


class CIndicator
{
protected:

	string short_name_;
	int    digits_;
	int    levels_;
	CMap<int, color>  level_color_;
	CMap<int, double> level_value_;
	//double maximum_;
	//double minimum_;

public:

	void CIndicator(){
		init_properties();
	}

	int window() { return ChartWindowFind(); }

	// Короткое наименование индикатора
	_INDICATOR_GET_CACHED(short_name, string)
	_INDICATOR_SET_CACHED(short_name, string, INDICATOR_SHORTNAME)

	// Точность отображения значений индикатора
	_INDICATOR_GET_CACHED(digits, int)
	_INDICATOR_SET_CACHED(digits, int, INDICATOR_DIGITS)

	// Количество уровней на окне индикатора
	_INDICATOR_GET_CACHED(levels, int)
	_INDICATOR_SET_CACHED(levels, int, INDICATOR_LEVELS)

	// Значение уровня
	_INDICATOR_GET_CACHED_I(level_value, double)
	_INDICATOR_SET_CACHED_I(level_value, double, INDICATOR_LEVELVALUE)

	// Цвет линий уровней
	_INDICATOR_GET_CACHED_I(level_color, color)
	_INDICATOR_SET_CACHED_I(level_color, color, INDICATOR_LEVELCOLOR)


private:

	void init_properties()
	{
		short_name_ = _mql.program_name();
		digits_ = _Digits;
		levels_ = 0;
	}

	// Универсальные функции доступа к свойствам

	CIndicator* set(ENUM_CUSTOMIND_PROPERTY_INTEGER property_id, int    value) { IndicatorSetInteger(property_id, value); return &this; }
	CIndicator* set(ENUM_CUSTOMIND_PROPERTY_DOUBLE  property_id, double value) { IndicatorSetDouble (property_id, value); return &this; }
	CIndicator* set(ENUM_CUSTOMIND_PROPERTY_STRING  property_id, string value) { IndicatorSetString (property_id, value); return &this; }

	CIndicator* set(ENUM_CUSTOMIND_PROPERTY_INTEGER property_id, int modifier, int    value) { IndicatorSetInteger(property_id, modifier, value); return &this; }
	CIndicator* set(ENUM_CUSTOMIND_PROPERTY_DOUBLE  property_id, int modifier, double value) { IndicatorSetDouble (property_id, modifier, value); return &this; }
	CIndicator* set(ENUM_CUSTOMIND_PROPERTY_STRING  property_id, int modifier, string value) { IndicatorSetString (property_id, modifier, value); return &this; }
};
CIndicator _indicator;
