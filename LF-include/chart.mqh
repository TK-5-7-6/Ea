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

// Chart. © FXcoder

#define _CHART_GET(N, T, P) T       N() const  { return (T)get(P); }
#define _CHART_SET(N, T, P) CChart *N(T value) { return set(P, value); }
#define _CHART_GETSET(N, T, P) _CHART_GET(N, T, P) _CHART_SET(N, T, P)

#define _CHART_WINDOW_GET(N, T, P) T       N(int window = 0) const  { return (T)get(P, window); }
#define _CHART_WINDOW_SET(N, T, P) CChart *N(int window, T value)   { return set(P, window, value); }

class CChart
{
private:

	long id_; // 0 - current

	// Chart's changing parameters. See check_change().
	double chart_price_min_;
	double chart_price_max_;
	int chart_width_in_bars_;
	int chart_first_visible_bar_;
	int chart_height_in_pixels_;
	int chart_width_in_pixels_;
	datetime chart_zero_bar_time_;

public:

	// Default constructor
	void CChart():
		id_(0),
		chart_price_min_(0),
		chart_price_max_(0),
		chart_width_in_bars_(0),
		chart_first_visible_bar_(0),
		chart_height_in_pixels_(0),
		chart_width_in_pixels_(0),
		chart_zero_bar_time_(0)
	{
	}

	// Constructor for a specific chart Id.
	void CChart(long chart_id):
		id_(chart_id),
		chart_price_min_(0),
		chart_price_max_(0),
		chart_width_in_bars_(0),
		chart_first_visible_bar_(0),
		chart_height_in_pixels_(0),
		chart_width_in_pixels_(0),
		chart_zero_bar_time_(0)
	{
	}

	int objects_delete_all(int subwindow = -1, int object_type = -1) const
	{
		return ObjectsDeleteAll(id_, subwindow, object_type);
	}

	int objects_delete_all(const string prefix, int subwindow = -1, int object_type = -1) const
	{
		return ObjectsDeleteAll(id_, prefix, subwindow, object_type);
	}

	void redraw() { ChartRedraw(id_); }

	// if <0 return id_
	long id() const { return id_ == 0 ? ChartID() : id_; }

	string symbol() const
	{
		return ChartSymbol(id_);
	}

	bool symbol(string symbol)
	{
		return ChartSetSymbolPeriod(id_, symbol, period());
	}

	ENUM_TIMEFRAMES period() const
	{
		return ChartPeriod(id_);
	}

	bool xy_to_time_price(int x, int y, int &window, datetime &time, double &price) const
	{
		return ChartXYToTimePrice(id_, x, y, window, time, price);
	}

	bool time_price_to_xy(int window, datetime time, double price, int &x, int &y) const
	{
		return ChartTimePriceToXY(id_, window, time, price, x, y);
	}

	static int window_find()
	{
		return ChartWindowFind();
	}

	int window_find(string indicator_shortname) const
	{
		return ChartWindowFind(id_, indicator_shortname);
	}

	int objects_total()                                    const { return ObjectsTotal(id_); }
	int objects_total(int subwindow)                       const { return ObjectsTotal(id_, subwindow); }
	int objects_total(int subwindow, ENUM_OBJECT obj_type) const { return ObjectsTotal(id_, subwindow, obj_type); }

	string object_name(int index)                                      const { return ObjectName(id_, index); }
	string object_name(int index, int subwindow)                       const { return ObjectName(id_, index, subwindow); }
	string object_name(int index, int subwindow, ENUM_OBJECT obj_type) const { return ObjectName(id_, index, subwindow, obj_type); }

	// Число баров на графике (не в окне)
	int bars() const
	{
		return Bars(symbol(), period());
	}

	void event_custom(ushort event_n, long lparam, double dparam, string sparam)
	{
		EventChartCustom(id_, event_n, lparam, dparam, sparam);
	}

	//
	_CHART_GETSET(autoscroll, bool, CHART_AUTOSCROLL)

	//
	_CHART_GETSET(bring_to_top, bool, CHART_BRING_TO_TOP)

	//
	_CHART_GETSET(color_ask, color, CHART_COLOR_ASK)

	// Chart background color
	_CHART_GETSET(color_background, color, CHART_COLOR_BACKGROUND)

