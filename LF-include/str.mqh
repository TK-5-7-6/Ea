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

// String. © FXcoder

#include <Generic/HashSet.mqh>

class CStringUtil
{
private:

	// альтернативные разделители строковых параметров, разделённых запятой
	static const string comma_alt_separators[];

public:

	static bool is_empty(string s) { return (s == "") || (s == NULL); }

	static bool contains(const string s, const string match, int start_pos = 0)
	{
		return StringFind(s, match, start_pos) >= 0;
	}

	/*
	Сшить массив в одну строку, используя указанный разделитель.
	@param arr[]      Массив.
	@param separator  Разделитель.
	@return           Строка-результат.
	*/
	template <typename T>
	static string join(const T &arr[], string separator)
	{
		int count = ArraySize(arr);
		if (count == 0)
			return "";

		string result = (string)arr[0];

		for (int i = 1; i < count; ++i)
			result += separator + (string)arr[i];

		return result;
	}

	/*
	Преобразовать массив целых чисел в сокращённый список.
	Примеры:
		[1, 2, 3, 4, 5, 6, 7]  => "1..7/7" + suffux
		[3, 5, 8, 13, 21]      => "3..21/5" + suffux
	*/
	static string format_range(const int &range[], string suffix)
	{
		int sorted[];
		ArrayCopy(sorted, range);
		ArraySort(sorted);

		int count = ArraySize(sorted);

		if (count <= 0)
			return "";

		if (count == 1)
			return (string)sorted[0];

		if (count == 2)
			return (string)sorted[0] + "," + (string)sorted[1];

		// all are equal
		if (sorted[0] == sorted[count - 1])
			return string(sorted[0]) + ".." + string(sorted[count - 1]);

		return (string)sorted[0] + ".." + (string)sorted[count - 1] + "/" + (string)count + suffix;
	}

	/*
	Убрать указанные символы в конце строки.
	@param s   Входная строка для преобразований.
	@param ch  Удаляемый символ.
	@return    Строка без указанных символов в конце.
	*/
	static string trim_end(string s, ushort ch)
	{
		int len = StringLen(s);

		// Найти начало вырезаемого до конца участка
		int cut = len;

		for (int i = len - 1; i >= 0; i--)
		{
			if (StringGetCharacter(s, i) != ch)
				break;

			cut--;
		}

		if (cut == len)
			return s;

		return cut == 0 ? "" : StringSubstr(s, 0, cut);
	}

	/*
	Убрать пустые символы в начале и конце строки
	@param s   Входная строка для преобразований.
	@return    Строка без указанных символов в начале и конце.
	*/
	static string trim(string s)
	{
		StringTrimRight(s);
		StringTrimLeft(s);
		return s;
	}

	/*
	Разбить строку на отдельные строки, разделенные в исходной строке указанным разделителем.
	@param s            Входная строка.
	@param sep          Разделитель.
	@param parts[]      Ссылка на результат - массив строк.
	@param skip_empty   Пропускать пустые строки.
	@param unique       Добавлять только уникальные значения.
	@return             Количество строк в результирующем массиве строк. Сам массив передается по ссылке
	                    в параметрах.
	*/
	static int split(string s, string sep, bool skip_empty, bool unique, string &parts[])
	{
		int sep_len = StringLen(sep);

		// Оптимизация наиболее часто используемого варианта за счёт использования стандартной функции со схожим, но ограниченным, функционалом.
		if (!skip_empty && !unique && (sep_len == 1))
		{
			ushort sep_char = StringGetCharacter(sep, 0);
			return StringSplit(s, sep_char, parts);
		}

		int count = 0;
		ArrayResize(parts, StringLen(s) / 2 + 1);
		int pos = 0;
		int start = 0;
		CHashSet<string> part_set;

		while (true)
		{
			pos = StringFind(s, sep, start);

			string part = StringSubstr(s, start, pos < 0 ? -1 : pos - start);

			if (!skip_empty || (trim(part) != ""))
			{
				if (!unique || !part_set.Contains(part))
				{
					parts[count++] = part;

					if (unique)
						part_set.Add(part);
				}
			}

			if (pos < 0)
				break;

			start = pos + sep_len;
		}

		// удалить последнюю пустую строку
		if ((count > 0) && (parts[count - 1] == ""))
			count--;

		return ArrayResize(parts, count);
	}

	static int split_input_csv(string s, bool unique, string &parts[])
	{
		for (int i = ArraySize(comma_alt_separators) - 1; i >= 0; ++i)
			StringReplace(s, comma_alt_separators[0], ",");

		return split(s, ",", true, unique, parts);
	}
};

const string CStringUtil::comma_alt_separators[]   = { /*" ",*/ ";" };

CStringUtil _str;
