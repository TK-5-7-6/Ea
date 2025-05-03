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

#property copyright "LF: Line Field v10.0. © FXcoder"
#property link      "https://fxcoder.blogspot.com"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots 0
#property description "Indicator line field (SMA, BB, PC)."


#include <Canvas/Canvas.mqh>
#include "LF-include/chartevent.mqh"
#include "LF-include/symbol.mqh"
#include "LF-include/enum/mtkey.mqh"
#include "LF-include/lf/lf_indicator.mqh"
#include "LF-include/lf/enum/lf_field.mqh"


input ENUM_LF_FIELD Field = LF_FIELD_SMA_BB; // Field Type

input group  "PERIODS"
input int    PeriodCount = 1111; // Count
input int    PeriodStart = 1;    // First
input int    PeriodEnd   = 7777; // Last

input group  "VIEW"
input bool   ShowExtra   = true; // Show Extra
input double Brightness  = 3.0;  // Brightness
input double Gamma       = 2.0;  // Gamma Correction

input group  "FIELD 1"
input color  Field1ColorFirst = clrDeepSkyBlue; // First Color
input color  Field1ColorLast  = clrRoyalBlue;   // Last Color

input group  "FIELD 2"
input color  Field2ColorFirst = clrOrangeRed; // First Color
input color  Field2ColorLast  = clrCrimson;   // Last Color

input group      "..."
input string     ZeroLineName  = "z";     // Zero Line Name
input ENUM_MTKEY ControlKey    = MTKEY_Q; // Control Key
input bool       OpenCLCalc    = false;   // Use OpenCL for indicators
input bool       OpenCLTrans   = true;    // Use OpenCL for transformations


CLFIndicator lf_(Field, PeriodCount, PeriodStart, PeriodEnd, ShowExtra, Brightness, Gamma,
	Field1ColorFirst, Field1ColorLast, Field2ColorFirst, Field2ColorLast,
	ZeroLineName, ControlKey, OpenCLCalc, OpenCLTrans);

// иногда OnChartEvent и OnTimer приходят раньше OnCalculate,
//   можно проверять по последнему бару
datetime last_on_calculate_bar_time_ = 0;


void OnInit()
{
	lf_.init();

	EventSetMillisecondTimer(55);
}

int OnCalculate(const int rates_total, const int prev_calculated, const int begin, const double& price[])
{
	last_on_calculate_bar_time_ = _time.begin_of_period(_symbol.time());
	return lf_.calculate(rates_total, prev_calculated, price);
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
	_chartevent.update(id, lparam, dparam, sparam);

	if (check_data())
		lf_.chart_event();
}

void OnTimer()
{
	if (check_data())
		lf_.timer();
}

void OnDeinit(const int reason)
{
	EventKillTimer();
	lf_.deinit(reason);
}

bool check_data()
{
	const datetime last_bar_open_time = _time.begin_of_period(_symbol.time());

	// no data?
	if (last_bar_open_time == 0)
	{
		return false;
	}

	// synchronized?
	if (last_bar_open_time != last_on_calculate_bar_time_)
	{
		return false;
	}

	return true;
}
