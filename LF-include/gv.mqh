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

// Класс глобальной переменной. © FXcoder


#define GV_EVENTN_PREFIX     "+.eventn."
#define GV_EVENTN_Z_NAME     GV_EVENTN_PREFIX + "z"
#define GV_EVENTN_Z_DEFAULT  1

class CGV
{
private:

	string name_;

public:

	void CGV():
		name_("")
	{
	}

	void CGV(string name):
		name_(name)
	{
	}

	void CGV(int index):
		name_("")
	{
		name_ = GlobalVariableName(index);
	}

	CGV*   name(string name) { name_ = name; return &this; }
	string name() const      { return name_; }


	// Проверяет существование глобальной переменной клиентского терминала.
	bool check() const
	{
		return GlobalVariableCheck(name_);
	}

	// Удаляет глобальную переменную клиентского терминала.
	bool del() const
	{
		return GlobalVariableDel(name_);
	}

	// Возвращает значение существующей глобальной переменной клиентского терминала.
	double get_or_default(double default_value) const
	{
		double value;
		return GlobalVariableGet(name_, value) ? value : default_value;
	}

	bool get(double &value) const
	{
		double tmp;

		if (!GlobalVariableGet(name_, tmp))
			return false;

		value = tmp;
		return true;
	}

	// Устанавливает новое значение глобальной переменной.
	datetime set(double value)  const
	{
		return GlobalVariableSet(name_, value);
	}

	// Производит попытку создания временной глобальной переменной.
	bool temp() const
	{
		return GlobalVariableTemp(name_);
	}

	// Возвращает время последнего доступа к глобальной переменной.
	datetime time() const
	{
		return GlobalVariableTime(name_);
	}

	// Устанавливает новое значение существующей глобальной переменной, если текущее значение переменной равно значению третьего параметра check_value.
	// Если в ГП установлено значение check_value, то установить новое value. Атомарная операция (с блокировкой).
	// Например, установить флаг занятости: if (!(set_on_condition(1, 0)) Print("Занято!");
	bool set_on_condition(double value, double check_value) const
	{
		return GlobalVariableSetOnCondition(name_, value, check_value);
	}

};
