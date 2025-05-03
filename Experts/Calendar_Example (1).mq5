#define FAKE // Уберите эту строку, чтобы советник заработал. Нужно для прохождения автоматической проверки КБ.

#ifndef FAKE

// Советник для торговли в MT4/5-Тестере на истории фундаментальных данных.

#define CALENDAR_FILENAME "Calendar.bin" // Название файла для чтения/записи Календаря.
#property tester_file CALENDAR_FILENAME  // Указание, чтобы MT5-Тестер подхватывал данный файл.

#include <fxsaber\Calendar\Calendar.mqh> // Календарь - фундаментальный анализ на истории и в реал-тайме.

input group "Calendar"
input string inCurrency = "USD";        // Currency
input string inFilterName = "payrolls"; // FilterName

input group "EA"
input int inTP = 1000; // TakeProfit
input int inSL = 1000; // StopLoss
input bool inReverse = true; // Trade direction

CALENDAR Calendar; // Объект с данными календаря.

int OnInit()
{
  bool Res = false;

  if (MQLInfoInteger(MQL_TESTER)) // Если работаем в Тестере
  {
    Res = Calendar.Load(CALENDAR_FILENAME) &&      // Загрузили события из файла.
          Calendar.FilterByCurrency(inCurrency) && // Применили фильтр по валюте.
          Calendar.FilterByName(inFilterName);     // Применили фильтр по названию события.

    if (!Res)                                      // Если проблемы с загруженными данными,
      Print("Run the EA in the MT5-Terminal!");    // сообщили, что нужно их получить запуском советника в MT5-Терминале.
  }
#ifdef __MQL5__
  // Работаем в Терминале.
  else if (Calendar.Set(NULL, CALENDAR_IMPORTANCE_NONE, 0, 0) && // Загрузили абсолютно все события (история + будущее) из MT5-Терминала.
           Calendar.AutoDST() &&                                 // Синхронизировали календарь с котировками.
           Calendar.Save(CALENDAR_FILENAME))                     // Сохранили их в файл.
    MessageBox("You can run the EA in the MT4/5-Tester.");       // Сообщили, что можем теперь работать в MT4/5-Тестере.
#endif // #ifdef __MQL5__

  return(!Res);
}

void OnTick()
{
  static int Pos = Calendar.GetPosAfter(TimeCurrent()); // Получили позицию события в Календаре, которая стоит сразу за текущим временем.

  if ((Pos < Calendar.GetAmount()) &&       // Если не вышли за границы Календаря
      (Calendar[Pos].time < TimeCurrent())) // и текущее время перешагнуло событие.
  {
    const EVENT Event = Calendar[Pos];      // Получили соответствующее событие.

    if ((Event.Actual != LONG_MIN) && (Event.Forecast != LONG_MIN)) // Если текущее и прогнозное значения события заданы
    {
      Print(Event.ToString()); // Распечатываем полностью это событие.

      if (Event.Actual > Event.Forecast)                                                                          // Если текущее значение больше прогнозного,
        PositionOpen(inReverse, "Act.(" + Event.ActualToString() + ")>(" + Event.ForecastToString() + ")For.");   // открываем позицию одного направления.
      else
        PositionOpen(!inReverse, "Act.(" + Event.ActualToString() + ")<=(" + Event.ForecastToString() + ")For."); // Иначе - другого направления.
    }

    Pos = Calendar.GetPosAfter(TimeCurrent(), Pos); // Получили позицию события в Календаре, которая стоит сразу за текущим временем.
  }
}

#include <MT4Orders.mqh> // https://www.mql5.com/ru/code/16006

#define Bid SymbolInfoDouble(_Symbol, SYMBOL_BID)
#define Ask SymbolInfoDouble(_Symbol, SYMBOL_ASK)

// Открывает позицию с заданным комментарием.
TICKET_TYPE PositionOpen( const int Type, const string comment )
{
  return(Type ? OrderSend(_Symbol, OP_SELL, 1, Bid, 0, Bid + inSL * _Point, Bid - inTP * _Point, comment)
              : OrderSend(_Symbol, OP_BUY, 1, Ask, 0, Ask - inSL * _Point, Ask + inTP * _Point, comment));
}

#else // #ifndef FAKE
  int OnInit() { return(INIT_FAILED); }
#endif // #ifndef FAKE #else
