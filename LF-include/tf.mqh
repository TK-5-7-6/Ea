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

// Timeframe. © FXcoder

#include "time.mqh"

class CTFUtil
{
public:

	static const ENUM_TIMEFRAMES current;
	static const int current_minutes; // number of minutes in the current timeframe
	static const int current_seconds; // number of seconds in the current timeframe
	static const int w1_seconds;      // number of seconds in the W1 timeframe
	static const int mn1_seconds;     // number of seconds in the MN1 timeframe

	// convert PERIOD_CURRENT to real
	static ENUM_TIMEFRAMES real(ENUM_TIMEFRAMES tf = PERIOD_CURRENT)
	{
		return tf == PERIOD_CURRENT ? current : tf;
	}

	static bool is_current(ENUM_TIMEFRAMES tf)
	{
		return real(tf) == current;
	}

	// Найти ближайший таймфрейм.
	// Результат всегда есть, minutes <= 0 даёт M1.
	static ENUM_TIMEFRAMES find_closest(int minutes)
	{
		const ENUM_TIMEFRAMES list[] =
		{
			PERIOD_M1,  PERIOD_M2,  PERIOD_M3,  PERIOD_M4,  PERIOD_M5, PERIOD_M6, PERIOD_M10,
			PERIOD_M12, PERIOD_M15, PERIOD_M20, PERIOD_M30, PERIOD_H1, PERIOD_H2, PERIOD_H3,
			PERIOD_H4,  PERIOD_H6,  PERIOD_H8,  PERIOD_H12, PERIOD_D1, PERIOD_W1, PERIOD_MN1
		};

		const int count = ArraySize(list);
		const long seconds = minutes * 60;

		long min_diff = LONG_MAX;
		ENUM_TIMEFRAMES tf = PERIOD_CURRENT;

		for (int i = 0; i < count; i++)
		{
			const long tf_sec = PeriodSeconds(list[i]);
			const long diff = fabs(tf_sec - seconds);

			// give priority to higher timeframe (3 seems closer to 5 than to 1)
			if (diff > min_diff)
				return list[i - 1];

			min_diff = diff;
		}

		return list[count - 1];
	}

	// Convert timeframe to string. Standard timeframes only.
	static string to_string(ENUM_TIMEFRAMES tf = PERIOD_CURRENT)
	{
		const int seconds = PeriodSeconds(tf);

		if (seconds % _time.seconds_in_month == 0)
			return "MN" + IntegerToString(seconds / _time.seconds_in_month);
		else if (seconds % _time.seconds_in_week == 0)
			return "W" + IntegerToString(seconds / _time.seconds_in_week);
		else if (seconds % _time.seconds_in_day == 0)
			return "D" + IntegerToString(seconds / _time.seconds_in_day);
		else if (seconds % _time.seconds_in_hour == 0)
			return "H" + IntegerToString(seconds / _time.seconds_in_hour);
		else
			return "M" + IntegerToString(seconds / 60);
	}
};

const ENUM_TIMEFRAMES  CTFUtil::current         = Period();
const int              CTFUtil::current_minutes = PeriodSeconds() / 60;
const int              CTFUtil::current_seconds = PeriodSeconds();
const int              CTFUtil::w1_seconds      = PeriodSeconds(PERIOD_W1);
const int              CTFUtil::mn1_seconds     = PeriodSeconds(PERIOD_MN1);

CTFUtil _tf;
