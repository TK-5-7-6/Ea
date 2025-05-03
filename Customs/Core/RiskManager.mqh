//+------------------------------------------------------------------+
//|                        RiskManager.mqh                           |
//|      ใช้ ATR ในการตั้ง Stop Loss และ Risk:Reward               |
//+------------------------------------------------------------------+
#property strict

class CRiskManager
{
private:
   double m_riskPercent;   // เปอร์เซ็นต์ความเสี่ยงต่อไม้
   double m_riskReward;    // Risk:Reward Ratio เช่น 1:2 = 2.0
   int    m_atrPeriod;
   int    m_atrHandle;

public:
   bool Init(double riskPercent = 1.0, double riskReward = 2.0, int atrPeriod = 14)
   {
      m_riskPercent = riskPercent;
      m_riskReward  = riskReward;
      m_atrPeriod   = atrPeriod;

      m_atrHandle = iATR(_Symbol, _Period, atrPeriod);
      return (m_atrHandle != INVALID_HANDLE);
   }

   void Deinit()
   {
      if (m_atrHandle != INVALID_HANDLE)
         IndicatorRelease(m_atrHandle);
   }

   // ดึงค่าปัจจุบันของ ATR
   double GetATR()
   {
      double atrBuffer[];
      ArraySetAsSeries(atrBuffer, true);

      if (CopyBuffer(m_atrHandle, 0, 0, 1, atrBuffer) == 1)
         return atrBuffer[0];

      return -1; // error
   }

   // คำนวณขนาด Lot จาก Risk%
   double CalculateLot(double riskPercent, double stopLossPips)
   {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double riskMoney = balance * (riskPercent / 100.0);
      double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
      double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);

      double slInMoney = (stopLossPips * tickValue) / tickSize;
      if (slInMoney <= 0.0) return 0.0;

      double lots = riskMoney / slInMoney;
      return NormalizeDouble(lots, 2);
   }

   // สร้าง SL / TP และ Lot
   bool GetTradeLevels(bool isBuy, double &lot, double &sl, double &tp)
   {
      double atr = GetATR();
      if (atr <= 0)
         return false;

      double price = isBuy ? SymbolInfoDouble(_Symbol, SYMBOL_ASK)
                           : SymbolInfoDouble(_Symbol, SYMBOL_BID);

      double slDistance = atr;
      double tpDistance = atr * m_riskReward;

      lot = CalculateLot(m_riskPercent, slDistance); // ✅ แก้ตรงนี้

      if (isBuy)
      {
         sl = NormalizeDouble(price - slDistance, _Digits);
         tp = NormalizeDouble(price + tpDistance, _Digits);
      }
      else
      {
         sl = NormalizeDouble(price + slDistance, _Digits);
         tp = NormalizeDouble(price - tpDistance, _Digits);
      }

      return true;
   }
};