	//
	_CHART_GETSET(color_bid, color, CHART_COLOR_BID)

	// Chart foreground color
	_CHART_GETSET(color_foreground, color, CHART_COLOR_FOREGROUND)

	//
	_CHART_GETSET(color_candle_bear, color, CHART_COLOR_CANDLE_BEAR)

	//
	_CHART_GETSET(color_candle_bull, color, CHART_COLOR_CANDLE_BULL)

	// Color for the down bar, shadows and body borders of bear candlesticks
	_CHART_GETSET(color_chart_down, color, CHART_COLOR_CHART_DOWN)

	//
	_CHART_GETSET(color_chart_line, color, CHART_COLOR_CHART_LINE)

	// Color for the up bar, shadows and body borders of bull candlesticks
	_CHART_GETSET(color_chart_up, color, CHART_COLOR_CHART_UP)

	//
	_CHART_GETSET(color_grid, color, CHART_COLOR_GRID)

	//
	_CHART_GETSET(color_last, color, CHART_COLOR_LAST)

	//
	_CHART_GETSET(color_stop_level, color, CHART_COLOR_STOP_LEVEL)

	//
	_CHART_GETSET(color_volume, color, CHART_COLOR_VOLUME)

	// Text of a comment in a chart
	_CHART_GETSET(comment, string, CHART_COMMENT)

	//
	_CHART_GETSET(event_mouse_move, bool, CHART_EVENT_MOUSE_MOVE)

	// Send a notification of an event of object deletion (CHARTEVENT_OBJECT_DELETE) to all mql5-programs on a chart
	_CHART_GETSET(event_object_delete, bool, CHART_EVENT_OBJECT_DELETE)

	// Number of the first visible bar in the chart. Indexing of bars is the same as for timeseries (r/o)
	_CHART_GET(first_visible_bar, int, CHART_FIRST_VISIBLE_BAR)

	//
	_CHART_GETSET(fixed_max, double, CHART_FIXED_MAX)

	//
	_CHART_GETSET(fixed_min, double, CHART_FIXED_MIN)

	// Price chart in the foreground
	_CHART_GETSET(foreground, bool, CHART_FOREGROUND)

	// Chart height in pixels
	_CHART_WINDOW_GET(height_in_pixels, int, CHART_HEIGHT_IN_PIXELS)

	//
	_CHART_GETSET(is_docked, bool, CHART_IS_DOCKED)

	//
	_CHART_GET(is_maximized, bool, CHART_IS_MAXIMIZED)

	//
	_CHART_GET(is_minimized, bool, CHART_IS_MINIMIZED)

	//
	_CHART_GET(is_object, bool, CHART_IS_OBJECT)

	//
	_CHART_GETSET(mode, ENUM_CHART_MODE, CHART_MODE)

	// Chart maximum (r/o)
	_CHART_WINDOW_GET(price_max, double, CHART_PRICE_MAX)
	// Chart minimum (r/o)
	_CHART_WINDOW_GET(price_min, double, CHART_PRICE_MIN)

	// Scale (0..5)
	_CHART_GETSET(scale, int, CHART_SCALE)

	//
	_CHART_GETSET(scale_fix, bool, CHART_SCALEFIX)

	//
	_CHART_GETSET(shift, bool, CHART_SHIFT)

	//
	_CHART_GETSET(show_trade_history, bool, CHART_SHOW_TRADE_HISTORY)

	//
	_CHART_GETSET(show_trade_levels, bool, CHART_SHOW_TRADE_LEVELS)

	//
	_CHART_GETSET(show_one_click, bool, CHART_SHOW_ONE_CLICK)

	// The number of bars on the chart that can be displayed (r/o)
	_CHART_GET(visible_bars, int, CHART_VISIBLE_BARS)

	// Chart width in bars (r/o)
	_CHART_GET(width_in_bars, int, CHART_WIDTH_IN_BARS)

	// Chart width in pixels (r/o)
	_CHART_GET(width_in_pixels, int, CHART_WIDTH_IN_PIXELS)

	int leftmost_visible_bar() const { return first_visible_bar(); }

	// Самый правый видимый бар, может быть отрицательным, если справа есть отступ.
	// forbid_negative: вернуть 0, если номер бара отрицательный
	int rightmost_visible_bar(bool forbid_negative) const
	{
		int bar = first_visible_bar() - width_in_bars() + 1;

		if (forbid_negative && bar < 0)
			bar = 0;

		return bar;
	}

