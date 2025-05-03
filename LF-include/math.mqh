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

// Math. © FXcoder

class CMathUtil
{
public:

	static const double nan; // not a number

	static int  round_to_int  (double value) { return  int(value >= 0.0  ? value + 0.5  : value - 0.5);  }
	static long round_to_long (double value) { return long(value >= 0.0  ? value + 0.5  : value - 0.5);  }

	template <typename T> static T max(T a, T b) { return a > b ? a : b; }
	template <typename T> static T min(T a, T b) { return a < b ? a : b; }

	template <typename T> static T max(T a, T b, T c) { return a > b ? max(a, c) : max(b, c); }
	template <typename T> static T min(T a, T b, T c) { return a < b ? min(a, c) : min(b, c); }

	template <typename T> static T max(const T &arr[], int first, int count) { return arr[ArrayMaximum(arr, first, count)]; }
	template <typename T> static T min(const T &arr[], int first, int count) { return arr[ArrayMinimum(arr, first, count)]; }

	static double max(const double &arr[], double fallback = 0.0)
	{
		int index = ArrayMaximum(arr);
		return index < 0 ? fallback : arr[index];
	}

	static double min(const double &arr[], double fallback = 0.0)
	{
		int index = ArrayMinimum(arr);
		return index < 0 ? fallback : arr[index];
	}

	static int max(const int &arr[], int fallback = 0)
	{
		int index = ArrayMaximum(arr);
		return index < 0 ? fallback : arr[index];
	}

	static int max_sorted(const int &arr[], int fallback = 0)
	{
		int size = ArraySize(arr);
		return size > 0 ? max(arr[0], arr[size - 1]) : fallback;
	}

	// start <= value < end
	template <typename T>
	static bool is_in(T value, T start, T end)
	{
		return value >= start && value < end;
	}

	/*
	Поместить значение в указанный диапазон.
	Предполагается использование с числовыми значениями, работа с другими типами не проверялась.
	@param value  Исходное значение.
	@param min    Нижняя граница диапазона.
	@param max    Верхняя граница диапазона.
	@return       Значение, помещенное в указанный диапазон. Например, для clamp(5, 10, 20)
	              будет возвращено 10. Если параметр to меньше параметра from, значение value
	              будет возвращено без изменений.
	*/
	template <typename T> static T clamp(T value, T min_value, T max_value)
	{
		if (max_value < min_value)
			return value;

		if (value > max_value)
			return max_value;

		if (value < min_value)
			return min_value;

		return value;
	}

	static uchar clamp_to_uchar(int v)    { return v < 0 ? 0 : (v > UCHAR_MAX ? UCHAR_MAX : (uchar)v); }
	static uchar clamp_to_uchar(double v) { return clamp_to_uchar(round_to_int(v)); }

	// округлить с указанной ошибкой
	static double round_err(double value, double error)
	{
		return error == 0 ? value : (round(value / error) * error);
	}

	static double sqr(const double value)
	{
		return value * value;
	}

	static double mean(const double &arr[], double fallback = 0.0)
	{
		int size = ArraySize(arr);
		if (size == 0)
			return fallback;

		const double q = 1.0 / size;
		double res = 0.0;

		for (int i = 0; i < size; ++i)
			res += arr[i] * q;

		return res;
	}

	// сумма пустого массива = 0
	static double sum(const double &arr[])
	{
		double sum = 0.0;

		for (int i = 0, size = ArraySize(arr); i < size; ++i)
			sum += arr[i];

		return sum;
	}

	/*
	Вычислить медиану. Медиана - середина отсортированного массива.

	@param &arr[]    Массив чисел, для которых будет рассчитана медиана.
	@param first     Стартовая позиция для расчета. Если не указано, расчет будет производиться с начала массива.
	@param count     Количество элементов массива для расчета, начиная с позиции first.
	@return          Медиана.
	*/
	static double median(const double &arr[])
	{
		if (ArraySize(arr) == 0)
			return nan;

		double sorted_arr[];
		ArrayCopy(sorted_arr, arr);
		ArraySort(sorted_arr);

		return median_sorted(sorted_arr);
	}

