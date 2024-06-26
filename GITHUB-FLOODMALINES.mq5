//+------------------------------------------------------------------+
//|                                                 FLOODMALINES.mq5 |
//|                             Copyright 2024, SERDAR BERKE OZYASAR |
//|                                           https://www.sberke.com |
//+------------------------------------------------------------------+

#property copyright "Open Source 2024, ForexSignals Developments"
#property link      "https://www.youtube.com/ForexSignals"
#property description "FLOOD MA LINES TREND SERIES FOR MACHINE LEARNING"
#property description "GNU General Public License     "
#property description "Free for personal usage."
#property description "For commercial project please contact with us"
#property description "eurousdforexlive@gmail.com"
#property description "For other developments please visit https://youtube.com/ForexSignals"
#property version   "1.00"


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

#include <\Expert\Signal\SignalMA.mqh>               // Public Class CPositionInfo
double abroka;
double ma1[], ma2[], ma3[];
int mm1, mm2, mm3;

double xma1[], xma2[], xma3[];
int xmm1, xmm2, xmm3;

double zma1[], zma2[], zma3[];
int zmm1, zmm2, zmm3;


input string MyTradeSuffix;
ulong magicNumberSuffix = AccountInfoInteger(ACCOUNT_LOGIN);

#include <Trade\PositionInfo.mqh>               // Public Class CPositionInfo
#include <Trade\SymbolInfo.mqh>                 // Public Class CSymbolInfo
#include <Trade\Trade.mqh>                      // Public Clas CTrade
CPositionInfo  objPosition;                     // Properties of open position
CSymbolInfo    objSymbol;                       // symbol info object
CTrade         objTrade;

datetime  Get_history_from_date   = D'2017.08.15 11:06:20';  // From date
datetime  Get_history_to_date     = D'2099.08.15 11:06:20';//__DATE__+60*60*24;       // To date

ushort InpStopLoss=0;//Don't Change
ushort InpTakeProfit=0;//Don't Change
int numberBarsOpenPosition;
double operationStopLoss=0.0;
double operationTakeProffit=0.0;
double operationPrice=0.0;
double adjustPoint=0.0;
double ExtTakeProfit=0.0;
double ExtStopLoss=0.0;
int StartDateNumber;
long magicNumber;
double theHistoryProfit;
double theHistoryCounter;

double theMaxCacther;
double theMinCacther;



//+------------------------------------------------------------------+
//+ BOLLEAN AND DOUBLE CONTROLLERS
//+------------------------------------------------------------------+
input bool AutoRestart = true;
input bool CloseNowEverything = false;
double AutoTakeProfitLevel = 10.00;
double Ax = 10000.00;
double TargetEquity;
bool TradeControl;
//+------------------------------------------------------------------+
//+ GLOBALS
//+------------------------------------------------------------------+

int   EURUSD=0;
int   GBPUSD=1;
int   AUDUSD=2;
int   USDJPY=3;
int   USDCHF=4;
int   USDCAD=5;
int   EURAUD=6;
int   EURCAD=7;
int   EURCHF=8;
int   EURGBP=9;
int   EURJPY=10;
int   GBPJPY=11;
int   GBPCHF=12;
int   NZDUSD=13;
int   AUDCAD=14;
int   AUDJPY=15;
int   CHFJPY=16;
int   AUDNZD=17;
int   NZDJPY=18;
int   NZDCAD=19;
int   NZDCHF=20;
int   GBPNZD=21;
int   EURNZD=22;
int   GBPCAD=23;
int   GBPAUD=24;
int   AUDCHF=25;
int   CADCHF=26;
int   CADJPY=27;
int   XAUUSD=28;
int   GOLD=29;

//+------------------------------------------------------------------+
//+ READ TICK PRICES
//+------------------------------------------------------------------+
double theTickPrice[30];
double theTickAsk[30];
double theTickBid[30];

double theLastestAsk[30];
double theLastestBid[30];
double theNet[30];
double theNettingTotal[30];
double theNettingTickCounters[30];
double theNetFloat[30,21];
double theNet21[30];
double theNet7[30];
double theNet3[30];

double theMax[30];
double theMin[30];
double theMaxTicker[30];
double theMinTicker[30];
double theTickDifference[30];

//+------------------------------------------------------------------+
//+ EXECUTED PAIRS
//+------------------------------------------------------------------+
string myAllPairs[30];
double HowManyWorkingPairs = 28;
//+------------------------------------------------------------------+
//+ TRADE INFORMATION
//+------------------------------------------------------------------+
double MTBuyCounts[30];
double MTSellCounts[30];
double MTBuyVolume[30];
double MTSellVolume[30];
double MTBuyProfit[30];
double MTSellProfit[30];
double MTTotalSellProfit;
double MTTotalBuyProfit;
int MTOrderMin[30]; //control order minutes value
double MTTotalGProfit;
double MTTotalGLost;
double MTBuyProfitMax[30];
double MTSellProfitMax[30];


//+------------------------------------------------------------------+
//+ EXECUTE TRADE ORDES
//+------------------------------------------------------------------+
string theActualSignal[30];

//+------------------------------------------------------------------+
//+ SPIRIT RATES
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int theSpirit[30];//+100 TO -100 (MAX TO MIN)
int theSpiritSignal[30];//+100 TO -100 (MAX TO MIN)
int thePreSpirit[30];
string theSpiritTrend[30];

struct mysignal
  {
   string            now;
   string            pre;
   double            nowprice;
   double            preprice;
   double            extend;
  };

struct calsignal
  {
   string            signal;
   int               longcount;
   int               shortcount;
   double            longextendtotal;
   double            shortextendtotal;
   double            avelong;
   double            aveshort;
  };

