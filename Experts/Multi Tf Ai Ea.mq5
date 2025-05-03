//+------------------------------------------------------------------+
//|                  Multi-Timeframe AI EA (TK EDITION)              |
//+------------------------------------------------------------------+
#property strict
#property version   "1.03"
#property copyright "TK EDITION"

// Include Modules
#include <Custom/Core/TradeManager.mqh>
#include <Custom/Core/StrategyManager.mqh>
#include <Custom/Core/RiskManager.mqh>
#include <Custom/Filters/NewsFilter.mqh>
#include <Custom/Filters/TimeFilter.mqh>
#include <Indicators/Ichimoku.mq5>

// Input Parameters
input group "==== Risk Management ===="
input double InpRiskPercent = 1.0;       // Risk per trade in %
input double InpMaxLotSize  = 0.2;       // Maximum lot size
input int    InpMaxTrades   = 1;         // Max simultaneous trades
input double InpMaxDrawdown = 70.0;      // Max Drawdown %

input group "==== Strategy Settings ===="
input bool   InpEnableHedging = false;

// Global Objects
CTradeManager *Trade = NULL;
CNewsFilter  *News  = NULL;
CRiskManager  Risk;
CIchimokuM30 Ichimoku;

int ExpertMagicNumber = 123456;

//+------------------------------------------------------------------+
int OnInit()
{
   Trade = new CTradeManager();
   News  = new CNewsFilter();

   if(!Trade.Init(ExpertMagicNumber)) {
      Alert("Trade Manager initialization failed!");
      return INIT_FAILED;
   }

   if(!News.Init()) {
      Alert("News filter initialization failed!");
      return INIT_FAILED;
   }

   Risk.Init(InpRiskPercent, 2.0, 14); // RR 1:2, ATR 14
   Ichimoku.Init();

   Print("EA Initialized. Balance: ", AccountInfoDouble(ACCOUNT_BALANCE));
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
void OnTick()
{
   if(!IsTradingAllowed()) return;

   // Basic time and risk filters
   if(!TimeFilter::IsTradingTime()) return;

   double currentDD = GetCurrentDrawdown();
   if(currentDD > InpMaxDrawdown) {
      Print("Drawdown exceeds limit: ", currentDD);
      return;
   }

   // Reduced size during news events
   double adjustedRisk = InpRiskPercent;
   if(News.IsHighImpactNews(_Symbol)) {
      adjustedRisk /= 2.0;
      Print("High Impact News: Reduced risk to ", adjustedRisk, "%");
   }

   Risk.Init(adjustedRisk, 2.0, 14);
   double lot = Risk.CalculateLotFromATR();

   if(!Ichimoku.IsBullish()) return;

   StrategyManager_Execute(*Trade, lot, InpMaxTrades);
}

//+------------------------------------------------------------------+
bool IsTradingAllowed()
{
   if(!TerminalInfoInteger(TERMINAL_CONNECTED)) {
      Alert("No internet connection.");
      return false;
   }

   if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)) {
      Alert("Trading not allowed.");
      return false;
   }

   return true;
}

//+------------------------------------------------------------------+
double GetCurrentDrawdown()
{
   double equity  = AccountInfoDouble(ACCOUNT_EQUITY);
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   if(balance <= 0) return 0;
   return 100.0 * (1.0 - equity / balance);
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{  
   Risk.Deinit();
   if(CheckPointer(Trade) == POINTER_DYNAMIC) {
      Trade.Deinit();
      delete Trade;
   }
   if(CheckPointer(News) == POINTER_DYNAMIC) {
      delete News;
   }
}
