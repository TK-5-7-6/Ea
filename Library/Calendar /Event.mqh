#include "DST.mqh"

#include "String.mqh"

#define WEEK (7 * 24 * 3600)

#ifndef __MQL5__
#property strict

enum ENUM_CALENDAR_EVENT_TIMEMODE
{
  CALENDAR_TIMEMODE_DATETIME,
  CALENDAR_TIMEMODE_DATE,
  CALENDAR_TIMEMODE_NOTIME,
  CALENDAR_TIMEMODE_TENTATIVE
};

enum ENUM_CALENDAR_EVENT_MULTIPLIER
{
  CALENDAR_MULTIPLIER_NONE,
  CALENDAR_MULTIPLIER_THOUSANDS,
  CALENDAR_MULTIPLIER_MILLIONS,
  CALENDAR_MULTIPLIER_BILLIONS,
  CALENDAR_MULTIPLIER_TRILLIONS
};

enum ENUM_CALENDAR_EVENT_UNIT
{
  CALENDAR_UNIT_NONE,
  CALENDAR_UNIT_PERCENT,
  CALENDAR_UNIT_CURRENCY,
  CALENDAR_UNIT_HOUR,
  CALENDAR_UNIT_JOB,
  CALENDAR_UNIT_RIG,
  CALENDAR_UNIT_USD,
  CALENDAR_UNIT_PEOPLE,
  CALENDAR_UNIT_MORTGAGE,
  CALENDAR_UNIT_VOTE,
  CALENDAR_UNIT_BARREL,
  CALENDAR_UNIT_CUBICFEET,
  CALENDAR_UNIT_POSITION,
  CALENDAR_UNIT_BUILDING
};

enum ENUM_CALENDAR_EVENT_IMPORTANCE
{
  CALENDAR_IMPORTANCE_NONE,
  CALENDAR_IMPORTANCE_LOW,
  CALENDAR_IMPORTANCE_MODERATE,
  CALENDAR_IMPORTANCE_HIGH
};

#endif // #ifndef __MQL5__

struct EVENT
{
private:
  string TimeToString( void ) const
  {
    string Str = NULL;

    switch (this.TimeMode)
    {
      case CALENDAR_TIMEMODE_DATETIME:
        Str = ::TimeToString(this.time);

        break;
      case CALENDAR_TIMEMODE_DATE:
        Str = ::TimeToString(this.time, TIME_DATE) + " AllDay";

        break;
      case CALENDAR_TIMEMODE_NOTIME:
        Str = ::TimeToString(this.time, TIME_DATE) + " NoTime";

        break;
      case CALENDAR_TIMEMODE_TENTATIVE:
      #ifdef __MQL5__
        if (this.time <= ::TimeTradeServer())
      #else // #ifdef __MQL5__
        if (this.time <= ::TimeCurrent())
      #endif // #ifdef __MQL5__
          Str = ::TimeToString(this.time);
        else
          Str = ::TimeToString(this.time, TIME_DATE) + " ≈" +::TimeToString(this.time, TIME_MINUTES);

        break;
    }

    return(Str);
  }

  int GetDigits( long Value ) const
  {
    int Res = Value ? 6 : 0;

    while (Value && (Value / 10 * 10 == Value))
    {
      Value /= 10;

      Res--;
    }

    return(Res);
  }

  string DoubleToString2( const long &Value, const int MinDigits ) const
  {
    return(::DoubleToString(Value / 1e6, ::MathMax(MinDigits, this.GetDigits(Value))));
  }

