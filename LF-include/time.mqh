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

// Time. © FXcoder

#include "tf.mqh"

class CTimeUtil
{
public:

	static const int seconds_in_hour;
	static const int seconds_in_day;
	static const int seconds_in_week;
	static const int seconds_in_month;

	// возвращает теоретическое время открытия бара, в реале может быть другое
	// 0 в случае неизвестного таймфрейма
	static datetime begin_of_period(datetime time, ENUM_TIMEFRAMES tf = PERIOD_CURRENT)
	{
		int tf_seconds = PeriodSeconds(tf);

		// для тф меньше недельного подойдёт отбрасывание остатка периода
		if (tf_seconds < _tf.w1_seconds)
			return (time / tf_seconds) * tf_seconds;

		// для недельного тф требуется небольшая магия с округлением и сдвигом из-за того, что
		//   нулевая дата - не воскресенье.
		// сравнение по секундам, чтобы не вызывать _tf.real()
		if (tf_seconds == _tf.w1_seconds)
			return ((time - 3 * seconds_in_day) / _tf.w1_seconds) * _tf.w1_seconds + 3 * seconds_in_day;

		if (tf_seconds == _tf.mn1_seconds)
		{
			MqlDateTime ts;
			if (!TimeToStruct(time, ts))
				return 0;

			ts.day = 1;
			ts.hour = 0;
			ts.min = 0;
			ts.sec = 0;

			return StructToTime(ts);
		}

		return 0;
	}

	// 0 в случае неудачи (лучше для отладки, чем возвращать исходное время).
	// Без проверок на переполнение.
	// bars может быть с любым знаком, положительные значения смещают в будущее (вправо).
	// Для PERIOD_MN1 результат только в пределах 28 числа.
	static bool add_periods(datetime time, int bars, ENUM_TIMEFRAMES period, datetime &res)
	{
		const int period_seconds = PeriodSeconds(period);

		// для периодов до недельного включительно можно просто добавлять секунды
		if (period_seconds <= _tf.w1_seconds)
		{
			res = time += bars * period_seconds;
			return true;
		}

		MqlDateTime ts;
		if (!TimeToStruct(time, ts))
			return false;

		if (ts.day > 28)
			return false;

		int months = (ts.year - 1970) * 12 + ts.mon - 1;
		months += bars;
		ts.year = 1970 + months / 12;
		ts.mon = (months % 12) + 1;

		res = StructToTime(ts);
		return true;
	}

	/*
	Преобразовать время в строку по заданному шаблону.

	@param date    Дата
	@param format  Шаблон. Можно использовать следующие подстановки:
	                 - yy - год (2 знака),
	                 - yyyy - год (4 знака),
	                 - MM - месяц (2 знака),
	                 - dd - день (2 знака),
	                 - HH - час (2 знака, 24-часовой формат),
	                 - mm - минута (2 знака),
	                 - ss - секунда (2 знака).

	@return        Время в указанном формате.

	@code
	// преобразование в американский формат
	string am_time = to_string_format(D'2011.01.15', "MM/dd/yyyy"); // 01/15/2011

	// преобразование в российский формат
	string ru_time = to_string_format(D'2011.01.15', "dd.MM.yyyy"); // 15.01.2011
	@endcode
	*/
	static string to_string_format(datetime time, string format)
	{
		// пример: 18.03.2011 15:20:55
		//   yy    11
		//   yyyy  2011
		//   MM    03
		//   dd    18
		//   HH    15
		//   mm    20
		//   ss    55

		// Формат по умолчанию: yyyy.MM.dd HH:mm:ss
		string s = TimeToString(time, TIME_DATE | TIME_MINUTES | TIME_SECONDS);
		string res;

		// для часто используемых форматов использовать быстрое преобразование
		if (format == "MM/dd/yyyy")
		{
			// американский формат
			res = StringSubstr(s, 5, 2) + "/" + StringSubstr(s, 8, 2) + "/" + StringSubstr(s, 0, 4);
		}
		else if (format == "dd.MM.yyyy")
		{
			// русский формат
			res = StringSubstr(s, 8, 2) + "." + StringSubstr(s, 5, 2) + "." + StringSubstr(s, 0, 4);
		}
		else if (format == "yyyy-MM-dd")
		{
			// удобный для сортировки
			res = StringSubstr(s, 0, 4) + "-" + StringSubstr(s, 5, 2) + "-" + StringSubstr(s, 8, 2);
		}
		else
		{
			res = format;
			StringReplace(res, "yyyy", StringSubstr(s, 0,  4));
			StringReplace(res, "yy",   StringSubstr(s, 2,  2));
			StringReplace(res, "MM",   StringSubstr(s, 5,  2));
			StringReplace(res, "dd",   StringSubstr(s, 8,  2));
			StringReplace(res, "HH",   StringSubstr(s, 11, 2));
			StringReplace(res, "mm",   StringSubstr(s, 14, 2));
			StringReplace(res, "ss",   StringSubstr(s, 17, 2));
		}

		return (res);
	}
};

const int CTimeUtil::seconds_in_hour           =           60 * 60; //       3 600
const int CTimeUtil::seconds_in_day            =         1440 * 60; //      86 400
const int CTimeUtil::seconds_in_week           =     7 * 1440 * 60; //     604 800
const int CTimeUtil::seconds_in_month          =    30 * 1440 * 60; //   2 592 000 // 30-days

CTimeUtil _time;
