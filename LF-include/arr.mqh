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

// Array. © FXcoder

typedef int (*StringSortingComparer)(const string&, const string&);

class CArrayUtil
{
public:

	// Клонировать массив. В отличие от ArrayCopy, размер выходного массива всегда равен размеру входного.
	// Параметры и результат совместимы с ArrayCopy.
	template <typename TDst, typename TSrc>
	static bool clone(TDst &dst[], const TSrc &src[])
	{
		int size = ArraySize(src);
		if (ArrayResize(dst, size) != size)
			return false;

		return ArrayCopy(dst, src) == size;
	}

	template <typename T>
	static int resize_init(T &arr[], int size, T value, int reserve = 0)
	{
		int res_size = ArrayResize(arr, size, reserve);
		if (res_size != size)
			return false;

		return ArrayInitialize(arr, value) == size;
	}

	/*
	Найти значение в массиве и вернуть индекс элемента.
	@param arr[]  Массив для поиска
	@param value  Искомое значение
	@param first  Индекс начала поиска
	@return       Индекс найденного элемента или -1, если значение не найдено.
	*/
	template <typename T>
	static int index_of(const T &arr[], T value, int first = 0)
	{
		for (int i = first, size = ArraySize(arr); i < size; ++i)
		{
			if (arr[i] == value)
				return i;
		}

		return -1;
	}

	/*
	Определить, есть ли значение в массиве.
	Поиск производится, начиная с элемента с индексом starting_from. См. также ArrayIndexOf
	@param arr[]  Массив для поиска
	@param value  Искомое значение
	@param first  Индекс начала поиска
	@return       true - значение есть в массиве, false - нет.
	*/
	template <typename T>
	static bool contains(const T &arr[], T value, int first = 0)
	{
		return index_of(arr, value, first) >= 0;
	}

	/*
	Проверка и коррекция границ диапазона для указанного массива. Выходные параметры должны обеспечивать
	безопасность обхода массива по ним.
	@param arr        Массив.
	@param first      Начальный элемент в массиве для обработки. Может быть отрицательным.
	@param count      Количество элементов для обрабтоки, <0 - до конца массива.
	@return           true, если границы в норме, либо их удалось привести к норме. false, если границы
	                  не пересекаются с массивом. Если массив пустой, то пересечения нет.
	*/
	template <typename T>
	static bool check_range(const T &arr[], int &first, int &count)
	{
		if (count == 0)
			return false;

		const int size = ArraySize(arr);
		if (size <= 0)
			return false;

		if (count < 0)
			count = size - first;

		const int arr_last = size - 1;
		int last = first + count - 1;

		if (last < 0)
			return false;

		if (first > arr_last)
			return false;

		if (first < 0)
			first = 0;

		if (last > arr_last)
			last = arr_last;

		// здесь count уже не может быть <=0 из-за проверок выше
		count = last - first + 1;
		return true;
	}

	/*
	Сортировать массив.
	Алгоритм - сортировка Хоара / quicksort.

	@param array     Массив для сортировки.
	@param comparer  Указатель на функцию сравнения.
	*/
	template <typename T, typename TComparer>
	static void sort(T &arr[], const TComparer comparer)
	{
		const int MAXSTACK = 64;
		int size = ArraySize(arr);
	 	if (size <= 0)
			return;

	 	// указатели, участвующие в разделении границы сортируемого в цикле фрагмента
		int i, j;
		int lb, ub;

		// стек запросов
		int lbstack[], ubstack[];
		ArrayResize(lbstack, MAXSTACK);
		ArrayResize(ubstack, MAXSTACK);

		// каждый запрос задается парой значений, а именно: левой(lbstack) и правой(ubstack) границами промежутка
		int stackpos = 1;  // текущая позиция стека
		int ppos;          // середина массива
		T pivot;           // опорный элемент
		T temp;

		lbstack[1] = 0;
		ubstack[1] = size - 1;

		do
		{
			// Взять границы lb и ub текущего массива из стека.
			lb = lbstack[stackpos];
			ub = ubstack[stackpos];
			stackpos--;

			do
			{
				// Шаг 1. Разделение по элементу pivot
				ppos = (lb + ub) >> 1;
				i = lb;
				j = ub;
				pivot = arr[ppos];

				do
				{
					//while (arr[i] < pivot)
					while (comparer(arr[i], pivot) < 0)
						i++;

					//while (pivot < arr[j])
					while (comparer(pivot, arr[j]) < 0)
						j--;

					if (i <= j)
					{
						temp = arr[i];
						arr[i] = arr[j];
						arr[j] = temp;

						i++;
						j--;
					}
				}
				while (i <= j);

				// Сейчас указатель i указывает на начало правого подмассива,
				// j - на конец левого (см. иллюстрацию выше), lb ? j ? i ? ub.
				// Возможен случай, когда указатель i или j выходит за границу массива

				// Шаги 2, 3. Отправляем большую часть в стек и двигаем lb,ub
				if (i < ppos) // правая часть больше
				{
					if (i < ub) // если в ней больше 1 элемента - нужно сортировать, запрос в стек
					{
						stackpos++;
						lbstack[stackpos] = i;
						ubstack[stackpos] = ub;
					}

					ub = j; // следующая итерация разделения будет работать с левой частью
				}
				else // левая часть больше
				{
					if (j > lb)
					{
						stackpos++;
						lbstack[stackpos] = lb;
						ubstack[stackpos] = j;
					}

					lb = i;
				}
			}
			while (lb < ub); // пока в меньшей части более 1 элемента

		}
		while (stackpos != 0); // пока есть запросы в стеке
	}

	// сортировать строки без учёта регистра
	static void sort_text(string &arr[])
	{
		sort(arr, text_sorting_comparer());
	}

private:

	static StringSortingComparer text_sorting_comparer()
	{
		return compare_sorting;
	}

	// сравнение строк для типовой текстовой сортировки
	static int compare_sorting(const string &s1, const string &s2)
	{
		return StringCompare(s1, s2, false);
	}

} _arr;
