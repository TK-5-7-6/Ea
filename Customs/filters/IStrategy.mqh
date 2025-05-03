//+------------------------------------------------------------------+
//|                 IStrategy.mqh - Interface for Strategy Modules   |
//+------------------------------------------------------------------+
#ifndef _ISTRATEGY_MQH_
#define _ISTRATEGY_MQH_
class IStrategy
  {
public:
   virtual void   OnTick() = 0;
   virtual bool   CheckSignal() = 0;
   virtual string Name() = 0;
  };
#endif


//+------------------------------------------------------------------+
//|         Strategy_M15_Candlestick.mqh - M15 Candlestick Strategy |
//+------------------------------------------------------------------+
#ifndef _STRATEGY_M15_CANDLESTICK_MQH_
#define _STRATEGY_M15_CANDLESTICK_MQH_
#include "IStrategy.mqh"
#include <Trade/Trade.mqh>

class Strategy_M15_Candlestick : public IStrategy
  {
private:
   CTrade m_trade;
   ulong  m_magic;
   double m_risk;

public:
   Strategy_M15_Candlestick(ulong magic = 20240503, double risk = 1.0)
     {
      m_magic = magic;
      m_risk  = risk;
      m_trade.SetExpertMagicNumber(m_magic);
     }

   virtual void OnTick()
     {
      if(Period() != PERIOD_M15) return;
      if(CheckSignal())
        {
         ExecuteTrade();
        }
     }

   virtual bool CheckSignal()
     {
      string pattern = DetectPattern();
      return (pattern == "bullish_engulfing" || pattern == "bearish_engulfing");
     }

   virtual string Name()
     {
      return "M15 Candlestick Strategy";
     }

private:
   void ExecuteTrade()
     {
      double price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double sl = price - 50 * _Point;
      double tp = price + 75 * _Point;
      double lot = 0.01; // Simplified for demo

      if(!m_trade.Buy(lot, _Symbol, price, sl, tp, "Bullish Engulfing Trade"))
         Print("Trade failed: ", GetLastError());
     }

   string DetectPattern()
     {
      double open1 = iOpen(_Symbol, PERIOD_M15, 1);
      double close1 = iClose(_Symbol, PERIOD_M15, 1);
      double open2 = iOpen(_Symbol, PERIOD_M15, 2);
      double close2 = iClose(_Symbol, PERIOD_M15, 2);

      if(close2 < open2 && close1 > open1 && close1 > open2 && open1 < close2)
         return "bullish_engulfing";

      if(close2 > open2 && close1 < open1 && close1 < open2 && open1 > close2)
         return "bearish_engulfing";

      return "none";
     }
  };
#endif
