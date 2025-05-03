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

// Color. © FXcoder

#include "hsv.mqh"
#include "math.mqh"

class CColorUtil
{
public:

	// Проверить, является ли цвет неопределенным.
	// @param c  Цвет для проверки
	// @return   true, если цвет не определен, false, если определен.
	static bool is_none(color c)
	{
		return (c >> 24) != 0;
	}

	// не none
	static bool is_valid(color c)
	{
		return (c >> 24) == 0;
	}

	// проверить, является ли цвет валидным. если нет, то вернуть fallback
	static color validate(color c, color fallback)
	{
		return is_valid(c) ? c : fallback;
	}

	static color create(uchar r, uchar g, uchar b)
	{
		// 0x00BBGGRR
		return color(((b & 0xFF) << 16) | ((g & 0xFF) << 8) | (r & 0xFF));
	}


	/*
	Инвертировать цвет.
	@param c  Исходный цвет.
	@return   Цвет - результат инверсии.
	*/
	static color invert(color c)
	{
		return color(c ^ 0xFFFFFF);
	}

	/*
	Invert and rotate hue by 180 degrees.
	*/
	static color invert_save_hue(color c)
	{
		return _hsv.to_color(_hsv.shift_hue(to_hsv(c), 180));
	}

	// hue: 0..360
	// saturation, value: 0..255
	// r,g,b: 0..255
	// формулы из вики
	// 0 при неудаче
	static uint to_hsv(color c)
	{
		int ri, gi, bi;
		if (!split(c, ri, gi, bi))
			return 0;

		double d = 1.0 / 255.0;

		double r = d * ri;
		double g = d * gi;
		double b = d * bi;

		double max = _math.max(r, g, b);
		double min = _math.min(r, g, b);
		double range = max - min;

		int hue;

		if (max == min)
		{
			hue = 0;
		}
		else if (max == r)
		{
			hue = _math.round_to_int(60.0 * (g - b) / range) + (g >= b ? 0 : 360);
		}
		else if (max == g)
		{
			hue = _math.round_to_int(60.0 * (b - r) / range) + 120;
		}
		else // if (max == b)
		{
			hue = _math.round_to_int(60.0 * (r - g) / range) + 240;
		}

		uchar saturation = max == 0 ? 0 : _math.clamp_to_uchar(255.0 * range / max);
		uchar value = (uchar)_math.max(ri, gi, bi);
		return _hsv.create(_hsv.normalize_hue(hue), saturation, value);
	}

	/*
	Смешать цвета в заданных пропорциях.
	Терминал поддерживает только ограниченное число цветов, поэтому использование всей палитры RGB приводит к ошибкам
	в отображении не только индикатора, но и самого графика. Для ограничения палитры введен параметр шага.

	@param color1  Цвет 1
	@param color2  Цвет 2
	@param mix     Пропорция смешивания (0..1). При mix=0 получается цвет 1, при mix=1 получается цвет 2.
	@param step    Шаг цвета, огрубление (1..255).
	@return        Цвет - результат смешения.
	*/
	static color mix(color color1, color color2, double mix, double step = 16.0)
	{
		int r1, g1, b1;
		split(color1, r1, g1, b1);

		int r2, g2, b2;
		split(color2, r2, g2, b2);

		// вычислить
		const uchar r = _math.clamp_to_uchar(_math.round_err(r1 + mix * (r2 - r1), step));
		const uchar g = _math.clamp_to_uchar(_math.round_err(g1 + mix * (g2 - g1), step));
		const uchar b = _math.clamp_to_uchar(_math.round_err(b1 + mix * (b2 - b1), step));

		return create(r, g, b);
	}

	/*
	Разложить цвет на компоненты.

	@param c  Исходный цвет
	@param r  Результат: красная составляющая
	@param g  Результат: зеленая составляющая
	@param b  Результат: синяя составляющая
	@return   Успех операции. Разложение не может быть осуществлено для неопределенного цвета, параметры r, g и b при
	          этом остаются без изменений.
	*/
	static bool split(color c, int &r, int &g, int &b)
	{
		// Если цвет задан неверный, либо задан как отсутствующий, вернуть false
		if (is_none(c))
			return false;

		b = (c & 0xFF0000) >> 16;
		g = (c & 0x00FF00) >> 8;
		r = (c & 0x0000FF);
		return true;
	}

	static bool split_uchar(color c, uchar &r, uchar &g, uchar &b)
	{
		// Если цвет задан неверный, либо задан как отсутствующий, вернуть false
		if (is_none(c))
			return false;

		b = (uchar)((c & 0xFF0000) >> 16);
		g = (uchar)((c & 0x00FF00) >> 8);
		r = (uchar)((c & 0x0000FF));
		return true;
	}
} _color;
