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

// Series helper. © FXcoder

#include "math.mqh"
#include "sym.mqh"
#include "terminal.mqh"
#include "tf.mqh"

// шаблон для функций копирования истории
#define _SERIES_COPY_TPL(FUNC, SFUNC, T)                  \
    bool FUNC(int pos, T &value) const                    \
    {                                                     \
        T arr[];                                          \
        if (SFUNC(symbol_, period_, pos, 1, arr) != 1)    \
            return false;                                 \
        value = arr[0];                                   \
        return true;                                      \
    }                                                     \
    int FUNC(     int start_pos,       int count,     T &arr[]) const { return SFUNC(symbol_, period_, start_pos,  count,     arr); }  \
    int FUNC(datetime start_time,      int count,     T &arr[]) const { return SFUNC(symbol_, period_, start_time, count,     arr); }  \
    int FUNC(datetime start_time, datetime stop_time, T &arr[]) const { return SFUNC(symbol_, period_, start_time, stop_time, arr); }

#define _SERIES_GET(N, T, P) T N() const { return (T)get(P); }

class CSeries
{
private:

	const string symbol_;
	const ENUM_TIMEFRAMES period_;
	const int period_seconds_;

public:

	void CSeries():
		symbol_(_sym.current),
		period_(_tf.current),
		period_seconds_(_tf.current_seconds)
	{
	}

	void CSeries(string symbol, ENUM_TIMEFRAMES period):
		symbol_(_sym.real(symbol)),
		period_(_tf.real(period)),
		period_seconds_(PeriodSeconds(period))
	{
	}

	_SERIES_COPY_TPL(copy_rates,       CopyRates,      MqlRates)
	_SERIES_COPY_TPL(copy_time,        CopyTime,       datetime)
	_SERIES_COPY_TPL(copy_open,        CopyOpen,       double)
	_SERIES_COPY_TPL(copy_high,        CopyHigh,       double)
	_SERIES_COPY_TPL(copy_low,         CopyLow,        double)
	_SERIES_COPY_TPL(copy_close,       CopyClose,      double)
	_SERIES_COPY_TPL(copy_tick_volume, CopyTickVolume, long)
	_SERIES_COPY_TPL(copy_spread,      CopySpread,     int)

	// The very first date for the symbol-period for the current moment
	_SERIES_GET(first_date, datetime, SERIES_FIRSTDATE)

	// с учётом ограничения терминала
	int max_bars() const
	{
		return _math.min(bars_count(), _terminal.max_bars());
	}

	int bars_count() const
	{
		return (int)SeriesInfoInteger(symbol_, period_, SERIES_BARS_COUNT);
	}

	int bars() const
	{
		return Bars(symbol_, period_);
	}

	int bars(datetime start_time, datetime stop_time) const
	{
		return Bars(symbol_, period_, start_time, stop_time);
	}

	int bar_shift(datetime time, bool exact = false) const
	{
		return iBarShift(symbol_, period_, time, exact);
	}

	datetime time(int index, bool zero_limit = true, bool max_limit = true) const
	{
		int max_bars = max_bars();
		if (max_bars <= 0)
			return 0;

		if (!max_limit && index >= max_bars)
		{
			datetime time = iTime(symbol_, period_, max_bars - 1);
			if (time == 0)
				return 0;

			return time - (index - max_bars + 1) * period_seconds_;
		}

		if (!zero_limit && index < 0)
		{
			datetime time = iTime(symbol_, period_, 0);
			if (time == 0)
				return 0;

			return time - index * period_seconds_;
		}

		return iTime(symbol_, period_, index);
	}

	bool rate(int index, MqlRates &rate) const
	{
		MqlRates rates[];
		if (copy_rates(index, 1, rates) != 1)
			return false;

		rate = rates[0];
		return true;
	}

	double low(int index) const
	{
		if (index < 0 || index >= max_bars())
			return 0.0;

		return iLow(symbol_, period_, index);
	}

	double high(int index) const
	{
		if (index < 0 || index >= max_bars())
			return 0.0;

		return iHigh(symbol_, period_, index);
	}

	double close(int index) const
	{
		if (index < 0 || index >= max_bars())
			return 0.0;

		return iClose(symbol_, period_, index);
	}

	double open(int index) const
	{
		if (index < 0 || index >= max_bars())
			return 0.0;

		return iOpen(symbol_, period_, index);
	}

	/*
	Получить номер бара для указанного времени и таймфрейма со смещением влево.
	@param time    Время искомого бара.
	@return        Номер бара. Если бар выходит за границу котировок справа, возвращается соответствующее отрицательное
	               значение. Если найденный бар имеет время раньше указанного, то возвращается бар слева.
	*/
	int bar_shift_left(datetime time)
	{
		int bar = iBarShift(symbol_, period_, time);
		datetime t = this.time(bar);

		if ((t != time) && (bar == 0))
		{
			// время за пределами диапазона
			bar = (int)((this.time(0) - time) / period_seconds_);
		}
		else
		{
			// проверить, чтобы бар был не справа по времени (документация не уточняет этот момент)
			if (t > time)
				bar++;
		}

		return bar;
	}

	/*
	Получить номер бара для указанного времени и таймфрейма со смещением вправо.
	@param time        Время искомого бара.
	@return            Номер бара. Если бар выходит за границу котировок справа, возвращается соответствующее отрицательное
	                   значение. Если найденный бар имеет время раньше указанного, то возвращается бар справа.
	*/
	int bar_shift_right(datetime time)
	{
		int bar = iBarShift(symbol_, period_, time);

		// bar == 0 может означать как нулевой бар, так и отрицательный (будущее). В этом случае вычислить бар по формуле разницы.
		if (bar == 0)
			bar = (int)((this.time(0) - time) / period_seconds_);

		// если время не совпадает с открытием бара, то взять правый
		if (time != time_to_open_left(time))
		{
			bar--;
		}

		return bar;
	}

	// Привести время ко времени открытия бара влево.
	// Если время уже на открытии бара, оно не изменится, иначе будет возвращено ближайшее
	//   время открытия слева.
	datetime time_to_open_left(datetime time)
	{
		return this.time(bar_shift_left(time), false);
	}

	// Привести время ко времени открытия бара вправо.
	// Если время уже на открытии бара, оно не изменится, иначе будет возвращено ближайшее
	//   время открытия справа.
	datetime time_to_open_right(datetime time)
	{
		return this.time(bar_shift_right(time), false);
	}

private:

	// Универсальные функции доступа к свойствам
	long get(ENUM_SERIES_INFO_INTEGER property_id) const { return SeriesInfoInteger(symbol_, period_, property_id); }
};

CSeries _series;
