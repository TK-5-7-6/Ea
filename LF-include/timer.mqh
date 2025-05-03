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

// Timer. © FXcoder


#include "time.mqh"


/**
Таймер для для миллисекунд. © FXcoder

Для проверки срабатывания таймера необходимо проверять его состояние через метод check().
При срабатывании таймера происходит его перезапуск.

Важно! В тестере после создания объекта при необходимости вызвать restart явно, указав время.

@code
void OnStart()
{
	// Два таймера
    CTimer timer5sec(5 * 1000);
    CTimer timer1min(60 * 1000);

    while (!IsStopped())
    {
        if (timer5sec.check())
            Print("Сработал 5-секундный таймер");

        if (timer1min.check())
            Print("Сработал 1-минутный таймер");
    }
}
@endcode
*/
class CTimer
{
private:

	uint milliseconds_;
	ulong last_tick_;
	bool is_active_;

public:

	uint   milliseconds () const { return milliseconds_; }
	double seconds      () const { return milliseconds_ / 1000.0; }

	/**
	Конструктор.
	В тестере желательно сразу вызвать restart с указанием времени (например, взять из последнего тика).
	@param milliseconds     Период таймера в миллисекундах.
	@param wait_first_time  Ждать первый раз. Если ждать, то первый раз таймер сработает через
	                        milliseconds мс, иначе - сразу при первой проверке.
	*/
	void CTimer(uint milliseconds, bool wait_first_time = true):
		milliseconds_(milliseconds),
		is_active_(true),
		last_tick_(0)
	{
		if (wait_first_time)
			restart();
	}

	void CTimer():
		milliseconds_(0),
		is_active_(false),
		last_tick_(0)
	{
	}

	bool is_active() const { return is_active_; }

	/**
	Проверить состояние таймера.
	@return  true, если таймер сработал. false, если нет.
	*/
	bool check(ulong time_msc = 0)
	{
		if (!is_active_)
			return false;

		const ulong now = time_msc == 0 ? GetTickCount64() : time_msc;

		if (!check_once(now))
			return false;

		restart_at(now);
		return true;
	}

	/**
	Проверить однократое срабатывание таймера. После первого срабатывания таймер будет остановлен
	до перезапуска функцией restart().
	@return  true, если таймер сработал. false, если нет.
	*/
	bool check_once(ulong time_msc = 0)
	{
		if (!is_active_)
			return false;

		// проверить ожидание
		const ulong now = time_msc == 0 ? GetTickCount64() : time_msc;
		const bool res = now >= last_tick_ + milliseconds_;

		// сбросить и остановить таймер
		if (res)
		{
			last_tick_ = now;
			stop();
		}

		return res;
	}

	/**
	Перезапустить таймер.
	*/
	void restart()
	{
		restart_at(GetTickCount64());
	}

	/**
	Перезапустить таймер.
	*/
	void restart_at(ulong time_msc)
	{
		last_tick_ = time_msc;
		is_active_ = true;
	}

	/**
	Перезапустить таймер.
	@param milliseconds  Период таймера в мс.
	*/
	void restart(uint milliseconds)
	{
		restart_at(milliseconds, GetTickCount64());
	}

	/**
	Перезапустить таймер. Вариант с явным указанием времени (можно указать 0, чтобы не ждать первый раз).
	@param milliseconds  Период таймера в мс.
	*/
	void restart_at(uint milliseconds, ulong time_msc)
	{
		milliseconds_ = milliseconds;
		last_tick_ = time_msc;
		is_active_ = true;
	}

	void stop()
	{
		is_active_ = false;
	}

	uint elapsed(ulong time_msc = 0) const
	{
		if (!is_active_)
			return 0;

		const ulong now = time_msc == 0 ? GetTickCount64() : time_msc;

		return (uint)(now - last_tick_);
	}
};
