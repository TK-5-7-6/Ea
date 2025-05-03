//+------------------------------------------------------------------+
//|                        TimeFilter.mqh                           |
//+------------------------------------------------------------------+
#property strict

namespace TimeFilter
{
   bool IsTradingTime()
   {
      MqlDateTime mqlTime;
      TimeCurrent(mqlTime);
      
      // ตัวอย่าง: ไม่อนุญาตให้เทรดวันเสาร์-อาทิตย์
      if(mqlTime.day_of_week == 0 || mqlTime.day_of_week == 6)
         return false;
         
      // ตัวอย่าง: เวลาเทรด 08:00-20:00 GMT+3
      if(mqlTime.hour < 8 || mqlTime.hour >= 20)
         return false;
         
      return true;
   }
}
