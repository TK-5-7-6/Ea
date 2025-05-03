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

// ARGB functions. © FXcoder
#include "math.mqh"

class CARGBUtil
{
public:

	static uint create(uchar a, uchar r, uchar g, uchar b)
	{
		// 0xAARRGGBB
		return uint(((a & 0xFF) << 24) | ((r & 0xFF) << 16) | ((g & 0xFF) << 8) | (b & 0xFF));
	}
	static int alpha(uint c) { return (int)((c & 0xFF000000) >> 24); }

	static void split(uint c, int &a, int &r, int &g, int &b)
	{
		a = (int)((c & 0xFF000000) >> 24);
		r = (int)((c & 0x00FF0000) >> 16);
		g = (int)((c & 0x0000FF00) >> 8);
		b = (int)(c & 0x000000FF);
	}

	// Alpha blending: https://en.wikipedia.org/wiki/Alpha_compositing#Alpha_blending
	static uint mix(uint color1, uint color2)
	{
		int a1i, r1i, g1i, b1i;
		split(color1, a1i, r1i, g1i, b1i);

		if (a1i == 0)
			return color1;

		if (a1i == 255)
			return color2;

		int a2i, r2i, g2i, b2i;
		split(color2, a2i, r2i, g2i, b2i);
		if (a2i == 0)
			return color2;

		float a1 = a1i / 255.0f;
		float r1 = r1i / 255.0f;
		float g1 = g1i / 255.0f;
		float b1 = b1i / 255.0f;

		float a2 = a2i / 255.0f;
		float r2 = r2i / 255.0f;
		float g2 = g2i / 255.0f;
		float b2 = b2i / 255.0f;

		float aa = a1 + a2 * (1.0f - a1);

		int aai = _math.round_to_int(aa * 255.0f);
		if (aai <= 0)
			return 0;

		int rri = _math.round_to_int(((r1 * a1 + r2 * a2 * (1.0f - a1)) / aa) * 255.0f);
		int ggi = _math.round_to_int(((g1 * a1 + g2 * a2 * (1.0f - a1)) / aa) * 255.0f);
		int bbi = _math.round_to_int(((b1 * a1 + b2 * a2 * (1.0f - a1)) / aa) * 255.0f);

		return create(
			_math.clamp_to_uchar(aai),
			_math.clamp_to_uchar(rri),
			_math.clamp_to_uchar(ggi),
			_math.clamp_to_uchar(bbi));
	}
} _argb;
