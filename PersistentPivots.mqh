//+------------------------------------------------------------------+
//|                                             PersistentPivots.mqh |
//|                                                      nicholishen |
//|                                   www.reddit.com/u/nicholishenFX |
//+------------------------------------------------------------------+
#property copyright "nicholishen"
#property link "www.reddit.com/u/nicholishenFX"
#property version "1.00"
#property strict
#include <ChartObjects\ChartObjectsLines.mqh>
#include <ChartObjects\ChartObjectsTxtControls.mqh>
#include "PivotCollection.mqh"
#define ChartObjects objvector<CChartObject *>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class PersistentPivots
{
 protected:
   PivotCollection m_origin;
   PivotCollection m_filtered;
   ChartObjects m_objs;

   double m_high;
   double m_low;
   ENUM_TIMEFRAMES m_period;
   double m_bp;
   double m_wp;
   double m_rp;
   int m_num_levels;
   int m_points_between;
   color m_color;

 public:
   PersistentPivots();
   ~PersistentPivots();
   void Init(const double high,
             const double low,
             const ENUM_TIMEFRAMES period,
             const int num_levels,
             const int points_between,
             const color col = clrRed);
   void Refresh();

 protected:
   void Draw();
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
PersistentPivots::PersistentPivots() : m_bp(1), m_wp(5), m_rp(10) //,m_last_bars(0)
{
   ObjectsDeleteAll(0, "__Persistent");
   m_filtered.FreeMode(false);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
PersistentPivots::~PersistentPivots()
{
}
//+------------------------------------------------------------------+
void PersistentPivots::Init(const double high,
                            const double low,
                            const ENUM_TIMEFRAMES period,
                            const int num_levels,
                            const int points_between,
                            const color col = clrRed)
{
   m_period = period;
   m_high = NormalizeDouble(high, _Digits);
   m_low = NormalizeDouble(low, _Digits);
   m_points_between = points_between;
   m_num_levels = num_levels;
   m_color = col;
   m_origin.Init(high, low);
}
//+------------------------------------------------------------------+
void PersistentPivots::Refresh(void)
{
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   int bars = Bars(Symbol(), m_period);
   //bars = bars - m_last_bars;
   //m_last_bars =
   int total = CopyRates(Symbol(), m_period, 0, bars, rates);
   int last_index = -1;
   int origin_total = m_origin.Total();
   for (int bar = 3; bar < total; bar++)
   {
      if (rates[bar].high > m_high || rates[bar].low < m_low)
         continue;
      double up_body = fmax(rates[bar].open, rates[bar].close);
      double dn_body = fmin(rates[bar].open, rates[bar].close);
      for (double tick = rates[bar].high; tick >= rates[bar].low; tick -= _Point)
      {
         //NormalizeDouble(tick,_Digits);
         int index = int(NormalizeDouble((m_high - tick) / _Point, 0));
         if (index == last_index)
            continue;
         else
            last_index = index;
         index = index < 0 ? 0 : index >= origin_total ? origin_total - 1 : index;
         Pivot *pivot = m_origin.At(index);
         if(!CheckPointer(pivot))
            continue;
         if (tick > up_body)
         {
            pivot.Wick(m_wp);
            if (rates[bar - 2].low < rates[bar - 1].low && rates[bar - 1].low < rates[bar].low)
               pivot.Reverse(m_rp);
         }
         else if (tick < dn_body)
         {
            pivot.Wick(m_wp);
            if (rates[bar - 2].high > rates[bar - 1].high && rates[bar - 1].high > rates[bar].high)
               pivot.Reverse(m_rp);
         }
         else
            pivot.Body(m_bp);

         // if (rates[bar].open < rates[bar].close)
         // { // bull bar
         //    if (rates[bar].open <= tick && rates[bar].close >= tick)
         //       m_origin[index].Body(m_bp);

         //    if ((rates[bar].low <= tick && rates[bar].open > tick) || (rates[bar].high >= tick && rates[bar].close < tick))
         //       m_origin[index].Wick(m_wp);

         //    if ((rates[bar].high >= tick && rates[bar].close < tick) && (rates[bar - 1].high < tick && rates[bar - 2].high < tick))
         //       m_origin[index].Reverse(m_rp);
         // }
         // else
         // { //bear bar
         //    if (rates[bar].open >= tick && rates[bar].close <= tick)
         //       m_origin[index].Body(m_bp);

         //    if ((rates[bar].low <= tick && rates[bar].close > tick) || (rates[bar].high >= tick && rates[bar].open < tick))
         //       m_origin[index].Wick(m_wp);

         //    if ((rates[bar].low <= tick && rates[bar].close > tick) && (rates[bar - 1].low > tick && rates[bar - 2].low > tick))
         //       m_origin[index].Reverse(m_rp);
         // }
      }
   }
   m_origin.CopyTo(m_filtered);
   m_filtered.Filter(m_num_levels, m_points_between);
   Draw();
}
//+------------------------------------------------------------------+
void PersistentPivots::Draw(void)
{
   ObjectsDeleteAll(0,"__Persistent");
   for (int index = 0; index < m_num_levels && index < m_filtered.Total(); index++)
   {
      CChartObjectHLine *line = new CChartObjectHLine;
      string name = "__Persistent_Pivot_" + string(m_filtered[index].Price()) + string(m_period);
      double price = m_filtered[index].Price();
      line.Create(0, name, 0, m_filtered[index].Price());
      m_objs.Add(line);
      line.Color(m_color);
      
      //line.Description(string(m_filtered[index].Score()));
      line.Tooltip(string(m_filtered[index].Score()));
      line.Detach(); //FOR SCRIPT ONLY!!!
      
      
      name+="_text_";
      CChartObjectText *text = new CChartObjectText;
      m_objs.Add(text);
      text.Create(0, name, 0, TimeCurrent(), m_filtered[index].Price());
      text.Color(m_color);
      text.FontSize(6);
      text.Anchor(ANCHOR_LEFT_LOWER);
      text.Description("#" + string(index + 1) + " - " + string(m_filtered[index].Score()));
      text.Detach();
   }
}
//+------------------------------------------------------------------+