  string ValueToString( const long &Value ) const
  {
    static const string Multipliers[] = {NULL, " K", " M", " B", " T"};

    string Str = NULL;

    if (Value != LONG_MIN)
    {
      switch (this.Unit)
      {
        case CALENDAR_UNIT_NONE:
          Str = this.DoubleToString2(Value, 0);

          break;
        case CALENDAR_UNIT_PERCENT:
          Str = this.DoubleToString2(Value, 1) + "%";

          break;
        case CALENDAR_UNIT_CURRENCY:
          Str = this.CurrencySymbol[] + this.DoubleToString2(Value, 1);

          break;
        case CALENDAR_UNIT_HOUR:
          Str = this.DoubleToString2(Value, 1);

          break;
        case CALENDAR_UNIT_JOB:
          Str = this.DoubleToString2(Value, 0);

          break;
        case CALENDAR_UNIT_RIG:
          Str = (string)(Value / 1000000);

          break;
        case CALENDAR_UNIT_USD:
          Str = "$" + this.DoubleToString2(Value, 1);

          break;
        case CALENDAR_UNIT_PEOPLE:
          Str = this.DoubleToString2(Value, 0);

          break;
        case CALENDAR_UNIT_MORTGAGE:
          Str = this.DoubleToString2(Value, 1);

          break;
        case CALENDAR_UNIT_VOTE:
          Str = (string)(Value / 1000000);

          break;
        case CALENDAR_UNIT_BARREL:
          Str = this.DoubleToString2(Value, 3);

          break;
        case CALENDAR_UNIT_CUBICFEET:
          Str = (string)(Value / 1000000);

          break;
        case CALENDAR_UNIT_POSITION:
          Str = this.DoubleToString2(Value, 1);

          break;
        case CALENDAR_UNIT_BUILDING:
          Str = this.DoubleToString2(Value, 3);

          break;
      }

      Str += Multipliers[(int)this.Multiplier];
    }

    return(Str);
  }

  bool IsReadyToCorrectTime( void ) const
  {
    return((this.TimeMode == CALENDAR_TIMEMODE_DATETIME) || (this.TimeMode == CALENDAR_TIMEMODE_TENTATIVE));
  }

public:
  datetime time;
  STRING4 Currency;
  ENUM_CALENDAR_EVENT_IMPORTANCE Importance;
  STRING128 Name;
  STRING32 Country;
  STRING16 Source;
  ulong id;
  ulong EventID;

  long Actual;
  long Previous;
  long Revised;
  long Forecast;

  ENUM_CALENDAR_EVENT_UNIT Unit;
  ENUM_CALENDAR_EVENT_MULTIPLIER Multiplier;
  ENUM_CALENDAR_EVENT_TIMEMODE TimeMode;
  STRING4 CurrencySymbol;

  EVENT( void ) : time(0), Importance(CALENDAR_IMPORTANCE_NONE), id(0), EventID(0),
                  Actual(LONG_MIN), Previous(LONG_MIN), Revised(LONG_MIN), Forecast(LONG_MIN),
                  Unit(CALENDAR_UNIT_NONE), Multiplier(CALENDAR_MULTIPLIER_NONE), TimeMode(CALENDAR_TIMEMODE_DATETIME)
  {
  }

#ifdef __MQL5__
  EVENT( const string sCurrency, const ENUM_CALENDAR_EVENT_IMPORTANCE MinImportance = CALENDAR_IMPORTANCE_HIGH )
  {
    this.SetNear(sCurrency, 0, MinImportance);
  }

  bool Set( const MqlCalendarValue &Value )
  {
    MqlCalendarEvent Event;
    MqlCalendarCountry country;

    const bool Res = ::CalendarEventById(Value.event_id, Event) && ::CalendarCountryById(Event.country_id, country);

    if (Res)
    {
      this.time = Value.time;
      this.Importance = Event.importance;

      const string StrName = Event.name + " (" + Event.event_code + ")";
      this.Name = StrName;

      this.Currency = country.currency;

      const string StrCountry = country.name + " (" + country.code + ")";
      this.Country = StrCountry;

      static const string StrSource = "MetaTrader5";
      this.Source = StrSource;

      this.id = Value.id;
      this.EventID = Value.event_id;

      this.Actual = Value.actual_value;
      this.Previous = Value.prev_value;
      this.Revised = Value.revised_prev_value;
      this.Forecast = Value.forecast_value;

      this.Unit = Event.unit;
      this.Multiplier = Event.multiplier;
      this.TimeMode = Event.time_mode;

      this.CurrencySymbol = country.currency_symbol;
    }

    return(Res);
  }

  bool GetValue( MqlCalendarValue &Value ) const
  {
    return(this.id && ::CalendarValueById(this.id, Value));
  }

  const MqlCalendarValue GetValue( void ) const
  {
    MqlCalendarValue Value = {};

    this.GetValue(Value);

    return(Value);
  }

  bool GetEvent( MqlCalendarEvent &Event ) const
  {
    return(::CalendarEventById(this.EventID, Event));
  }

  const MqlCalendarEvent GetEvent( void ) const
  {
    MqlCalendarEvent Event = {};

    this.GetEvent(Event);

    return(Event);
  }

