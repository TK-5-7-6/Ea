//+------------------------------------------------------------------+
//|                        TradeManager.mqh                          |
//|             จัดการคำสั่งซื้อขายโดยไม่ปิดออร์เดอร์ใน Deinit |
//+------------------------------------------------------------------+
#property strict

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>

class CTradeManager
{
private:
   CTrade m_trade;
   CPositionInfo m_position;
   int m_magic;

public:
   bool Init(int magic)
   {
      m_magic = magic;
      m_trade.SetExpertMagicNumber(magic);
      m_trade.SetTypeFilling(ORDER_FILLING_IOC); // Instant or Cancel
      return true;
   }

   bool Buy(double lot, double sl, double tp, string comment)
   {
      double price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      return m_trade.Buy(lot, _Symbol, price, sl, tp, comment);
   }

   bool Sell(double lot, double sl, double tp, string comment)
   {
      double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      return m_trade.Sell(lot, _Symbol, price, sl, tp, comment);
   }

   // ตรวจสอบว่ามีออร์เดอร์เปิดอยู่หรือไม่
   bool HasOpenPosition()
   {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         if(m_position.SelectByIndex(i))
         {
            if(m_position.Magic() == m_magic && m_position.Symbol() == _Symbol)
               return true;
         }
      }
      return false;
   }

   void Deinit()
   {
      // ไม่ปิดออร์เดอร์อีกต่อไปเพื่อให้ TP/SL ทำงานตามปกติ
      Print("CTradeManager Deinit called — no open orders closed.");
   }
};