mysignal supersignal[99999];
calsignal signalseperate[99999];
int supercounter;
int supercalcounter;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//---


   CallPairs();   //PAIRS LOADED
   TradeControl=true;
   for(int i=0; i<28; i++)
     {
      double CheckValue = thePrice(myAllPairs[i]);
      theMax[i]=CheckValue;
      theMin[i]=CheckValue;
      theActualSignal[i]="notr";
     }

   magicNumber = (long)magicNumberSuffix;
   TargetEquity = AccountInfoDouble(ACCOUNT_EQUITY) + AutoTakeProfitLevel;

   supercounter = 0;
   supercalcounter = 0;

   ENUM_TIMEFRAMES mytimeframe[];
   ArrayResize(mytimeframe, 10); // Dizi boyutunu tanımla

   mytimeframe[0] = PERIOD_M1;
   mytimeframe[1] = PERIOD_M5;
   mytimeframe[2] = PERIOD_M15;
   mytimeframe[3] = PERIOD_M30;
   mytimeframe[4] = PERIOD_H1;
   mytimeframe[5] = PERIOD_H4;
   mytimeframe[6] = PERIOD_D1;
   mytimeframe[7] = PERIOD_W1;
   mytimeframe[8] = PERIOD_MN1;

   int myperiod[10]; //period değeri
   string trend [10,10];
   myperiod[0] = 3;
   myperiod[1] = 7;
   myperiod[2] = 13;
   myperiod[3] = 21;
   myperiod[4] = 56;
   myperiod[5] = 233;
   myperiod[6] = 610;
   myperiod[7] = 843;
   myperiod[8] = 1253;
   int s = 1;
   int setbufferid = 0;
   for(int fs=1; fs>0; fs--)
     {
      setbufferid = 0;
      //if(MathMod(fs,100)==0){IndicatorRelease(mm1);IndicatorRelease(mm2);IndicatorRelease(mm3);Sleep(1000);}
      string subsignal = "";
      for(int i=0; i<7; i++)
        {
        
         subsignal = subsignal + "|M:"+(string)mytimeframe[i] + "|";
         //ctext = ctext + "\n" + (string)mytimeframe[i] + "\n";
         for(int j=0; j<7; j++)
           {
            if(i==0)
              {
               s=fs;
              }
            if(i==1)
              {
               s=(int)(fs/5)+1;
              }
            if(i==2)
              {
               s=(int)(fs/15)+1;
              }
            if(i==3)
              {
               s=(int)(fs/30)+1;
              }
            if(i==4)
              {
               s=(int)(fs/60)+1;
              }
            if(i==5)
              {
               s=(int)(fs/240)+1;
              }
            if(i==6)
              {
               s=(int)(fs/1440)+1;
              }
           
     
            mm2 = iMA(_Symbol,mytimeframe[i],myperiod[j],0,MODE_LWMA,iMA(_Symbol,mytimeframe[i],myperiod[j+1],0,MODE_LWMA,MODE_CLOSE));
            ArraySetAsSeries(ma2,true);
            SetIndexBuffer(0,ma2,INDICATOR_CALCULATIONS);  
            CopyBuffer(mm2,0,s,s+3,ma2);
            mm3 = iMA(_Symbol,mytimeframe[i],myperiod[j],0,MODE_LWMA,iMA(_Symbol,mytimeframe[i],myperiod[j+1],0,MODE_LWMA,iMA(_Symbol,mytimeframe[i],myperiod[j+2],0,MODE_LWMA,MODE_CLOSE)));
            ArraySetAsSeries(ma3,true);
            SetIndexBuffer(0,ma3,INDICATOR_CALCULATIONS);  
            CopyBuffer(mm3,0,s,s+3,ma3);
           
            setbufferid = setbufferid + 1;
            
            trend[i,j] = "N";
            if(ma2[s]>ma3[s])
              {
               trend[i,j]="L";
              }
            if(ma2[s]<ma3[s])
              {
               trend[i,j]="S";
              }
            subsignal = subsignal + trend[i,j];
           }
        }
      Print((string)fs + ":" + (string) supercounter + ":" + subsignal);
      if(supercounter==0)
        {
         supersignal[supercounter].now = subsignal;
         supersignal[supercounter].nowprice = iOpen(_Symbol,PERIOD_M1,fs);
         supersignal[supercounter].pre = subsignal;
         supersignal[supercounter].preprice = iOpen(_Symbol,PERIOD_M1,fs);
         supersignal[supercounter].extend = 0.0;
         supercounter = supercounter + 1;
        }
        
      if(supersignal[supercounter-1].now != subsignal)
        {
         supercounter = supercounter + 1;
         //Print(supercounter);
         supersignal[supercounter].now = subsignal;
         supersignal[supercounter].nowprice = iOpen(_Symbol,PERIOD_M1,fs);
         supersignal[supercounter].pre = supersignal[supercounter-1].now;
         supersignal[supercounter].preprice = supersignal[supercounter-1].nowprice;
         supersignal[supercounter-1].extend = (supersignal[supercounter].nowprice - supersignal[supercounter-1].nowprice)/_Point;
        }
        
      if(supercalcounter==0)
        {
         signalseperate[supercalcounter].signal = supersignal[supercounter].now;
         signalseperate[supercalcounter].longcount = 0;
         signalseperate[supercalcounter].shortcount = 0;
         signalseperate[supercalcounter].longextendtotal = signalseperate[supercalcounter].longextendtotal + supersignal[supercounter].extend;
         signalseperate[supercalcounter].shortextendtotal = signalseperate[supercalcounter].shortextendtotal + supersignal[supercounter].extend;
         signalseperate[supercalcounter].avelong = signalseperate[supercalcounter].longextendtotal / signalseperate[supercounter].longcount;
         signalseperate[supercalcounter].aveshort = signalseperate[supercalcounter].shortextendtotal / signalseperate[supercounter].shortcount;
         signalseperate[supercalcounter].aveshort = signalseperate[supercalcounter].shortextendtotal / signalseperate[supercalcounter].longcount;
         signalseperate[supercalcounter].aveshort = signalseperate[supercalcounter].shortextendtotal / signalseperate[supercalcounter].longcount;
         supercalcounter = 1;
        }
        
      if(supercalcounter>0)
        {
         //SIGNAL SEARCH & MATCH
         //TREND SELECTOR TRADE ANALYZER
        }
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   MqlDateTime stm;
   datetime tm=TimeCurrent(stm);

//21-13-7
//56-21-13
//233-56-21
//610-233-56

//SEARCH TIME FRAME
//M1-M5-M15-M30-H1-H4-D1


   ENUM_TIMEFRAMES mytimeframe[];
   ArrayResize(mytimeframe, 10); // Dizi boyutunu tanımla

   mytimeframe[0] = PERIOD_M1;
   mytimeframe[1] = PERIOD_M5;
   mytimeframe[2] = PERIOD_M15;
   mytimeframe[3] = PERIOD_M30;
   mytimeframe[4] = PERIOD_H1;
   mytimeframe[5] = PERIOD_H4;
   mytimeframe[6] = PERIOD_D1;
   mytimeframe[7] = PERIOD_W1;
   mytimeframe[8] = PERIOD_MN1;

   int myperiod[10]; //period değeri
   string trend [10,10];
   myperiod[0] = 3;
   myperiod[1] = 7;
   myperiod[2] = 13;
   myperiod[3] = 21;
   myperiod[4] = 56;
   myperiod[5] = 233;
   myperiod[6] = 610;
   myperiod[7] = 843;
   myperiod[8] = 1253;

//int ;
   string subsignal = "";
   string ctext = "\n\n\n\n";
   for(int i=0; i<7; i++)
     {
      subsignal = subsignal + "|M:"+(string)mytimeframe[i] + "|";
      ctext = ctext + "\n" + (string)mytimeframe[i] + "\n";
      for(int j=0; j<7; j++)
        {
         //mm1 = iMA(_Symbol,mytimeframe[i],myperiod[j],0,MODE_LWMA,MODE_CLOSE);
         //CopyBuffer(mm1,0,0,1,ma1);
         mm2 = iMA(_Symbol,mytimeframe[i],myperiod[j],0,MODE_LWMA,iMA(_Symbol,mytimeframe[i],myperiod[j+1],0,MODE_LWMA,MODE_CLOSE));
         CopyBuffer(mm2,0,0,1,ma2);
         mm3 = iMA(_Symbol,mytimeframe[i],myperiod[j],0,MODE_LWMA,iMA(_Symbol,mytimeframe[i],myperiod[j+1],0,MODE_LWMA,iMA(_Symbol,mytimeframe[i],myperiod[j+2],0,MODE_LWMA,MODE_CLOSE)));
         CopyBuffer(mm3,0,0,1,ma3);
         if(ma2[0]>ma3[0])
           {
            trend[i,j]="L";
           }
         if(ma2[0]<ma3[0])
           {
            trend[i,j]="S";
           }
         subsignal = subsignal + trend[i,j];
         ctext = ctext + "["+trend[i,j]+":"+DoubleToString(ma2[0],2)+"]";
        }
     }

      ctext = ctext + "\n\n\n" + subsignal;
      

   Comment(ctext);




  }
