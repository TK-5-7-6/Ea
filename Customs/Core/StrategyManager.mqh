//+------------------------------------------------------------------+
//|                StrategyManager.mqh (Fixed & Updated)            |
//|                แนวคิดหลัก: Multi-TF + R:R + ATR               |
//+------------------------------------------------------------------+
#property strict
#include <Trade\Trade.mqh>
#include "RiskManager.mqh"

#include <Indicators\Trend.mqh>
#include <Indicators\Oscilators.mqh>
#include <Indicators\MovingAverages.mqh>

#include "TradeManager.mqh"

//--- ENUM สำหรับกลยุทธ์
enum ENUM_STRATEGY {
   STRAT_SCALPING,
   STRAT_SWING,
   STRAT_TREND
};

//--- Global
ENUM_STRATEGY CurrentStrategy;
CTradeManager tradeManager;

//+------------------------------------------------------------------+
//| เลือกกลยุทธ์ตาม Timeframe                                      |
//+------------------------------------------------------------------+
ENUM_STRATEGY SelectStrategy()
{
   ENUM_TIMEFRAMES tf = Period();
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);

   if (tf <= PERIOD_M5)
      return (balance < 100) ? STRAT_SCALPING : STRAT_SWING;
   else if (tf <= PERIOD_M30)
      return STRAT_SWING;
   else
      return STRAT_TREND;
}

//+------------------------------------------------------------------+
//| ฟังก์ชันหลัก: Execute Strategy                                  |
//+------------------------------------------------------------------+
bool StrategyManager_Execute(CTradeManager &tm, double lot, int maxTrades)
{
   if (PositionsTotal() >= maxTrades) return false;

   tradeManager = tm; // assign

   CurrentStrategy = SelectStrategy();

   switch (CurrentStrategy)
   {
      case STRAT_SCALPING:
         return ExecuteScalping(lot);
      case STRAT_SWING:
         return ExecuteSwing(lot);
      case STRAT_TREND:
         return ExecuteTrend(lot);
   }

   return false;
}

//+------------------------------------------------------------------+
//| Scalping: EMA + RSI                                              |
//+------------------------------------------------------------------+
bool ExecuteScalping(double lot)
{
   CiMA maFast, maSlow;
   CiRSI rsi;

   if (!maFast.Create(_Symbol, PERIOD_CURRENT, 12, 0, MODE_EMA, PRICE_CLOSE)) return false;
   if (!maSlow.Create(_Symbol, PERIOD_CURRENT, 26, 0, MODE_EMA, PRICE_CLOSE)) return false;
   if (!rsi.Create(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE)) return false;

   double emaFast = maFast.Main(0);
   double emaSlow = maSlow.Main(0);
   double rsiVal = rsi.Main(0);

   if (emaFast > emaSlow && rsiVal < 30)
      return tradeManager.Buy(lot, 0, 0, "Scalping Buy");

   if (emaFast < emaSlow && rsiVal > 70)
      return tradeManager.Sell(lot, 0, 0, "Scalping Sell");

   return false;
}

//+------------------------------------------------------------------+
//| Swing: Ichimoku + ATR                                            |
//+------------------------------------------------------------------+
bool ExecuteSwing(double lot)
{
   CiIchimoku ichimoku;
   CiATR atr;

   if (!ichimoku.Create(_Symbol, PERIOD_CURRENT, 9, 26, 52)) return false;
   if (!atr.Create(_Symbol, PERIOD_CURRENT, 14)) return false;

   double tenkan = ichimoku.TenkanSen(0);
   double kijun = ichimoku.KijunSen(0);
   double atrVal = atr.Main(0);

   MqlRates rates[];
   if (CopyRates(_Symbol, PERIOD_CURRENT, 0, 1, rates) != 1) return false;
   double closePrice = rates[0].close;

   if (closePrice > tenkan && tenkan > kijun && atrVal > 0.0001)
      return tradeManager.Buy(lot, 0, 0, "Swing Buy");

   if (closePrice < tenkan && tenkan < kijun && atrVal > 0.0001)
      return tradeManager.Sell(lot, 0, 0, "Swing Sell");

   return false;
}

//+------------------------------------------------------------------+
//| Trend: ADX + EMA200                                              |
//+------------------------------------------------------------------+
bool ExecuteTrend(double lot)
{
   CiADX adx;
   CiMA ema;

   if (!adx.Create(_Symbol, PERIOD_CURRENT, 14)) return false;
   if (!ema.Create(_Symbol, PERIOD_CURRENT, 200, 0, MODE_EMA, PRICE_CLOSE)) return false;

   double adxVal = adx.Main(0);
   double emaVal = ema.Main(0);

   MqlRates rates[];
   if (CopyRates(_Symbol, PERIOD_CURRENT, 0, 1, rates) != 1) return false;
   double closePrice = rates[0].close;

   if (adxVal > 25 && closePrice > emaVal)
      return tradeManager.Buy(lot, 0, 0, "Trend Buy");

   if (adxVal > 25 && closePrice < emaVal)
      return tradeManager.Sell(lot, 0, 0, "Trend Sell");

   return false;
}
