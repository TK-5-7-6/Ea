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

// Матрица простых типов, хранение данных в одномерном массиве. © FXcoder


#include "math.mqh"

template <typename T>
class CMatrixL
{
private:

	int row_count_;
	int col_count_;

public:

	T data[];

	void CMatrixL():
		row_count_(0), col_count_(0)
	{
	}

	void CMatrixL(int row_count, int col_count):
		row_count_(0), col_count_(0)
	{
		resize(row_count, col_count);
	}

	void CMatrixL(int row_count, int col_count, T init_value):
		row_count_(0), col_count_(0)
	{
		resize_fill(row_count, col_count, init_value);
	}

	int row_count() const { return row_count_; }
	int col_count() const { return col_count_; }

	// Оператор присваивание. Результат - копия данных в размере источника
	void operator=(const CMatrixL<T> &rhs)
	{
		resize(rhs.row_count(), rhs.col_count());
		ArrayCopy(data, rhs.data, 0, 0, row_count_ * col_count_);
	}

	// Изменить размер. Данные будут искажены, если меняется число столбцов
	bool resize(int row_count, int col_count)
	{
		row_count_ = row_count;
		col_count_ = col_count;
		const int new_size = row_count * col_count;
		return ArrayResize(data, new_size) == new_size;
	}

	// Изменить размер и заполнить значением
	bool resize_fill(int row_count, int col_count, T value)
	{
		row_count_ = row_count;
		col_count_ = col_count;
		const int new_size = row_count * col_count;
		if (ArrayResize(data, new_size) != new_size)
			return false;

		return ArrayInitialize(data, value) == new_size;
	}

	// Инициализировать значением
	void fill(T value)
	{
		ArrayInitialize(data, value); // можно стандартной функцией, т.к. предполагаются только числовые типы
	}
	T get(int row, int col) const
	{
		return data[row * col_count_ + col];
	}

	void set(int row, int col, T value)
	{
		data[row * col_count_ + col] = value;
	}

	// если размер src меньше длины ряда, то оставшиеся значения не меняются
	void set_row(int row, const T &src[])
	{
		int src_size = ArraySize(src);
		int count = _math.min(col_count_, src_size);
		ArrayCopy(data, src, row * col_count_, 0, count);
	}
};
