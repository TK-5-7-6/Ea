//+------------------------------------------------------------------+
//|                        Utils.mqh                                |
//+------------------------------------------------------------------+
#property strict

#include <Trade\Trade.mqh>
#include <Indicators\Indicators.mqh>

//+------------------------------------------------------------------+
//| ฟังก์ชันจัดการเวลา                                              |
//+------------------------------------------------------------------+
bool IsNewBar(string symbol, ENUM_TIMEFRAMES timeframe)
{
   static datetime lastBarTime = 0;
   datetime currentBarTime = iTime(symbol, timeframe, 0);
   
   if(lastBarTime != currentBarTime) {
      lastBarTime = currentBarTime;
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| ฟังก์ชันคำนวณสเปรดปัจจุบัน                                      |
//+------------------------------------------------------------------+
double GetCurrentSpread(string symbol)
{
   return SymbolInfoInteger(symbol, SYMBOL_SPREAD) * Point();
}

//+------------------------------------------------------------------+
//| ฟังก์ชันตรวจสอบเวลาทำการ                                        |
//+------------------------------------------------------------------+
bool IsTradingHours(int startHour, int endHour)
{
   MqlDateTime mqlTime;
   TimeCurrent(mqlTime);
   
   return (mqlTime.hour >= startHour && mqlTime.hour < endHour);
}

//+------------------------------------------------------------------+
//| ฟังก์ชันคำนวณ Pip Value                                        |
//+------------------------------------------------------------------+
double CalculatePipValue(string symbol)
{
   double tickSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
   double tickValue = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
   return (tickValue / tickSize) * Point();
}
