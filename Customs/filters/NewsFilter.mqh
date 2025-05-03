//+------------------------------------------------------------------+
//|                News Filter (Fixed)                               |
//+------------------------------------------------------------------+
#property strict

#include <Arrays\ArrayObj.mqh>

class CNewsEvent : public CObject
{
public:
   datetime time;
   string   currency;
   string   title;
   int      impact;
   
   CNewsEvent() : time(0), currency(""), title(""), impact(0) {}
};

class CNewsFilter
{
private:
   CArrayObj newsEvents;
   
public:
   bool Init()
   {
      LoadEconomicCalendar();
      return true;
   }
   
   bool IsHighImpactNews(const string symbol, const int minutesBefore=60, const int minutesAfter=60)
   {
      datetime now = TimeCurrent();
      string currency1 = StringSubstr(symbol, 0, 3);
      string currency2 = StringSubstr(symbol, 3, 3);
      
      for(int i = 0; i < newsEvents.Total(); i++)
      {
         CNewsEvent* event = dynamic_cast<CNewsEvent*>(newsEvents.At(i));
         if(event == NULL) continue;
         
         if(event.impact >= 1 && 
            (StringFind(event.currency, currency1) != -1 || 
             StringFind(event.currency, currency2) != -1))
         {
            if(MathAbs(now - event.time) <= (minutesBefore + minutesAfter) * 60)
            {
               PrintFormat("High impact news detected: %s (%s)", 
                          event.title, TimeToString(event.time));
               return true;
            }
         }
      }
      return false;
   }
   
private:
   void LoadEconomicCalendar()
   {
      // Example news events (replace with real API calls)
      AddNewsEvent("USD", "NFP Data", D'2023.12.08 13:30', 2);
      AddNewsEvent("EUR", "ECB Interest Rate", D'2023.12.14 14:45', 2);
      AddNewsEvent("GBP", "CPI Data", D'2023.12.20 09:30', 1);
   }
   
   void AddNewsEvent(const string currency, const string title, const datetime time, const int impact)
   {
      CNewsEvent* event = new CNewsEvent();
      event.currency = currency;
      event.title = title;
      event.time = time;
      event.impact = impact;
      newsEvents.Add(event);
   }
};
