//+------------------------------------------------------------------+
//|                                                        Pivot.mqh |
//|                                                      nicholishen |
//|                                   www.reddit.com/u/nicholishenFX |
//+------------------------------------------------------------------+
#property copyright "nicholishen"
#property link      "www.reddit.com/u/nicholishenFX"
#property version   "1.00"
#property strict
#include <Arrays\objvector.mqh>
//+------------------------------------------------------------------+
#define SORT_PRICE 0
#define SORT_SCORE 1
//+------------------------------------------------------------------+
class Pivot : public CObject
{
protected:
   double         m_price;
   double         m_body;
   double         m_wick;
   double         m_reversal;
public:
                  Pivot(const double price);
   double         Score()           const { return m_body+m_wick+m_reversal;  }
   double         Price()           const { return m_price;                   }
   double         Body()            const { return m_body;                    }
   double         Wick()            const { return m_wick;                    }
   double         Reverse()         const { return m_reversal;                }
   void           Body(const double points)    { m_body+=points;              }
   void           Wick(const double points)    { m_wick+=points;              }
   void           Reverse(const double points) { m_reversal +=points;         }
   virtual int    Compare(const CObject *node,const int mode=0)const override;
};
//+------------------------------------------------------------------+
Pivot::Pivot(const double price):m_price(price),
                                 m_body(0),
                                 m_wick(0),
                                 m_reversal(0)
{
}
//+------------------------------------------------------------------+
int Pivot::Compare(const CObject *node,const int mode=0)const
{
   Pivot *other = (Pivot*)node;
   if(mode==SORT_PRICE)
   {
      if(this.Price() > other.Price())return -1;
      if(this.Price() < other.Price())return 1;
   }
   else
   {
      if(this.Score() > other.Score())return -1;
      if(this.Score() < other.Score())return 1;
   }
   return 0;
}
//+------------------------------------------------------------------+