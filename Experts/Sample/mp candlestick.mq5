
// This MQL5 code is an Expert Advisor (EA) designed for automated trading based on candlestick analysis. The EA focuses on executing trades with a specific risk-to-reward ratio, dynamic stop-loss calculation, and margin validation. Here's a breakdown of the code:
// 
// ### Header and Includes
// - **Properties and Includes**: The code sets some metadata like copyright and version. It includes the `Trade/Trade.mqh` library, which provides trading functions.
// - **Global Declarations**: A `CTrade` object is declared globally for managing trades.
// 
// ### Input Parameters
// - **Risk Parameters**: 
//   - `RiskPercent`: Percentage of account equity to risk per trade.
//   - `RiskRewardRatio`: Desired risk-to-reward ratio (1.5:1 in this case).
//   - `MaxMarginUsage`: Maximum percentage of account margin to use.
// 
// - **Trade Settings**:
//   - `StopLossPips`: Base stop-loss in pips.
//   - `UseAutoSL`: Boolean to decide if dynamic stop-loss calculation is used.
//   - `MagicNumber`: Unique identifier for the EA's trades.
// 
// ### Main Functions
// 1. **ExecuteTrade**: 
//    - Determines entry price based on order type (buy/sell).
//    - Calculates stop-loss (`sl`) and take-profit (`tp`) levels.
//    - Validates if the margin requirements are met.
//    - Calculates position size based on risk.
//    - Opens a position if all checks are passed.
//    - Adjusts trailing stop if `UseAutoSL` is true.
// 
// 2. **CalculatePositionSize**:
//    - Calculates the position size based on risk amount and tick value.
//    - Checks if the calculated margin is within allowed limits.
//    - Adjusts lots based on margin constraints.
// 
// 3. **CalculateTakeProfit**:
//    - Computes the take-profit level based on the risk-to-reward ratio.
// 
// 4. **CalculateStopLoss**:
//    - Computes the stop-loss level.
//    - Uses ATR (Average True Range) for dynamic stop-loss if `UseAutoSL` is true.
// 
// 5. **ValidateMargin**:
//    - Checks if the margin required for a trade is within the allowed limit.
// 
// 6. **AdjustTrailingStop**:
//    - Iterates over open positions.
//    - Adjusts the stop-loss to trail the price based on the position's take-profit level.
// 
// ### Initialization and Deinitialization
// - **OnInit**: Sets the expert's magic number for trade identification.
// - **OnDeinit**: Releases the ATR indicator handle to clean up resources.
// 
// ### Key Concepts
// - **Risk Management**: The EA uses a fixed percentage of equity to determine trade size, ensuring consistent risk management.
// - **Dynamic Stop-Loss**: The stop-loss can be dynamically calculated using ATR, providing flexibility in volatile markets.
// - **Margin Validation**: Ensures that trades do not exceed a specified margin usage, protecting the account from over-leveraging.
// - **Trailing Stop**: Automatically adjusts stop-loss to lock in profits as the trade moves in favor.
// 
// This EA is designed to automate trading with a focus on risk management and dynamic trade adjustments, making it suitable for traders who want to maintain a disciplined trading strategy.
// 
//+------------------------------------------------------------------+
//|                                  Candlestick Analysis.mq5         |
//|                                  © 31 March 2025,         |
//|                                              Revised by MPLeong|
//+------------------------------------------------------------------+
#property copyright "Candlestick Analysis"
#property version   "3.0"
#property strict
#include <Trade/Trade.mqh>  // Added missing include

CTrade trade;  // Declare CTrade object globally

input group "Risk Parameters"
input double RiskPercent     = 1.0;        // Risk % per trade
input double RiskRewardRatio = 1.5;        // Risk:Reward (1.5:1)
input double MaxMarginUsage  = 30.0;       // Max margin % of account

input group "Trade Settings"
input int      StopLossPips  = 50;         // Base SL in pips
input bool     UseAutoSL     = true;       // Use dynamic SL calculation
input ulong    MagicNumber   = 20240615;   // Unique EA identifier

//+------------------------------------------------------------------+
//| Trade Execution with 1.5:1 Ratio                                |
//+------------------------------------------------------------------+
void ExecuteTrade(ENUM_ORDER_TYPE type)
  {
   double price = type == ORDER_TYPE_BUY ? SymbolInfoDouble(Symbol(), SYMBOL_ASK)
                  : SymbolInfoDouble(Symbol(), SYMBOL_BID);
   double sl = CalculateStopLoss(type, price);
   double tp = CalculateTakeProfit(type, price, sl);

   if(!ValidateMargin(price, sl, tp))
     {
      Print("Margin requirements exceeded!");
      return;
     }

   double lots = CalculatePositionSize(price, sl);
   if(lots <= 0)
      return;

   if(!trade.PositionOpen(Symbol(), type, lots, price, sl, tp, "1.5:1 RR Trade"))
     {
      Print("PositionOpen failed. Error: ", GetLastError());
      return;
     }

   if(UseAutoSL)
      AdjustTrailingStop();
  }

