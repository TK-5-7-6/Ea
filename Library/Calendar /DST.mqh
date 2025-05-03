#property strict

#define HOUR 3600
#define DAY (24 * HOUR)
#define WEEK2 7

class DST
{
private:
// https://www.mql5.com/ru/forum/376510#comment_24723343
  static ENUM_DAY_OF_WEEK TimeDayOfWeek( const datetime time )
  {
    return((ENUM_DAY_OF_WEEK)((time / DAY + THURSDAY) % WEEK2));
  }

  static void CheckTime( datetime &dTime )
  {
  #ifdef __MQL5__
    const datetime NewTime = ::TimeTradeServer();
  #else // #ifdef __MQL5__
    const datetime NewTime = ::TimeCurrent();
  #endif // #ifdef __MQL5__ #else

    if (dTime <= 0)
      dTime = NewTime;
    else if (dTime > NewTime)
      dTime = NewTime;

    return;
  }

  static datetime PrevFullDay( datetime dTime = 0 )
  {
    const ENUM_DAY_OF_WEEK DayWeek = DST::TimeDayOfWeek(dTime);

    dTime -= dTime % DAY + (((DayWeek == WEDNESDAY) || (DayWeek == THURSDAY)) ? 1 : (DayWeek + 3) % 7) * DAY;

    return(dTime);
  }

  static datetime RolloverTime( datetime dTime = 0, const string Symb = NULL, const int MaxOffset = 5 * 60 )
  {
    DST::CheckTime(dTime);

    dTime = DST::PrevFullDay(dTime);

    MqlRates Rates[];

    int Spread[24] = {};

    if (::CopyRates(Symb, PERIOD_M1, dTime, dTime + DAY - 1, Rates))
    {
      int Count[24] = {};

      for (uint i = ::ArraySize(Rates); (bool)i--;)
      {
        const int iHour = DST::GetHour(Rates[i].time);

        Spread[iHour] += Rates[i].spread;
        Count[iHour]++;

        const int iHour2 = DST::GetHour(Rates[i].time + MaxOffset);

        if (iHour2 != iHour)
        {
          Spread[iHour2] += Rates[i].spread;
          Count[iHour2]++;
        }

        const int iHour3 = DST::GetHour(Rates[i].time - MaxOffset);

        if (iHour3 != iHour)
        {
          Spread[iHour3] += Rates[i].spread;
          Count[iHour3]++;
        }
      }

      for (int i = 0; i < 24; i++)
        if (Count[i])
          Spread[i] /= Count[i];
    }

    return(dTime + ::ArrayMaximum(Spread) * HOUR);
  }

  static int GetHour( const datetime time )
  {
    return((int)(time / HOUR) % 24);
  }

  static datetime PrevDSTTime( datetime dTime = 0 )
  {
    datetime Res = 0;

    DST::CheckTime(dTime);

    MqlDateTime TimeStruct;

    ::TimeToStruct(dTime, TimeStruct);

    if (TimeStruct.mon >= 10)
    {
      const datetime Begin2 = DST::LastDayWeekMonth(TimeStruct.year, 10);

      if (dTime >= Begin2)
      {
        const datetime End2 = DST::FirstDayWeekMonth(TimeStruct.year, 11);

        Res = (dTime >= End2) ? End2 : Begin2;
      }
      else
        Res = DST::LastDayWeekMonth(TimeStruct.year, 3) - 1;
    }
    else if (TimeStruct.mon == 3)
    {
      const datetime Begin1 = DST::FirstDayWeekMonth(TimeStruct.year, 3, 2);

      if (dTime >= Begin1)
      {
        const datetime End1 = DST::LastDayWeekMonth(TimeStruct.year, 3);

        Res = (dTime >= End1) ? End1 : Begin1;
      }
      else
        Res = DST::FirstDayWeekMonth(TimeStruct.year - 1, 11);
    }
    else if (TimeStruct.mon > 3)
      Res = DST::LastDayWeekMonth(TimeStruct.year, 3);
    else
      Res = DST::FirstDayWeekMonth(TimeStruct.year - 1, 11);

    return(Res - 1);
  }

public:
  static datetime FirstDayWeekMonth( const int Year, const int Month, const int Count = 1, const ENUM_DAY_OF_WEEK DayWeek = SUNDAY )
  {
    const datetime time2 = (datetime)((string)Year + "-" + (string)Month + "-01");

    return(time2 + ((WEEK2 + DayWeek - DST::TimeDayOfWeek(time2)) % WEEK2) * DAY + (Count - 1) * WEEK2 * DAY);
  }

  static datetime LastDayWeekMonth( const int Year, const int Month, const ENUM_DAY_OF_WEEK DayWeek = SUNDAY )
  {
    const datetime time2 = (datetime)((string)(Year + (Month == 12)) + "-" + (string)((Month + 1) % 12) + "-01") - DAY;

    return(time2 - ((WEEK2 + DST::TimeDayOfWeek(time2) - DayWeek) % WEEK2) * DAY);
  }

  static int IsEurope( const datetime dTime = 0, const string Symb = NULL )
  {
    static int Res = INT_MAX;

    if (Res == INT_MAX)
    {
      ::ResetLastError();

      const datetime Time1 = DST::RolloverTime(dTime, Symb);
      const datetime Time2 = DST::RolloverTime(PrevDSTTime(Time1), Symb);

      if (!_LastError)
        Res = (DST::GetHour(Time1) != DST::GetHour(Time2));
      else
        ::Alert(__FUNCTION__ + " " + __FILE__ + " error = " + (string)_LastError +
                "\nFor the function to work correctly, it may take up to seven months of quote M1-history.");
    }

    return(Res);
  }

  static bool IsTime( const datetime TimeCheck )
  {
    MqlDateTime dTime;

    return(::TimeToStruct(TimeCheck, dTime) &&
           ((dTime.mon >= 10) ? (TimeCheck >= DST::LastDayWeekMonth(dTime.year, 10)) && (TimeCheck < DST::FirstDayWeekMonth(dTime.year, 11))
                             : (dTime.mon == 3) && (TimeCheck >= DST::FirstDayWeekMonth(dTime.year, 3, 2)) &&
                               (TimeCheck < DST::LastDayWeekMonth(dTime.year, 3))));
  }

#ifdef __MQL5__
  // Аналог по серверному времени - https://www.mql5.com/ru/docs/dateandtime/timegmtoffset
  static int TimeServerGMTOffset( void )
  {
    MqlCalendarValue Value[1];

    ::CalendarValueHistoryByEvent(840030016, Value, D'2023.09.01', D'2023.09.02');

    // EVENT::CorrectTime(Value[0].time);

    return((-3 + (24 - DST::GetHour(Value[0].time - 31 * HOUR / 2)) % 24) * HOUR);
  }

  // Аналог по серверному времени - https://www.mql5.com/ru/docs/dateandtime/timegmt
  static datetime TimeServerGMT( void )
  {
    return(::TimeTradeServer() + DST::TimeServerGMTOffset());
  }

  static datetime GetRollover( void )
  {
    return(::TimeTradeServer() / DAY * DAY - DST::TimeServerGMTOffset() - 3 * HOUR);
  }
#endif // #ifdef __MQL5__
};

#undef WEEK2
#undef DAY
#undef HOUR