	static double median_sorted(const double &sorted_arr[])
	{
		int count = ArraySize(sorted_arr);
		if (count == 0)
			return nan;

		if (count % 2 == 1)
			return sorted_arr[count / 2];
		else
			return (sorted_arr[count / 2 - 1] + sorted_arr[count / 2]) / 2.0;
	}

	static bool quartiles(const double &arr[], bool odd_include_median, double &quartiles[])
	{
		double sorted_arr[];
		ArrayCopy(sorted_arr, arr);
		ArraySort(sorted_arr);
		return quartiles_sorted(sorted_arr, odd_include_median, quartiles);
	}

	static bool quartiles_sorted(const double &sorted_arr[], bool odd_include_median, double &quartiles[])
	{
		int count = ArraySize(sorted_arr);
		if (count == 0)
			return false;

		if (ArrayIsDynamic(quartiles))
			ArrayResize(quartiles, 3);

		if (ArraySize(quartiles) < 3)
			return false;

		const bool is_odd = (count % 2) != 0;
		const int last = count - 1;

		double q1 = 0.0;
		double q2 = 0.0;
		double q3 = 0.0;

		if (is_odd)
		{
			q2 = sorted_arr[count / 2];

			if (odd_include_median)
			{
				const int q13_count = count / 2 + 1;
				const int q1i = q13_count / 2;
				const bool is_q13_odd = (q13_count % 2) != 0;

				if (is_q13_odd)
				{
					//  0  1  2   3  4   5  6   7  8
					// [ ][ ][Q1][ ][Q2][ ][Q3][ ][ ]
					q1 = sorted_arr[q1i];
					q3 = sorted_arr[last - q1i];
				}
				else
				{
					//  0  1      2  3   4      5  6
					// [ ][ ] Q1 [ ][Q2][ ] Q3 [ ][ ]
					q1 = (sorted_arr[q1i - 1] + sorted_arr[q1i]) / 2.0;
					q3 = (sorted_arr[last - (q1i - 1)] + sorted_arr[last - q1i]) / 2.0;
				}
			}
			else
			{
				const int q13_count = count / 2;
				const int q1i = q13_count / 2;
				const bool is_q13_odd = (q13_count % 2) != 0;

				if (is_q13_odd)
				{
					//  0  1  2   3  4   5    6  7  8   9  10
					// [ ][ ][Q1][ ][ ] [Q2] [ ][ ][Q3][ ][ ]
					q1 = sorted_arr[q1i];
					q3 = sorted_arr[last - q1i];
				}
				else
				{
					//  0  1      2  3   4    5  6      7  8
					// [ ][ ] Q1 [ ][ ] [Q2] [ ][ ] Q3 [ ][ ]
					q1 = (sorted_arr[q1i - 1] + sorted_arr[q1i]) / 2.0;
					q3 = (sorted_arr[last - (q1i - 1)] + sorted_arr[last - q1i]) / 2.0;
				}
			}
		}
		else
		{
			q2 = (sorted_arr[count / 2 - 1] + sorted_arr[count / 2]) / 2.0;

			const int q13_count = count / 2;
			const int q1i = q13_count / 2;
			const bool is_q13_odd = (q13_count % 2) != 0;

			if (is_q13_odd)
			{
				//  0  1   2      3  4   5
				// [ ][Q1][ ] Q2 [ ][Q3][ ]
				q1 = sorted_arr[q1i];
				q3 = sorted_arr[last - q1i];
			}
			else
			{
				//  0      1      2      3
				// [ ] Q1 [ ] Q2 [ ] Q3 [ ]
				q1 = (sorted_arr[q1i - 1] + sorted_arr[q1i]) / 2.0;
				q3 = (sorted_arr[last - (q1i - 1)] + sorted_arr[last - q1i]) / 2.0;
			}
		}

		quartiles[0] = q1;
		quartiles[1] = q2;
		quartiles[2] = q3;
		return true;
	}
};

const double CMathUtil::nan = log(-1); // NaN

CMathUtil _math;
