//+------------------------------------------------------------------+
//|                                                  PivotsRedux.mq4 |
//|                                                      nicholishen |
//|                                   www.reddit.com/u/nicholishenFX |
//+------------------------------------------------------------------+
#property copyright "nicholishen"
#property link "www.reddit.com/u/nicholishenFX"
#property version "1.00"
#property strict
#include "PersistentPivots.mqh"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   //---
   ulong st = GetMicrosecondCount();
   PersistentPivots pivots;
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   CopyRates(Symbol(), Period(), 0, 2000, rates);
   pivots.Init(rates[iHighest(Symbol(), Period(), MODE_HIGH, 1000)].high,
               rates[iLowest(Symbol(), Period(), MODE_LOW, 1000)].low,
               (ENUM_TIMEFRAMES)Period(),
               5,
               200,
               clrYellow);
   pivots.Refresh();
   st = GetMicrosecondCount() - st;
   Print("Time to complete = ", st/1000);
}
//+------------------------------------------------------------------+