//+------------------------------------------------------------------+




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateSpiritRates()
  {
   for(int i=0; i<28; i++)
     {
      double vpoint = mySymbolPointNew2(myAllPairs[i]);
      double A = myPipDifferenceAbsolute(theMax[i],theMin[i],vpoint);
      double B = myPipDifference(theMax[i],theNet[i],vpoint);
      double C = myPipDifference(theNet[i],theMin[i],vpoint);
      double RateB = (B/A)*100;
      double RateC = (C/A)*100;
      double theSpiritRate = RateC - RateB;
      theSpirit[i] = (int)theSpiritRate * 1;
      B = myPipDifference(theMax[i],thePrice(myAllPairs[i]),vpoint);
      C = myPipDifference(thePrice(myAllPairs[i]),theMin[i],vpoint);
      RateB = (B/A)*100;
      RateC = (C/A)*100;
      theSpiritRate = RateC - RateB;
      theSpiritSignal[i] = (int)theSpiritRate * 1;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckMaxMin()
  {
   for(int i=0; i<28; i++)
     {
      double CheckValue = thePrice(myAllPairs[i]);

      double routermax=0.0;
      double routermin=0.0;

      routermax=MathAbs(CheckValue/theMax[i]);
      routermin=MathAbs(theMin[i]/CheckValue);

      if(theMax[i]<=CheckValue&&routermax<1.01&&routermax>1.00)
        {
         theMax[i]=CheckValue;
         theMaxTicker[i]=0.0;
        }
      if(theMin[i]>=CheckValue&&routermin<1.01&&routermin>1.00)
        {
         theMin[i]=CheckValue;
         theMinTicker[i]=0.0;
        }
      theMaxTicker[i] = theMaxTicker[i] + 1.00;
      theMinTicker[i] = theMinTicker[i] + 1.00;
      theTickDifference[i] = theMinTicker[i] - theMaxTicker[i];
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double thePrice(string thePair)
  {
   double xturn = (theAsk(thePair) + theBid(thePair))/2.00;
   return(xturn);
  }
//+------------------------------------------------------------------+
//+ NETTING CALCULATIONS
//+------------------------------------------------------------------+
void CalculateNettings()
  {
   for(int i=0; i<28; i++)
     {
      double thePriceNow = thePrice(myAllPairs[i]);// (theAsk(myAllPairs[i]) + theBid(myAllPairs[i]))/2.00;
      double checkPrice = (theLastestAsk[i] + theLastestBid[i])/2.0;
      double checkRate = checkPrice/thePriceNow;
      if((checkRate>1.01||checkRate<0.99)&&theLastestAsk[i]!=0.0&&theLastestBid[i]!=0.0)
        {
         thePriceNow=checkPrice;
        }
      theNettingTotal[i] = theNettingTotal[i] + thePriceNow;
      theNettingTickCounters[i] = theNettingTickCounters[i] + 1.00;
      theNet[i] = theNettingTotal[i] / theNettingTickCounters[i];

      /*
      if(theNetFloat[i,0]!=theNet[i])
         {
         for(int j=20;j>0;j--)
            {
               theNetFloat[i,j] = theNetFloat[i,j-1];
            }
         theNetFloat[i,0] = theNet[i];
         }

      theNet3[i] = 0.00;
      theNet7[i] = 0.00;
      theNet21[i] = 0.00;
         for(int j=0;j<21;j++)
            {
                  if(j<3)
                  {
                     theNet3[i] = theNet3[i]+theNetFloat[i,j];
                  }
                  if(j<7)
                  {
                     theNet7[i] = theNet7[i]+theNetFloat[i,j];
                  }
                  if(j<21)
                  {
                     theNet21[i] = theNet21[i]+theNetFloat[i,j];
                  }
            }
      theNet3[i] = theNet3[i]/3.00;
      theNet7[i] = theNet7[i]/7.00;
      theNet21[i] = theNet21[i]/21.00;
      */
     }
  }
//+------------------------------------------------------------------+
//+ READ ASK PRICE AND ERROR CHECK
//+------------------------------------------------------------------+
double theAsk(string thePair)
  {
   double read=SymbolInfoDouble(thePair,SYMBOL_ASK);
   if(read==0.0)
     {
      read=theLastestAsk[mySymbolId(thePair)];
      Print("Read error ASK close used last: " + DoubleToString(read,8));
     }
   if(read==0.0)
     {
      read=iClose(thePair,PERIOD_M1,1);
      Print("Read error ASK close used close: " + DoubleToString(read,8));
     }
   double checkrate = theLastestAsk[mySymbolId(thePair)]/read;
   if(checkrate<1.001||checkrate>0.999)
     {
      theLastestAsk[mySymbolId(thePair)] = read;
     }
   if(checkrate>1.001||checkrate<0.999)
     {
      read = theLastestAsk[mySymbolId(thePair)];
     }//Print("Read error BID close used previous: " + DoubleToString(read,8));}
   return(read);
  }
//+------------------------------------------------------------------+
//+ READ BID PRICE AND ERROR CHECK
//+------------------------------------------------------------------+
double theBid(string thePair)
  {
   double read=SymbolInfoDouble(thePair,SYMBOL_BID);
   if(read==0.0)
     {
      read=theLastestBid[mySymbolId(thePair)];
      Print("Read error ASK close used last: " + DoubleToString(read,8));
     }
   if(read==0.0)
     {
      read=iClose(thePair,PERIOD_M1,1);
      Print("Read error BID close used close: " + DoubleToString(read,8));
     }
   double checkrate = theLastestAsk[mySymbolId(thePair)]/read;
   if(checkrate<1.001||checkrate>0.999)
     {
      theLastestAsk[mySymbolId(thePair)] = read;
     }
   if(checkrate>1.001||checkrate<0.999)
     {
      read = theLastestAsk[mySymbolId(thePair)];
     }//Print("Read error BID close used previous: " + DoubleToString(read,8));}
   return(read);
  }
//+------------------------------------------------------------------+
//+ RETURN SYMBOLS DIGIT STRING TO INTEGER
//+------------------------------------------------------------------+
int mySymbolDigit(string _mySymbol)
  {
   int vpoint = 00001;
//return(SymbolInfoDouble(_mySymbol,SYMBOL_POINT));
   if(_mySymbol==myAllPairs[EURUSD])
     {
      vpoint=5;
     }
   if(_mySymbol==myAllPairs[GBPUSD])
     {
      vpoint=5;
     }
   if(_mySymbol==myAllPairs[AUDUSD])
     {
      vpoint=5;
     }
   if(_mySymbol==myAllPairs[USDJPY])
     {
      vpoint=3;
     }
   if(_mySymbol==myAllPairs[USDCHF])
     {
      vpoint=5;
     }
   if(_mySymbol==myAllPairs[USDCAD])
     {
      vpoint=5;
     }
   if(_mySymbol==myAllPairs[EURAUD])
     {
      vpoint=5;
     }
   if(_mySymbol==myAllPairs[EURCAD])
     {
      vpoint=5;
     }
   if(_mySymbol==myAllPairs[EURCHF])
     {
      vpoint=5;
     }
   if(_mySymbol==myAllPairs[EURGBP])
     {
      vpoint=5;
     }
   if(_mySymbol==myAllPairs[EURJPY])
     {
      vpoint=3;
     }
   if(_mySymbol==myAllPairs[GBPJPY])
     {
      vpoint=3;
     }
   if(_mySymbol==myAllPairs[GBPCHF])
     {
      vpoint=5;
     }
   if(_mySymbol==myAllPairs[NZDUSD])
     {
      vpoint=5;
     }
   if(_mySymbol==myAllPairs[AUDCAD])
     {
      vpoint=5;
     }
   if(_mySymbol==myAllPairs[AUDJPY])
     {
      vpoint=3;
     }
   if(_mySymbol==myAllPairs[CHFJPY])
     {
      vpoint=3;
     }
   if(_mySymbol==myAllPairs[AUDNZD])
     {
      vpoint=5;
     }
   if(_mySymbol==myAllPairs[NZDJPY])
     {
      vpoint=2;
     }
   if(_mySymbol==myAllPairs[NZDCAD])
     {
      vpoint=5;
     }
   if(_mySymbol==myAllPairs[NZDCHF])
     {
      vpoint=5;
     }
   if(_mySymbol==myAllPairs[GBPNZD])
     {
      vpoint=5;
     }
   if(_mySymbol==myAllPairs[EURNZD])
     {
      vpoint=5;
     }
   if(_mySymbol==myAllPairs[GBPCAD])
     {
      vpoint=5;
     }
   if(_mySymbol==myAllPairs[GBPAUD])
     {
      vpoint=5;
     }
   if(_mySymbol==myAllPairs[AUDCHF])
     {
      vpoint=5;
     }
   if(_mySymbol==myAllPairs[CADCHF])
     {
      vpoint=5;
     }
   if(_mySymbol==myAllPairs[CADJPY])
     {
      vpoint=3;
     }
   if(_mySymbol==myAllPairs[XAUUSD])
     {
      vpoint=2;
     }
   if(_mySymbol==myAllPairs[GOLD])
     {
      vpoint=2;
     }
   return(vpoint);
  }
//+------------------------------------------------------------------+
//+ RETURN SYMBOL ID STRING TO INTEGER
//+------------------------------------------------------------------+
int mySymbolId(string _mySymbol)
  {
   int vpoint = 00001;
//return(SymbolInfoDouble(_mySymbol,SYMBOL_POINT));
   if(_mySymbol==myAllPairs[EURUSD])
     {
      vpoint=EURUSD;
     }
   if(_mySymbol==myAllPairs[GBPUSD])
     {
      vpoint=GBPUSD;
     }
   if(_mySymbol==myAllPairs[AUDUSD])
     {
      vpoint=AUDUSD;
     }
   if(_mySymbol==myAllPairs[USDJPY])
     {
      vpoint=USDJPY;
     }
   if(_mySymbol==myAllPairs[USDCHF])
     {
      vpoint=USDCHF;
     }
   if(_mySymbol==myAllPairs[USDCAD])
     {
      vpoint=USDCAD;
     }
   if(_mySymbol==myAllPairs[EURAUD])
     {
      vpoint=EURAUD;
     }
   if(_mySymbol==myAllPairs[EURCAD])
     {
      vpoint=EURCAD;
     }
   if(_mySymbol==myAllPairs[EURCHF])
     {
      vpoint=EURCHF;
     }
   if(_mySymbol==myAllPairs[EURGBP])
     {
      vpoint=EURGBP;
     }
   if(_mySymbol==myAllPairs[EURJPY])
     {
      vpoint=EURJPY;
     }
   if(_mySymbol==myAllPairs[GBPJPY])
     {
      vpoint=GBPJPY;
     }
   if(_mySymbol==myAllPairs[GBPCHF])
     {
      vpoint=GBPCHF;
     }
   if(_mySymbol==myAllPairs[NZDUSD])
     {
      vpoint=NZDUSD;
     }
   if(_mySymbol==myAllPairs[AUDCAD])
     {
      vpoint=AUDCAD;
     }
   if(_mySymbol==myAllPairs[AUDJPY])
     {
      vpoint=AUDJPY;
     }
   if(_mySymbol==myAllPairs[CHFJPY])
     {
      vpoint=CHFJPY;
     }
   if(_mySymbol==myAllPairs[AUDNZD])
     {
      vpoint=AUDNZD;
     }
   if(_mySymbol==myAllPairs[NZDJPY])
     {
      vpoint=NZDJPY;
     }
   if(_mySymbol==myAllPairs[NZDCAD])
     {
      vpoint=NZDCAD;
     }
   if(_mySymbol==myAllPairs[NZDCHF])
     {
      vpoint=NZDCHF;
     }
   if(_mySymbol==myAllPairs[GBPNZD])
     {
      vpoint=GBPNZD;
     }
   if(_mySymbol==myAllPairs[EURNZD])
     {
      vpoint=EURNZD;
     }
   if(_mySymbol==myAllPairs[GBPCAD])
     {
      vpoint=GBPCAD;
     }
   if(_mySymbol==myAllPairs[GBPAUD])
     {
      vpoint=GBPUSD;
     }
   if(_mySymbol==myAllPairs[AUDCHF])
     {
      vpoint=AUDCHF;
     }
   if(_mySymbol==myAllPairs[CADCHF])
     {
      vpoint=CADCHF;
     }
   if(_mySymbol==myAllPairs[CADJPY])
     {
      vpoint=CADJPY;
     }
   if(_mySymbol==myAllPairs[XAUUSD])
     {
      vpoint=XAUUSD;
     }
   if(_mySymbol==myAllPairs[GOLD])
     {
      vpoint=GOLD;
     }
   return(vpoint);
  }
//+------------------------------------------------------------------+
//+ LOAD PAIRS LABELS WITH SUFFIX
//+------------------------------------------------------------------+
void CallPairs()
  {
   myAllPairs[0]=_Symbol;//"EURUSD"+MyTradeSuffix;
   myAllPairs[1]="GBPUSD"+MyTradeSuffix;
   myAllPairs[2]="AUDUSD"+MyTradeSuffix;
   myAllPairs[3]="USDJPY"+MyTradeSuffix;
   myAllPairs[4]="USDCHF"+MyTradeSuffix;
   myAllPairs[5]="USDCAD"+MyTradeSuffix;
   myAllPairs[6]="EURAUD"+MyTradeSuffix;
   myAllPairs[7]="EURCAD"+MyTradeSuffix;
   myAllPairs[8]="EURCHF"+MyTradeSuffix;
   myAllPairs[9]="EURGBP"+MyTradeSuffix;
   myAllPairs[10]="EURJPY"+MyTradeSuffix;
   myAllPairs[11]="GBPJPY"+MyTradeSuffix;
   myAllPairs[12]="GBPCHF"+MyTradeSuffix;
   myAllPairs[13]="NZDUSD"+MyTradeSuffix;
   myAllPairs[14]="AUDCAD"+MyTradeSuffix;
   myAllPairs[15]="AUDJPY"+MyTradeSuffix;
   myAllPairs[16]="CHFJPY"+MyTradeSuffix;
   myAllPairs[17]="AUDNZD"+MyTradeSuffix;
   myAllPairs[18]="NZDJPY"+MyTradeSuffix;
   myAllPairs[19]="NZDCAD"+MyTradeSuffix;
   myAllPairs[20]="NZDCHF"+MyTradeSuffix;
   myAllPairs[21]="GBPNZD"+MyTradeSuffix;
   myAllPairs[22]="EURNZD"+MyTradeSuffix;
   myAllPairs[23]="GBPCAD"+MyTradeSuffix;
   myAllPairs[24]="GBPAUD"+MyTradeSuffix;
   myAllPairs[25]="AUDCHF"+MyTradeSuffix;
   myAllPairs[26]="CADCHF"+MyTradeSuffix;
   myAllPairs[27]="CADJPY"+MyTradeSuffix;
   myAllPairs[28]="XAUUSD"+MyTradeSuffix;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getprofitbyticket(ulong ticketid)
  {
   int total=PositionsTotal();
   ulong position_ticket= (ulong)PositionGetTicket((int)ticketid);
   double position_profit=PositionGetDouble(POSITION_PROFIT)-MathAbs(PositionGetDouble(POSITION_SWAP));
   return(position_profit);
  }

//+------------------------------------------------------------------+
//+ TRADE INFORMATION                                                +
//+------------------------------------------------------------------+
void TradeInfo()
  {
   int total=PositionsTotal();
   for(int kl=0; kl<HowManyWorkingPairs; kl++)
     {
      MTSellCounts[kl]=0.00;
      MTSellProfit[kl]=0.00;
      MTSellVolume[kl]=0.00;
      MTBuyCounts[kl]=0.00;
      MTBuyProfit[kl]=0.00;
      MTBuyVolume[kl]=0.00;
      MTTotalBuyProfit=0.00;
      MTTotalSellProfit=0.00;
      MTTotalGProfit=0.00;
      MTTotalGLost=0.00;
     }
   for(int i=0; i<total; i++)
     {
      ulong  position_ticket=PositionGetTicket(i);
      string position_symbol=PositionGetString(POSITION_SYMBOL);
      double position_profit=PositionGetDouble(POSITION_PROFIT)-MathAbs(PositionGetDouble(POSITION_SWAP));
      double position_size=PositionGetDouble(POSITION_VOLUME);
      ulong  magic=PositionGetInteger(POSITION_MAGIC);
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

      for(int j=0; j<=HowManyWorkingPairs; j++)

        {
         if(position_symbol==myAllPairs[j]&&POSITION_TYPE_BUY==type&&magic==magicNumber)
           {
            MTBuyCounts[j]=MTBuyCounts[j]+1.00;
            MTBuyProfit[j]=MTBuyProfit[j]+position_profit;
            MTBuyVolume[j]=MTBuyVolume[j]+position_size;
            MTTotalBuyProfit=MTTotalBuyProfit+position_profit;
            if(position_profit>0.00)
              {
               MTTotalGProfit=MTTotalGProfit+position_profit;
              }
            if(position_profit<0.00)
              {
               MTTotalGLost=MTTotalGLost+position_profit;
              }
           }
         if(position_symbol==myAllPairs[j]&&POSITION_TYPE_SELL==type&&magic==magicNumber)
           {
            MTSellCounts[j]=MTSellCounts[j]+1.00;
            MTSellProfit[j]=MTSellProfit[j]+position_profit;
            MTSellVolume[j]=MTSellVolume[j]+position_size;
            MTTotalSellProfit=MTTotalSellProfit+position_profit;
            if(position_profit>0.00)
              {
               MTTotalGProfit=MTTotalGProfit+position_profit;
              }
            if(position_profit<0.00)
              {
               MTTotalGLost=MTTotalGLost+position_profit;
              }
           }
        }


     }
  }


//+------------------------------------------------------------------+



//+-------------------------------------------------------------------------+
//+ TRADE FUNCTIONS
//+-------------------------------------------------------------------------+


//+ESKI KODLAR ------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Sell(double _volume=0.01,string _symbol="EURUSD",string _CommentSellProfit="0.00")
  {
   double volume=_volume;
//string symbol=_symbol;
   string symbol=_symbol;
   int    digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
   double SL=SetStopLoss(ORDER_TYPE_SELL);
   SL=NormalizeDouble(SL,digits);
   double TP=SetTakeProffit(ORDER_TYPE_SELL);
   TP=NormalizeDouble(TP,digits);
   double open_price=SymbolInfoDouble(symbol,SYMBOL_BID);
   string comment=StringFormat("SELL %s %G lots at %s, SL=%s TP=%s",
                               symbol,volume,
                               DoubleToString(open_price,digits),
                               DoubleToString(SL,digits),
                               DoubleToString(TP,digits));
//comment = magicNumber + " " + comment;
   comment = _CommentSellProfit;

//Print(comment);
   operationStopLoss=SL;
   operationTakeProffit=TP;
   operationPrice=open_price;
   objTrade.SetExpertMagicNumber(magicNumber);
   numberBarsOpenPosition=Bars(Symbol(),PERIOD_CURRENT);
   bool canSell=objTrade.Sell(volume,symbol,open_price,SL,TP,comment);
   if(!canSell)
     {
      //--- mensaje de error
      /*Print("Fail Sell() method. Return code=",objTrade.ResultRetcode(),
            ". error message: ",objTrade.ResultRetcodeDescription());*/
     }
//Sleep(8000);

  }
//+------------------------------------------------------------------+
void Buy(double _volume=0.01,string _symbol="EURUSD", string _CommentBuyProfit="0.00")
  {
   double volume=_volume;
//string symbol=_symbol;
   string symbol=_symbol;
   int    digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
   double SL=SetStopLoss(ORDER_TYPE_BUY);
   SL=NormalizeDouble(SL,digits);
   double TP=SetTakeProffit(ORDER_TYPE_BUY);
   TP=NormalizeDouble(TP,digits);
   double open_price=SymbolInfoDouble(symbol,SYMBOL_ASK);
   string comment=StringFormat("BUY %s %G lots at %s, SL=%s TP=%s",
                               symbol,volume,
                               DoubleToString(open_price,digits),
                               DoubleToString(SL,digits),
                               DoubleToString(TP,digits));
//comment = magicNumber + " " + comment;
   comment = _CommentBuyProfit;
//Print(comment);
   operationStopLoss=SL;
   operationTakeProffit=TP;
   operationPrice=open_price;
   objTrade.SetExpertMagicNumber(magicNumber);
   numberBarsOpenPosition=Bars(Symbol(),PERIOD_CURRENT);
   bool canBuy=objTrade.Buy(volume,symbol,open_price,SL,TP,comment);
   if(!canBuy)
     {
      //--- mensaje de error
      /*Print("Fail Buy() method. Return code=",objTrade.ResultRetcode(),
            ". error message: ",objTrade.ResultRetcodeDescription());*/
     }
//Sleep(8000);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
double SetStopLoss(ENUM_ORDER_TYPE orderType)
  {
   double sl=0.0;
   double _ASK = SymbolInfoDouble(Symbol(),SYMBOL_ASK);
   double _BID = SymbolInfoDouble(Symbol(),SYMBOL_BID);
   if(orderType==ORDER_TYPE_BUY)
     {
      sl=(InpStopLoss==0)?0.0:_ASK-ExtStopLoss;
     }
   else
      if(orderType==ORDER_TYPE_SELL)
        {
         sl=(InpStopLoss==0)?0.0:_BID+ExtStopLoss;
        }
   return(sl);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SetTakeProffit(ENUM_ORDER_TYPE orderType)
  {
   double tp=0.0;
   double _ASK = SymbolInfoDouble(Symbol(),SYMBOL_ASK);
   double _BID = SymbolInfoDouble(Symbol(),SYMBOL_BID);
   if(orderType==ORDER_TYPE_BUY)
     {
      tp=(InpTakeProfit==0)?0.0:_ASK+ExtTakeProfit;
     }
   else
      if(orderType==ORDER_TYPE_SELL)
        {
         tp=(InpTakeProfit==0)?0.0: _BID-ExtTakeProfit;
        }
   return(tp);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int SetDigitsAdjusts(int adjustDigits=1)
  {
   int _adjustDigits=adjustDigits;
   int symbolDigits=objSymbol.Digits();
   if(symbolDigits==3 || symbolDigits==5)
      _adjustDigits=10;
   return(_adjustDigits);
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
bool CloseAllPositionsOrders()
  {
//magicNumber=XmagicNumber;
//magicNumberLevel=1;
   int contClosePositionFail=0;
   int positionsTotal=PositionsTotal();
   for(int i=positionsTotal-1; i>=0; i--)
     {
      ulong ticket=PositionGetTicket(i);

      ulong  position_ticket=PositionGetTicket(i);
      string position_symbol=PositionGetString(POSITION_SYMBOL);
      double position_profit=PositionGetDouble(POSITION_PROFIT);
      double position_size=PositionGetDouble(POSITION_VOLUME);
      ulong  magic=PositionGetInteger(POSITION_MAGIC);
      bool restulClosePositon;
      restulClosePositon = false;

      if(magic==magicNumber)
         restulClosePositon=ClosePosition(ticket);

      if(!restulClosePositon)
         contClosePositionFail++;
     }
   return(contClosePositionFail>0 ?true : false);
  }


//+------------------------------------------------------------------+
//+ CLOSE BOOL CONTROLLER                                            +
//+------------------------------------------------------------------+
bool ClosePosition(ulong ticket=0)
  {
   return objTrade.PositionClose(ticket);
  }






//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double myTargetPrice(double _Price1, double _TargetPips, double _SymPoint)
  {
   double _TargetPrice = _Price1 + _TargetPips * _SymPoint;
   return(_TargetPrice);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double myPipDifference(double _Price1, double _Price2, double _SymPoint)
  {

   double _Pips=(_Price1-_Price2)/_SymPoint;
   double returnPips = _Pips * 1;
   return(returnPips);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double myPipDifferenceAbsolute(double _Price1, double _Price2, double _SymPoint)
  {

   double _Pips=(_Price1-_Price2)/_SymPoint;
   double returnPips = MathAbs(_Pips) * 1;
   return(returnPips);
  }






//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double mySymbolPointNew2(string _mySymbol)
  {
   double vpoint = 00001;
//return(SymbolInfoDouble(_mySymbol,SYMBOL_POINT));
   if(_mySymbol==myAllPairs[EURUSD])
     {
      vpoint=0.00001;
     }
   if(_mySymbol==myAllPairs[GBPUSD])
     {
      vpoint=0.00001;
     }
   if(_mySymbol==myAllPairs[AUDUSD])
     {
      vpoint=0.00001;
     }
   if(_mySymbol==myAllPairs[USDJPY])
     {
      vpoint=0.001;
     }
   if(_mySymbol==myAllPairs[USDCHF])
     {
      vpoint=0.00001;
     }
   if(_mySymbol==myAllPairs[USDCAD])
     {
      vpoint=0.00001;
     }
   if(_mySymbol==myAllPairs[EURAUD])
     {
      vpoint=0.00001;
     }
   if(_mySymbol==myAllPairs[EURCAD])
     {
      vpoint=0.00001;
     }
   if(_mySymbol==myAllPairs[EURCHF])
     {
      vpoint=0.00001;
     }
   if(_mySymbol==myAllPairs[EURGBP])
     {
      vpoint=0.00001;
     }
   if(_mySymbol==myAllPairs[EURJPY])
     {
      vpoint=0.001;
     }
   if(_mySymbol==myAllPairs[GBPJPY])
     {
      vpoint=0.001;
     }
   if(_mySymbol==myAllPairs[GBPCHF])
     {
      vpoint=0.00001;
     }
   if(_mySymbol==myAllPairs[NZDUSD])
     {
      vpoint=0.00001;
     }
   if(_mySymbol==myAllPairs[AUDCAD])
     {
      vpoint=0.00001;
     }
   if(_mySymbol==myAllPairs[AUDJPY])
     {
      vpoint=0.001;
     }
   if(_mySymbol==myAllPairs[CHFJPY])
     {
      vpoint=0.001;
     }
   if(_mySymbol==myAllPairs[AUDNZD])
     {
      vpoint=0.00001;
     }
   if(_mySymbol==myAllPairs[NZDJPY])
     {
      vpoint=0.001;
     }
   if(_mySymbol==myAllPairs[NZDCAD])
     {
      vpoint=0.00001;
     }
   if(_mySymbol==myAllPairs[NZDCHF])
     {
      vpoint=0.00001;
     }
   if(_mySymbol==myAllPairs[GBPNZD])
     {
      vpoint=0.00001;
     }
   if(_mySymbol==myAllPairs[EURNZD])
     {
      vpoint=0.00001;
     }
   if(_mySymbol==myAllPairs[GBPCAD])
     {
      vpoint=0.00001;
     }
   if(_mySymbol==myAllPairs[GBPAUD])
     {
      vpoint=0.00001;
     }
   if(_mySymbol==myAllPairs[AUDCHF])
     {
      vpoint=0.00001;
     }
   if(_mySymbol==myAllPairs[CADCHF])
     {
      vpoint=0.00001;
     }
   if(_mySymbol==myAllPairs[CADJPY])
     {
      vpoint=0.001;
     }
   if(_mySymbol==myAllPairs[XAUUSD])
     {
      vpoint=0.01;
     }
   if(_mySymbol==myAllPairs[GOLD])
     {
      vpoint=0.01;
     }
   return(vpoint);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string myAccountFullInfo()
  {
   string Info = "\nRobot Trades:"+(string)TradeControl;
   Info += "\nBroker:"+myAccountBroker();
   Info += "\nServer:"+myAccountServer();
   Info += "\nType:"+myAccountType();
   Info += "\nCurrency:"+myAccountBaseCurrency();
   Info += "\nOwner:"+myAccountOwner();
   Info += "\nAccount ID:"+DoubleToString(myAccountId(),0);
   Info += "\nLeverage:"+DoubleToString(myAccountLeverage(),2);
   Info += "\nBalance:"+DoubleToString(myAccountBalance(),2);
   Info += "\nCredit:"+DoubleToString(myAccountCredit(),2);
   Info += "\nEquity:"+DoubleToString(myAccountEquity(),2);
   Info += "\nProfit:"+DoubleToString(myAccountProfit(),2);
   Info += "\nMargin:"+DoubleToString(myAccountMargin(),2);
   Info += "\nMarginFree:"+DoubleToString(myAccountMarginFree(),2);

   return(Info);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double myAccountMarginFree()
  {
   return(AccountInfoDouble(ACCOUNT_MARGIN_FREE));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double myAccountMargin()
  {
   return(AccountInfoDouble(ACCOUNT_MARGIN));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string myAccountBroker()
  {
   return(AccountInfoString(ACCOUNT_COMPANY));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string myAccountBaseCurrency()
  {
   return(AccountInfoString(ACCOUNT_CURRENCY));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string myAccountOwner()
  {
   return(AccountInfoString(ACCOUNT_NAME));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string myAccountServer()
  {
   return(AccountInfoString(ACCOUNT_SERVER));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ulong myAccountLeverage()
  {
   return(AccountInfoInteger(ACCOUNT_LEVERAGE));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ulong myAccountId()
  {
   return(AccountInfoInteger(ACCOUNT_LOGIN));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double myAccountBalance()
  {
   return(AccountInfoDouble(ACCOUNT_BALANCE));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double myAccountCredit()
  {
   return(AccountInfoDouble(ACCOUNT_CREDIT));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double myAccountEquity()
  {
   return(AccountInfoDouble(ACCOUNT_EQUITY));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double myAccountProfit()
  {
   return(AccountInfoDouble(ACCOUNT_PROFIT));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string myAccountType()
  {

   ENUM_ACCOUNT_TRADE_MODE account_type=(ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE);
//--- Now transform the value of  the enumeration into an understandable form
   string trade_mode;
   switch(account_type)
     {
      case  ACCOUNT_TRADE_MODE_DEMO:
         trade_mode="demo";
         break;
      case  ACCOUNT_TRADE_MODE_CONTEST:
         trade_mode="contest";
         break;
      default:
         trade_mode="real";
         break;
     }
   return(trade_mode);
  }




//+------------------------------------------------------------------+
//| Request trade history                                            |
//+------------------------------------------------------------------+
void RequestTradeHistorybyMagicbyProfit()
  {
//--- request trade history
//theHistoryProfit = 0.0;
//Print("A:");
   HistorySelect(Get_history_from_date,Get_history_to_date);
   uint total_deals=HistoryDealsTotal();
   ulong ticket_history_deal=0;
   ulong x_ticket_history_deal = 0;
//--- for all deals
//Print("B:"+total_deals);

   for(uint i=0; i<total_deals; i++)
     {
      //--- try to get deals ticket_history_deal
      if((ticket_history_deal=HistoryDealGetTicket(i))>0)
        {
         //Print("C:"+ticket_history_deal);

         long     deal_ticket       =HistoryDealGetInteger(ticket_history_deal,DEAL_TICKET);
         long     deal_order        =HistoryDealGetInteger(ticket_history_deal,DEAL_ORDER);
         long     deal_time         =HistoryDealGetInteger(ticket_history_deal,DEAL_TIME);
         long     deal_time_msc     =HistoryDealGetInteger(ticket_history_deal,DEAL_TIME_MSC);
         long     deal_type         =HistoryDealGetInteger(ticket_history_deal,DEAL_TYPE);
         long     deal_entry        =HistoryDealGetInteger(ticket_history_deal,DEAL_ENTRY);
         long     deal_magic        =HistoryDealGetInteger(ticket_history_deal,DEAL_MAGIC);
         long     deal_reason       =HistoryDealGetInteger(ticket_history_deal,DEAL_REASON);
         long     deal_position_id  =HistoryDealGetInteger(ticket_history_deal,DEAL_POSITION_ID);

         double   deal_volume       =HistoryDealGetDouble(ticket_history_deal,DEAL_VOLUME);
         double   deal_price        =HistoryDealGetDouble(ticket_history_deal,DEAL_PRICE);
         double   deal_commission   =HistoryDealGetDouble(ticket_history_deal,DEAL_COMMISSION);
         double   deal_swap         =HistoryDealGetDouble(ticket_history_deal,DEAL_SWAP);
         double   deal_profit       =HistoryDealGetDouble(ticket_history_deal,DEAL_PROFIT);

         if(deal_profit!=0.0&&magicNumber==deal_magic)
           {
            theHistoryProfit=theHistoryProfit+deal_profit;
            theHistoryCounter=theHistoryCounter+1;
           }

         //if(deal_profit==0.00)Print(">"+deal_order);

         x_ticket_history_deal=0;
         if(deal_profit==0.0&&magicNumber==deal_magic)
           {
            //Print("C:"+ticket_history_deal);
            for(uint k=0; k<total_deals; k++)
              {
               if((x_ticket_history_deal=HistoryDealGetTicket(k))>0)
                 {

                  long     x_deal_ticket       =HistoryDealGetInteger(x_ticket_history_deal,DEAL_TICKET);
                  long     x_deal_order        =HistoryDealGetInteger(x_ticket_history_deal,DEAL_ORDER);
                  long     x_deal_position_id  =HistoryDealGetInteger(x_ticket_history_deal,DEAL_POSITION_ID);
                  long     x_deal_reason       =HistoryDealGetInteger(x_ticket_history_deal,DEAL_REASON);

                  double   x_deal_profit       =HistoryDealGetDouble(x_ticket_history_deal,DEAL_PROFIT);

                  if(x_deal_position_id==deal_position_id&&x_deal_reason==0)
                    {
                     theHistoryProfit=theHistoryProfit+x_deal_profit;
                     theHistoryCounter=theHistoryCounter+1;
                    }

                  //if(x_deal_position_id==deal_position_id)Print(deal_position_id+">>"+x_deal_reason+"|"+x_deal_profit);
                  //Print(">>>"+x_deal_ticket + "|"+deal_order);
                 }

              }
           }


         string   deal_symbol       =HistoryDealGetString(ticket_history_deal,DEAL_SYMBOL);
         string   deal_comment      =HistoryDealGetString(ticket_history_deal,DEAL_COMMENT);
         string   deal_external_id  =HistoryDealGetString(ticket_history_deal,DEAL_EXTERNAL_ID);

         string time=TimeToString((datetime)deal_time,TIME_DATE|TIME_MINUTES|TIME_SECONDS);
         string type=EnumToString((ENUM_DEAL_TYPE)deal_type);
         string entry=EnumToString((ENUM_DEAL_ENTRY)deal_entry);
         string str_deal_reason=EnumToString((ENUM_DEAL_REASON)deal_reason);
         long digits=5;
         if(deal_symbol!="" && deal_symbol!=NULL)
           {
            if(SymbolSelect(deal_symbol,true))
               digits=SymbolInfoInteger(deal_symbol,SYMBOL_DIGITS);
           }

         //---
         string text="";
         /*
         if(deal_magic==999)
         {
         text="Deal:";
         Print(deal_entry);
         Print(text);

         text=StringFormat("%-20s %-20s %-20s %-20s %-20s %-20s %-20s %-20s %-20s",
                           "|Ticket","|Order","|Time","|Time msc","|Type","|Entry","|Magic","|Reason","|Position ID");
         Print(text);
         text=StringFormat("|%-19d |%-19d |%-19s |%-19I64d |%-19s |%-19s |%-19d |%-19s |%-19d"
                           ,deal_ticket,deal_order,time,deal_time_msc,type,entry,deal_magic,str_deal_reason,deal_position_id);
         Print(text);

         text=StringFormat("%-20s %-20s %-20s %-20s %-20s %-20s %-41s %-20s",
                           "|Volume","|Price","|Commission","|Swap","|Profit","|Symbol","|Comment","|External ID");
         Print(text);
         text=StringFormat("|%-19.2f |%-19."+IntegerToString(digits)+"f |%-19.2f |%-19.2f |%-19.2f |%-19s |%-40s |%-19s",
                           deal_volume,deal_price,deal_commission,deal_swap,deal_profit,deal_symbol,deal_comment,deal_external_id);
         Print(text);
         theHistoryProfit=theHistoryProfit+deal_profit;

         }
         */
         //--- try to get oeders ticket_history_order
         if(HistoryOrderSelect(deal_order))
           {
            long     o_ticket          =HistoryOrderGetInteger(deal_order,ORDER_TICKET);
            long     o_time_setup      =HistoryOrderGetInteger(deal_order,ORDER_TIME_SETUP);
            long     o_type            =HistoryOrderGetInteger(deal_order,ORDER_TYPE);
            long     o_state           =HistoryOrderGetInteger(deal_order,ORDER_STATE);
            long     o_time_expiration =HistoryOrderGetInteger(deal_order,ORDER_TIME_EXPIRATION);
            long     o_time_done       =HistoryOrderGetInteger(deal_order,ORDER_TIME_DONE);
            long     o_time_setup_msc  =HistoryOrderGetInteger(deal_order,ORDER_TIME_SETUP_MSC);
            long     o_time_done_msc   =HistoryOrderGetInteger(deal_order,ORDER_TIME_DONE_MSC);
            long     o_type_filling    =HistoryOrderGetInteger(deal_order,ORDER_TYPE_FILLING);
            long     o_type_time       =HistoryOrderGetInteger(deal_order,ORDER_TYPE_TIME);
            long     o_magic           =HistoryOrderGetInteger(deal_order,ORDER_MAGIC);
            long     o_reason          =HistoryOrderGetInteger(deal_order,ORDER_REASON);
            long     o_position_id     =HistoryOrderGetInteger(deal_order,ORDER_POSITION_ID);
            long     o_position_by_id  =HistoryOrderGetInteger(deal_order,ORDER_POSITION_BY_ID);

            double   o_volume_initial  =HistoryOrderGetDouble(deal_order,ORDER_VOLUME_INITIAL);
            double   o_volume_current  =HistoryOrderGetDouble(deal_order,ORDER_VOLUME_CURRENT);
            double   o_open_price      =HistoryOrderGetDouble(deal_order,ORDER_PRICE_OPEN);
            double   o_sl              =HistoryOrderGetDouble(deal_order,ORDER_SL);
            double   o_tp              =HistoryOrderGetDouble(deal_order,ORDER_TP);
            double   o_price_current   =HistoryOrderGetDouble(deal_order,ORDER_PRICE_CURRENT);
            double   o_price_stoplimit =HistoryOrderGetDouble(deal_order,ORDER_PRICE_STOPLIMIT);

            //double   o_profit = HistoryOrderGetDouble(deal_order,ORDER);

            string   o_symbol          =HistoryOrderGetString(deal_order,ORDER_SYMBOL);
            string   o_comment         =HistoryOrderGetString(deal_order,ORDER_COMMENT);
            string   o_extarnal_id     =HistoryOrderGetString(deal_order,ORDER_EXTERNAL_ID);

            string str_o_time_setup       =TimeToString((datetime)o_time_setup,TIME_DATE|TIME_MINUTES|TIME_SECONDS);
            string str_o_type             =EnumToString((ENUM_ORDER_TYPE)o_type);
            string str_o_state            =EnumToString((ENUM_ORDER_STATE)o_state);
            string str_o_time_expiration  =TimeToString((datetime)o_time_expiration,TIME_DATE|TIME_MINUTES|TIME_SECONDS);
            string str_o_time_done        =TimeToString((datetime)o_time_done,TIME_DATE|TIME_MINUTES|TIME_SECONDS);
            string str_o_type_filling     =EnumToString((ENUM_ORDER_TYPE_FILLING)o_type_filling);
            string str_o_type_time        =TimeToString((datetime)o_type_time,TIME_DATE|TIME_MINUTES|TIME_SECONDS);
            string str_o_reason           =EnumToString((ENUM_ORDER_REASON)o_reason);

            text="Order:";
            //OutputTest(text);

            text=StringFormat("%-20s %-20s %-20s %-20s %-20s %-20s %-20s %-20s %-20s",
                              "|Ticket","|Time setup","|Type","|State","|Time expiration",
                              "|Time done","|Time setup msc","|Time done msc","|Type filling");
            //OutputTest(text);
            text=StringFormat("|%-19d |%-19s |%-19s |%-19s |%-19s |%-19s |%-19I64d |%-19I64d |%-19s",
                              o_ticket,str_o_time_setup,str_o_type,str_o_state,str_o_time_expiration,str_o_time_done,
                              o_time_setup_msc,o_time_done_msc,str_o_type_filling);
            //OutputTest(text);
            text=StringFormat("%-20s %-20s %-20s %-20s %-20s",
                              "|Type time","|Magic","|Reason","|Position id","|Position by id");
            //OutputTest(text);
            text=StringFormat("|%-19s |%-19d |%-19s |%-19d |%-19d",
                              str_o_type_time,o_magic,str_o_reason,o_position_id,o_position_by_id);
            //OutputTest(text);

            text=StringFormat("%-20s %-20s %-20s %-20s %-20s %-20s %-20s",
                              "|Volume initial","|Volume current","|Open price","|sl","|tp","|Price current","|Price stoplimit");
            //OutputTest(text);
            text=StringFormat("|%-19.2f |%-19.2f |%-19."+IntegerToString(digits)+"f |%-19."+IntegerToString(digits)+
                              "f |%-19."+IntegerToString(digits)+"f |%-19."+IntegerToString(digits)+
                              "f |%-19."+IntegerToString(digits)+"f",
                              o_volume_initial,o_volume_current,o_open_price,o_sl,o_tp,o_price_current,o_price_stoplimit);
            //OutputTest(text);
            text=StringFormat("%-20s %-41s %-20s","|Symbol","|Comment","|Extarnal id");
            //OutputTest(text);
            text=StringFormat("|%-19s |%-40s |%-19s",o_symbol,o_comment,o_extarnal_id);
            //OutputTest(text);

            int d=0;
           }
         else
           {
            text="Order "+IntegerToString(deal_order)+" is not found in the trade history between the dates "+
                 TimeToString(Get_history_from_date,TIME_DATE|TIME_MINUTES|TIME_SECONDS)+" and "+
                 TimeToString(Get_history_to_date,TIME_DATE|TIME_MINUTES|TIME_SECONDS);
            //OutputTest(text);
           }
         text="";
         //OutputTest(text);

         int d=0;
        }
     }
//---
   /*
   if(InpOutput==txt_file)
   FileClose(file_handle);
   */
//return(theHistoryProfit);
  }



//----------------------------------------------------------------------+
void Cizikle44(string name, string text, int xdistance,int ydistance)
  {

   long cid=ChartID();
   ResetLastError();
   ObjectDelete(cid,name);
   ObjectCreate(cid,name,OBJ_LABEL,0,0,0,0,0,0,0);
   ObjectSetString(cid,name,OBJPROP_TEXT,text);
   ObjectSetInteger(cid,name,OBJPROP_XDISTANCE,xdistance);
   ObjectSetInteger(cid,name,OBJPROP_YDISTANCE,ydistance);
   ObjectSetInteger(cid,name,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(cid,name,OBJPROP_COLOR,clrGold);
   ObjectSetInteger(cid,name,OBJPROP_FILL,clrBlack);
   ObjectSetInteger(cid,name,OBJPROP_FONTSIZE,15);
   ObjectSetInteger(cid,name,OBJPROP_WIDTH,8);

  }


//----------------------------------------------------------------------+
void Cizikle4(string name, string text, int xdistance,int ydistance)
  {

   long cid=ChartID();
   ResetLastError();
   ObjectDelete(cid,name);
   ObjectCreate(cid,name,OBJ_LABEL,0,0,0,0,0,0,0);
   ObjectSetString(cid,name,OBJPROP_TEXT,text);
   ObjectSetInteger(cid,name,OBJPROP_XDISTANCE,xdistance);
   ObjectSetInteger(cid,name,OBJPROP_YDISTANCE,ydistance);
   ObjectSetInteger(cid,name,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(cid,name,OBJPROP_COLOR,clrGold);
   ObjectSetInteger(cid,name,OBJPROP_FILL,clrBlack);
   ObjectSetInteger(cid,name,OBJPROP_FONTSIZE,15);
   ObjectSetInteger(cid,name,OBJPROP_WIDTH,8);

  }


//----------------------------------------------------------------------+
void Cizikle5(string name, string text, int xdistance,int ydistance)
  {

   long cid=ChartID();
   ResetLastError();
   ObjectDelete(cid,name);
   ObjectCreate(cid,name,OBJ_LABEL,0,0,0,0,0,0,0);
   ObjectSetString(cid,name,OBJPROP_TEXT,text);
   ObjectSetInteger(cid,name,OBJPROP_XDISTANCE,xdistance);
   ObjectSetInteger(cid,name,OBJPROP_YDISTANCE,ydistance);
   ObjectSetInteger(cid,name,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(cid,name,OBJPROP_COLOR,clrGold);
   ObjectSetInteger(cid,name,OBJPROP_FILL,clrBlack);
   ObjectSetInteger(cid,name,OBJPROP_FONTSIZE,8);
   ObjectSetInteger(cid,name,OBJPROP_WIDTH,4);

  }