  bool GetCountry( MqlCalendarCountry &sCountry ) const
  {
    MqlCalendarEvent Event = {};

    return(this.GetEvent(Event) && ::CalendarCountryById(Event.country_id, sCountry));
  }

  const MqlCalendarCountry GetCountry( void ) const
  {
    MqlCalendarCountry sCountry = {};

    this.GetCountry(sCountry);

    return(sCountry);
  }

  bool SetNear( const string sCurrency = NULL, const ENUM_CALENDAR_EVENT_IMPORTANCE MinImportance = CALENDAR_IMPORTANCE_HIGH, const datetime To = -WEEK )
  {
    bool Res = false;
    EVENT TempEvent;

    this = TempEvent;

    MqlCalendarValue Values[];

    if (::CalendarValueHistory(Values, ::TimeTradeServer(), (To < 0) ? ::TimeTradeServer() - To : To, NULL, sCurrency))
    {
      const int Size = ::ArraySize(Values);

      for (int i = 0; i < Size; i++)
        if (Res = TempEvent.Set(Values[i]) && (TempEvent.Importance >= MinImportance))
        {
          this = TempEvent;

          break;
        }
    }

    return(Res);
  }

  bool SetNear( const string &sCurrencies[], const ENUM_CALENDAR_EVENT_IMPORTANCE MinImportance = CALENDAR_IMPORTANCE_HIGH, const datetime To = -WEEK )
  {
    bool Res = false;

    EVENT TempEvent;
    this = TempEvent;

    for (int i = ::ArraySize(sCurrencies) - 1; i >= 0; i--)
      if (Res |= TempEvent.SetNear(sCurrencies[i], MinImportance, To) && (TempEvent < this))
        this = TempEvent;

    return(Res);
  }

#endif // #ifdef __MQL5__

  bool IsSymbol( const string Symb = NULL ) const
  {
    return((this.Currency[] == ::SymbolInfoString(Symb, SYMBOL_CURRENCY_BASE)) || (this.Currency[] == ::SymbolInfoString(Symb, SYMBOL_CURRENCY_PROFIT)));
  }

  bool operator <( const EVENT &Value ) const
  {
    return(!Value.time || (this.time < Value.time));
  }

  void operator +=( const int Offset )
  {
    if (this.IsReadyToCorrectTime())
      this.time += Offset;

    return;
  }

  void operator -=( const int Offset )
  {
    if (this.IsReadyToCorrectTime())
      this.time -= Offset;

    return;
  }

  static bool CorrectTime( datetime &TimeCorrect )
  {
    MqlDateTime dTime;

    const bool Res = ::TimeToStruct(TimeCorrect, dTime) &&
                     ((dTime.mon < 11) ? (dTime.mon <= 3) && (TimeCorrect < DST::FirstDayWeekMonth(dTime.year, 3, 2))
                                      : (TimeCorrect >= DST::FirstDayWeekMonth(dTime.year, 11)));

    if (Res)
      TimeCorrect -= 3600;

    return(Res);
  }

  bool CorrectTime( void )
  {
    return(this.IsReadyToCorrectTime() && EVENT::CorrectTime(this.time));
  }

  bool DST( const bool &IsTimeNowDST )
  {
    const bool Res1 = this.IsReadyToCorrectTime();
    const bool Res2 = Res1 && DST::IsTime(this.time);

    if (Res1)
    {
      if (IsTimeNowDST)
        this.time += 3600; // Весеннее смещение. Возможно, для осеннего надо будет делать иначе.

      if (Res2)
        this.time -= 3600;
    }

    return(Res1 && !(IsTimeNowDST && Res2));
  }

#define MACROS_TOSTRING(A)                \
  string A##ToString( void ) const        \
  {                                       \
    return(this.ValueToString(this.##A)); \
  }

  MACROS_TOSTRING(Actual)
  MACROS_TOSTRING(Previous)
  MACROS_TOSTRING(Revised)
  MACROS_TOSTRING(Forecast)
#undef MACROS_TOSTRING

  string ToString( void ) const
  {
    return(this.TimeToString() +
           " " + this.Currency[] + " " + (string)this.Importance +
           " " + this.Name[] + ", " + this.Country[] +
           " | " + this.ActualToString() +
           " | " + this.ForecastToString() +
           " | " + this.PreviousToString() +
           " | " + this.RevisedToString()/* + " | - " + this.Source*/);
  }
};

#undef WEEK
