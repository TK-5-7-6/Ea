//+------------------------------------------------------------------+
//|                Indicator Manager (Fixed Parameters)              |
//+------------------------------------------------------------------+
#property strict

class CIndicatorManager
{
private:
   int m_emaFast;
   int m_emaSlow;
   int m_rsi;
   int m_ichimoku;
   
public:
   bool Init()
   {
      m_emaFast = iMA(_Symbol, _Period, 12, 0, MODE_EMA, PRICE_CLOSE);
      m_emaSlow = iMA(_Symbol, _Period, 26, 0, MODE_EMA, PRICE_CLOSE);
      m_rsi = iRSI(_Symbol, _Period, 14, PRICE_CLOSE);
      
      if(_Period >= PERIOD_M30) {
         m_ichimoku = iIchimoku(_Symbol, _Period, 9, 26, 52);
      }
      
      return (m_emaFast != INVALID_HANDLE && 
              m_emaSlow != INVALID_HANDLE && 
              m_rsi != INVALID_HANDLE);
   }
   
   void Refresh()
   {
      // Update indicator buffers if needed
   }
   
   bool GetBuySignal()
   {
      double emaFast[], emaSlow[], rsi[];
      ArraySetAsSeries(emaFast, true);
      ArraySetAsSeries(emaSlow, true);
      ArraySetAsSeries(rsi, true);
      
      if(CopyBuffer(m_emaFast, 0, 0, 1, emaFast) != 1 ||
         CopyBuffer(m_emaSlow, 0, 0, 1, emaSlow) != 1 ||
         CopyBuffer(m_rsi, 0, 0, 1, rsi) != 1)
      {
         return false;
      }
      
      return (emaFast[0] > emaSlow[0] && rsi[0] < 30);
   }
   
   bool GetSellSignal()
   {
      double emaFast[], emaSlow[], rsi[];
      ArraySetAsSeries(emaFast, true);
      ArraySetAsSeries(emaSlow, true);
      ArraySetAsSeries(rsi, true);
      
      if(CopyBuffer(m_emaFast, 0, 0, 1, emaFast) != 1 ||
         CopyBuffer(m_emaSlow, 0, 0, 1, emaSlow) != 1 ||
         CopyBuffer(m_rsi, 0, 0, 1, rsi) != 1)
      {
         return false;
      }
      
      return (emaFast[0] < emaSlow[0] && rsi[0] > 70);
   }
   
   void Deinit()
   {
      IndicatorRelease(m_emaFast);
      IndicatorRelease(m_emaSlow);
      IndicatorRelease(m_rsi);
      if(m_ichimoku != INVALID_HANDLE) IndicatorRelease(m_ichimoku);
   }
};