	// Толщина бара как линии (не пиксели).
	int bar_body_line_width()
	{
		int scale = scale();

		// see fxcoder/mki#55
		switch (scale)
		{
			case 0: return 1;
			case 1: return 1;
			case 2: return 2;
			case 3: return 3;
			case 4: return 6;
			case 5: return 13;
		}

		//_debug.warning("Unknown bar scale:" + VAR(scale));
		return 1;
	}

	// Ширина бара (включая зазор) в пикселях. Или шаг баров в пикселях.
	int bar_step() const
	{
		return 1 << scale();
	}

	bool is_current() const
	{
		return id_ == 0 || id_ == ChartID();
	}

	bool navigate_end(int bars_to_navigate = 0) const
	{
		return ChartNavigate(id_, CHART_END, bars_to_navigate);
	}

	bool check_change(bool check_size, bool check_price, bool check_new_bar, int window = 0)
	{
		bool bad_data = false;
		bool need_update = false;

		if (check_size)
		{
			const int chart_width_in_bars = width_in_bars();
			const int chart_first_visible_bar = first_visible_bar();
			const int chart_height_in_pixels = height_in_pixels(window);
			const int chart_width_in_pixels = width_in_pixels();

			bad_data = bad_data ||
				chart_width_in_bars == 0 ||
				chart_first_visible_bar == 0 ||
				chart_height_in_pixels == 0 ||
				chart_width_in_pixels == 0;

			need_update = need_update ||
				chart_width_in_bars != chart_width_in_bars_ ||
				chart_first_visible_bar != chart_first_visible_bar_ ||
				chart_height_in_pixels != chart_height_in_pixels_ ||
				chart_width_in_pixels != chart_width_in_pixels_;

			if (!bad_data)
			{
				chart_width_in_bars_ = chart_width_in_bars;
				chart_first_visible_bar_ = chart_first_visible_bar;
				chart_height_in_pixels_ = chart_height_in_pixels;
				chart_width_in_pixels_ = chart_width_in_pixels;
			}
		}

		if (check_price)
		{
			const double chart_price_max = price_max(window);
			const double chart_price_min = price_min(window);

			bad_data = bad_data ||
				chart_price_max == chart_price_min;

			need_update = need_update ||
				chart_price_max != chart_price_max_ ||
				chart_price_min != chart_price_min_;


			if (!bad_data)
			{
				chart_price_max_ = chart_price_max;
				chart_price_min_ = chart_price_min;
			}
		}

		if (check_new_bar)
		{
			const datetime time = (datetime)SymbolInfoInteger(symbol(), SYMBOL_TIME);
			const datetime chart_zero_bar_time = time - (time % PeriodSeconds());

			bad_data = bad_data ||
				chart_zero_bar_time == 0;

			need_update = need_update ||
				chart_zero_bar_time != chart_zero_bar_time_;

			if (!bad_data)
				chart_zero_bar_time_ = chart_zero_bar_time;
		}

		return need_update && !bad_data;
	}

	bool is_visible()
	{
		if (is_minimized())
			return false;

		return true;
	}

private:

	CChart* set(ENUM_CHART_PROPERTY_DOUBLE  property_id, double value) { ChartSetDouble (id_, property_id, value); return &this; }
	CChart* set(ENUM_CHART_PROPERTY_INTEGER property_id, long   value) { ChartSetInteger(id_, property_id, value); return &this; }
	CChart* set(ENUM_CHART_PROPERTY_STRING  property_id, string value) { ChartSetString (id_, property_id, value); return &this; }
	CChart* set(ENUM_CHART_PROPERTY_INTEGER property_id, int window, long value) { ChartSetInteger(id_, property_id, value); return &this; }

	double get(ENUM_CHART_PROPERTY_DOUBLE  property_id, int window = 0) const { return ChartGetDouble (id_, property_id, window); }
	long   get(ENUM_CHART_PROPERTY_INTEGER property_id, int window = 0) const { return ChartGetInteger(id_, property_id, window); }
	string get(ENUM_CHART_PROPERTY_STRING  property_id                ) const { return ChartGetString (id_, property_id        ); }
};

CChart _chart;
