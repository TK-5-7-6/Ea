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

// HashMap extensions. © FXcoder

#include <Generic/HashMap.mqh>

template<typename TKey,typename TValue>
class CMap: public CHashMap<TKey, TValue>
{
public:
	TValue GetOrDefault(TKey key, TValue default_value)
	{
		TValue value;
		return TryGetValue(key, value) ? value : default_value;
	}
};
