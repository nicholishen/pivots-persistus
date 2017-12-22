//+------------------------------------------------------------------+
//|                                                  PivotCollection.mqh |
//|                                                      nicholishen |
//|                                   www.reddit.com/u/nicholishenFX |
//+------------------------------------------------------------------+
#property copyright "nicholishen"
#property link "www.reddit.com/u/nicholishenFX"
#property version "1.00"
#property strict
#include "Pivot.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class PivotCollection : public objvector<Pivot *>
{
 protected:
   double m_high;
   double m_low;
   double m_last_price;

 public:
   PivotCollection();
   ~PivotCollection();
   void Init(const double, const double);
   bool CopyTo(PivotCollection &other);
   void Filter(const int, const int);
   double High() const { return m_high; }
   double Low() const { return m_low; }
   void High(const double h) { m_high = h; }
   void Low(const double l) { m_low = l; }
};
//+------------------------------------------------------------------+
PivotCollection::PivotCollection() : m_last_price(0)
{
}
//+------------------------------------------------------------------+
PivotCollection::~PivotCollection()
{
}
//+------------------------------------------------------------------+
void PivotCollection::Init(const double high, const double low)
{
   m_high = NormalizeDouble(high, _Digits);
   m_low = NormalizeDouble(low, _Digits);
   int reserve = int(((high - low) / _Point));
   Reserve(reserve);
   for (double price = m_high; price >= m_low; price = NormalizeDouble(price - _Point, _Digits))
      Add(new Pivot(price));
}
//+------------------------------------------------------------------+
bool PivotCollection::CopyTo(PivotCollection &other)
{
   other.Clear();
   other.High(High());
   other.Low(Low());
   return other.AssignArray(&this);
}
//+------------------------------------------------------------------+
void PivotCollection::Filter(const int num_pivots, const int points_between)
{
   objvector<Pivot *> temp;
   temp.FreeMode(false);
   double pb = points_between * _Point;
   Sort(SORT_SCORE);
   double iprice = 0, jprice = 0;
   for (int i = 0; i < Total(); i++)
   {
      if (i == 0)
      {
         temp.Add(this[i]);
         if (temp.Total() >= num_pivots)
            break;
         else
            continue;
      }
      iprice = this[i].Price();
      bool found = false;
      for (int j = 0; j < temp.Total(); j++)
      {
         jprice = temp[j].Price();
         if (fabs(iprice - jprice) <= pb)
         {
            found = true;
            break;
         }
      }
      if (!found)
      {
         //double debug = this[i].Price();
         temp.Add(this[i]);
         if (temp.Total() >= num_pivots)
            break;
      }
   }
   //int debug = temp.Total();
   this.AssignArray(&temp);
}