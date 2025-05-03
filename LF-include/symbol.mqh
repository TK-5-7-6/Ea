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

// Symbol helper. © FXcoder

#include "sym.mqh"

#define _SYMBOL_GET(N, T, P) T N() const { return((T)get(P)); }
#define _SYMBOL_SET(N, T, P) CBSymbol *N(T value) { return(set(P, value)); }

class CSymbol
{
private:

	const string name_;
	const bool is_current_;

public:

	void CSymbol():
		name_(_Symbol),
		is_current_(true)
	{
	}

	void CSymbol(string symbol):
		name_(_sym.real(symbol)),
		is_current_(_sym.is_current(symbol))
	{
	}

	string name() const { return name_; }

	bool select(bool select) const { return(SymbolSelect(name_, select)); }

	_SYMBOL_GET(ask, double, SYMBOL_ASK)
	_SYMBOL_GET(bid, double, SYMBOL_BID)
	_SYMBOL_GET(currency_profit, string, SYMBOL_CURRENCY_PROFIT)
	_SYMBOL_GET(exists, bool, SYMBOL_EXIST)
	_SYMBOL_GET(selected, bool, SYMBOL_SELECT)
	_SYMBOL_GET(time, datetime, SYMBOL_TIME)
	_SYMBOL_GET(trade_contract_size, double, SYMBOL_TRADE_CONTRACT_SIZE)
	_SYMBOL_GET(trade_tick_size, double, SYMBOL_TRADE_TICK_SIZE)
	_SYMBOL_GET(trade_tick_value, double, SYMBOL_TRADE_TICK_VALUE)
	_SYMBOL_GET(volume_min, double, SYMBOL_VOLUME_MIN)

	// selected_only - искать только в выбранных (в обзоре рынка)
	bool exists(bool selected_only) const
	{
		return exists() && (!selected_only || selected());
	}

	bool tick(MqlTick &tick) const { return SymbolInfoTick(name_, tick); }

private:

	double get(ENUM_SYMBOL_INFO_DOUBLE  property_id) const { return SymbolInfoDouble (name_, property_id); }
	long   get(ENUM_SYMBOL_INFO_INTEGER property_id) const { return SymbolInfoInteger(name_, property_id); }
	string get(ENUM_SYMBOL_INFO_STRING  property_id) const { return SymbolInfoString (name_, property_id); }
};

CSymbol _symbol;