//+------------------------------------------------------------------+
//| Calculate Position Size with Margin Check                       |
//+------------------------------------------------------------------+
double CalculatePositionSize(double entryPrice, double slPrice)
  {
   double riskAmount = AccountInfoDouble(ACCOUNT_EQUITY) * RiskPercent / 100;
   double tickValue = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_VALUE);
   double pointValue = SymbolInfoDouble(Symbol(), SYMBOL_POINT);

   if(pointValue == 0 || tickValue == 0)
      return 0;

   double riskPoints = MathAbs(entryPrice - slPrice) / pointValue;
   if(riskPoints == 0)
      return 0;

   double lots = NormalizeDouble(riskAmount / (riskPoints * tickValue), 2);

// Margin check using OrderCalcMargin
   double margin;
   ENUM_ORDER_TYPE dir = entryPrice > slPrice ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
   if(!OrderCalcMargin(dir, Symbol(), lots, entryPrice, margin))
     {
      Print("Margin calculation failed. Error: ", GetLastError());
      return 0;
     }

   double maxMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE) * MaxMarginUsage / 100;
   if(margin > maxMargin)
     {
      lots = NormalizeDouble(maxMargin / margin * lots, 2);
      Print("Adjusted lots to ", lots, " due to margin limits");
     }

   return MathMin(lots, SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MAX));
  }

//+------------------------------------------------------------------+
//| Risk:Reward Calculation (1.5:1)                                 |
//+------------------------------------------------------------------+
double CalculateTakeProfit(ENUM_ORDER_TYPE type, double entryPrice, double sl)
  {
   double risk = MathAbs(entryPrice - sl);
   return type == ORDER_TYPE_BUY ?
          entryPrice + (risk * RiskRewardRatio) :
          entryPrice - (risk * RiskRewardRatio);
  }

//+------------------------------------------------------------------+
//| Dynamic Stop Loss Calculation                                   |
//+------------------------------------------------------------------+
double CalculateStopLoss(ENUM_ORDER_TYPE type, double entryPrice)
  {
   if(!UseAutoSL)
     {
      return type == ORDER_TYPE_BUY ?
             entryPrice - StopLossPips * _Point :
             entryPrice + StopLossPips * _Point;
     }

// Advanced SL calculation using ATR
   int atrHandle = iATR(Symbol(), PERIOD_H1, 14);
   double atr[1];
   if(CopyBuffer(atrHandle, 0, 0, 1, atr) != 1)
     {
      Print("Failed to get ATR value. Error: ", GetLastError());
      return 0;
     }

   return type == ORDER_TYPE_BUY ?
          entryPrice - (atr[0] * _Point * 1.5) :
          entryPrice + (atr[0] * _Point * 1.5);
  }

//+------------------------------------------------------------------+
//| Margin Validation System                                        |
//+------------------------------------------------------------------+
bool ValidateMargin(double entryPrice, double sl, double tp)
  {
   double margin;
   ENUM_ORDER_TYPE dir = entryPrice > sl ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;

   if(!OrderCalcMargin(dir, Symbol(), SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN), entryPrice, margin))
     {
      Print("Margin validation failed. Error: ", GetLastError());
      return false;
     }

   double maxAllowedMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE) * MaxMarginUsage / 100;
   return margin <= maxAllowedMargin;
  }

//+------------------------------------------------------------------+
//| Trailing Stop Management                                        |
//+------------------------------------------------------------------+
void AdjustTrailingStop()
  {
   for(int i = PositionsTotal()-1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) && PositionGetInteger(POSITION_MAGIC) == MagicNumber)
        {
         double currentSL = PositionGetDouble(POSITION_SL);
         double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
         double newSL = openPrice + (PositionGetDouble(POSITION_TP) - openPrice) * 0.5;

         ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

         if((posType == POSITION_TYPE_BUY && newSL > currentSL) ||
            (posType == POSITION_TYPE_SELL && newSL < currentSL))
           {
            if(!trade.PositionModify(ticket, newSL, PositionGetDouble(POSITION_TP)))
              {
               Print("Failed to modify position. Error: ", GetLastError());
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Expert Initialization                                           |
//+------------------------------------------------------------------+
int OnInit()
  {
   trade.SetExpertMagicNumber(MagicNumber);  // Initialize CTrade magic number
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert Deinitialization                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
// Clean up indicators
   int atrHandle = iATR(Symbol(), PERIOD_H1, 14);
   IndicatorRelease(atrHandle);
  }
//+------------------------------------------------------------------+
