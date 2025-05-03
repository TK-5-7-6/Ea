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

// Функции цвета HSV. © FXcoder

#include "color.mqh"
#include "math.mqh"

class CHSVUtil
{
public:

	static uint create(ushort h, uchar s, uchar v)
	{
		h = normalize_hue(h);
		return (h << 16) | (s << 8) | v;
	}

	// hue: 0..360
	// saturation, value: 0..255
	// r,g,b: 0..255
	// формулы из вики
	static uint create_from_rgb(uchar red, uchar green, uchar blue)
	{
		double d = 1.0 / 255.0;

		double r = d * red;
		double g = d * green;
		double b = d * blue;

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
		uchar value = _math.max(red, green, blue);
		return create(normalize_hue(hue), saturation, value);
	}


	// -> 0..359
	static ushort normalize_hue(int h)
	{
		h = h % 360;

		if (h < 0)
			h += 360;

		return ushort(h);
	}

	static uint normalize(uint hsv)
	{
		ushort h = normalize_hue(hue(hsv));
		return (hsv & 0x0000FFFF) | (h << 16); // clear old H and set new H
	}

	static uint shift_hue(uint hsv, int shift, bool normalize = true)
	{
		int h = hue(hsv) + shift;
		if (normalize)
			h = normalize_hue(h);

		return (hsv & 0x0000FFFF) | (h << 16); // clear old H and set new H
	}

	// Компоненты HSV
	static int hue(uint hsv) { return (int)((hsv & 0x0FFF0000) >> 16); }
	//static int s(uint hsv) { return (int)((hsv & 0x0000FF00) >> 8); }
	//static int v(uint hsv) { return (int)( hsv & 0x000000FF); }
	//static ushort h_ushort(uint hsv) { return ushort((hsv & 0x0FFF0000) >> 16); }
	//static uchar  s_uchar (uint hsv) { return  uchar((hsv & 0x0000FF00) >> 8); }
	//static uchar  v_uchar (uint hsv) { return  uchar( hsv & 0x000000FF); }

	static void split(uint hsv, int &h, int &s, int &v)
	{
		h = (int)(hsv & 0x0FFF0000) >> 16;
		s = (int)(hsv & 0x0000FF00) >> 8;
		v = (int)(hsv & 0x000000FF);
	}

	// hsv: 0x0HHHSSVV
	static color to_color(uint hsv)
	{
		int h, s, v;
		split(hsv, h, s, v);
		//h = normalize_hue(h);

		uchar r, g, b;
		to_rgb((ushort)h, (uchar)s, (uchar)v, r, g, b);
		return _color.create(r, g, b);
	}

	static uint mix(uint hsv1, uint hsv2, double mix, double step)
	{
		mix = _math.clamp(mix, 0.0, 1.0);

		int h1, s1, v1;
		split(hsv1, h1, s1, v1);

		int h2, s2, v2;
		split(hsv2, h2, s2, v2);

		// Вычислить промежуточные компоненты, учесть разные ограничения на шаг

		step = _math.clamp(step, 1.0, 360.0);
		ushort h = (ushort)_math.clamp(
				_math.round_to_int(_math.round_err(h1 + mix * (h2 - h1), step)),
				0, (int)USHORT_MAX);

		step = _math.clamp(step, 1.0, 255.0);
		uchar s = _math.clamp_to_uchar(_math.round_err(s1 + mix * (s2 - s1), step));
		uchar v = _math.clamp_to_uchar(_math.round_err(v1 + mix * (v2 - v1), step));
		return create(h, s, v);
	}

private:

	// hue: 0..359
	// saturation, value: 0..255
	// r,g,b: 0..255
	// формулы из вики
	static void to_rgb(ushort hue, uchar saturation, uchar value, uchar &red, uchar &green, uchar &blue)
	{
		double s = (double)saturation;
		double v = (double)value;

		int hi = (hue / 60) % 6; // целоч. деление с окгруглением вниз

		double v_min = (255.0 - s) * v / 255.0;
		double a = (v - v_min) * (double)(hue % 60) / 60.0;
		double v_inc = v_min + a;
		double v_dec = v - a;

		double r, g, b;

		if (hi == 0)
		{
			r = v;
			g = v_inc;
			b = v_min;
		}
		else if (hi == 1)
		{
			r = v_dec;
			g = v;
			b = v_min;
		}
		else if (hi == 2)
		{
			r = v_min;
			g = v;
			b = v_inc;
		}
		else if (hi == 3)
		{
			r = v_min;
			g = v_dec;
			b = v;
		}
		else if (hi == 4)
		{
			r = v_inc;
			g = v_min;
			b = v;
		}
		else // if (hi == 5)
		{
			r = v;
			g = v_min;
			b = v_dec;
		}

		red   = _math.clamp_to_uchar(r);
		green = _math.clamp_to_uchar(g);
		blue  = _math.clamp_to_uchar(b);
	}

} _hsv;
