//+------------------------------------------------------------------+
//|                                             auto-trading-bot.mq5 |
//|                           Copyright 2018-2019, Umair Khan Jadoon |
//|                                        https://www.merrycode.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018-2019, Umair Khan Jadoon"
#property link      "https://www.merrycode.com"
#property version   "1.00"
//--- input parameters
input double      default_stop_loss;
input double      default_pips;
input double candleStickPatternBidAmount;
input double candleStickPatternTP;
input double candleStickPatternBidSL;

#include<Trade\Trade.mqh>
#include<candlesticktype.mqh>
#import "indicator_functions.mq5"

bool candleStickIndicate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[], double candle_stick_bid, double candle_stick_tp, double candle_stick_sl, double ask);
#import 
CTrade trade;

#property indicator_chart_window

//--- plot 1
#property indicator_label1  ""
#property indicator_type1   DRAW_LINE
#property indicator_color1  Blue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
#property indicator_buffers 5
#property indicator_plots   1
//--- input parameters
input int   InpPeriodSMA   =10;         // Period of averaging
input bool  InpAlert       =true;       // Enable. signal
input int   InpCountBars   =1000;       // Amount of bars for calculation
input color InpColorBull   =DodgerBlue; // Color of bullish models
input color InpColorBear   =Tomato;     // Color of bearish models
input bool  InpCommentOn   =true;       // Enable comment
input int   InpTextFontSize=10;         // Font size
//---- indicator buffers
//--- indicator handles
//--- list global variable
string prefix="Patterns ";
datetime CurTime=0;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
  double candle_stick_bid = 1.0;
  double candle_stick_tp = 100;
  double candle_stick_sl = 500;
  double ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK),_Digits);
  
  candleStickIndicate(rates_total,
                prev_calculated,
                time,
                open,
                high,
                low,
                close,
                tick_volume,
                volume,
                spread, candle_stick_bid, candle_stick_tp, candle_stick_sl, ask);
  
  return(0);
  }
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   
  }
 
  
  
  /*
  
  void OpenBuyOrder()
  {
    MqlTradeRequest myRequest;
    MqlTradeResult myResult;
    
    myRequest.action = TRADE_ACTION_DEAL;
    myRequest.type = ORDER_TYPE_BUY;
    myRequest.symbol = _Symbol;
    myRequest.volume = default_pips;
    myRequest.type_filling = ORDER_FILLING_FOK;
    myRequest.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    myRequest.tp = 50;
    myRequest.sl = 0;
    myRequest.deviation = 50;
    OrderSend(myRequest,myResult);   
    
  }
   void OpenSellOrder(double Ask)
  {
    MqlTradeRequest myRequest;
    MqlTradeResult myResult;
    
    
    
    myRequest.action = TRADE_ACTION_DEAL;
    myRequest.type = ORDER_TYPE_SELL;
    myRequest.symbol = _Symbol;
    myRequest.volume = default_pips;
    myRequest.type_filling = ORDER_FILLING_FOK;
    myRequest.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    myRequest.tp = (_Point * 30) + Ask ;
    myRequest.sl = 0;
    myRequest.deviation = 50;
    OrderSend(myRequest,myResult);   
    
  }
  */
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   double ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK),_Digits);
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   
   //Create arrays for several prices
   
   double myMovingAverageArray1[], myMovingAverageArray2[];
   
   //define the properties of the Moving Average 1
   int movingAverageDefination1 = iMA(_Symbol, _Period, 20, 0, MODE_EMA, PRICE_CLOSE);
   
   //define the properties of the Moving Average 2
   int movingAverageDefination2 = iMA(_Symbol, _Period, 50, 0, MODE_EMA, PRICE_CLOSE);
   
   //Sorting the price array 1 for the current candle downwards
   ArraySetAsSeries(myMovingAverageArray1, true);
   
   //Sorting the price array 2 for the current candle downwards
   ArraySetAsSeries(myMovingAverageArray2, true);
   
   //Defined MA1, one line, current candle, 3 candles, store result
   CopyBuffer(movingAverageDefination1,0,0,3,myMovingAverageArray1);
   
   //Defined MA2, one line, current candle, 3 candles, store result
   CopyBuffer(movingAverageDefination2,0,0,3,myMovingAverageArray2);
   
   //Check if the 20 candle EA is above the 50 candle EA
   if( (myMovingAverageArray1[0] > myMovingAverageArray2[0]) 
   && ( myMovingAverageArray1[1] < myMovingAverageArray2[1]) )
   {
      
      //trade.Buy(0.01,_Symbol,ask,(ask - 100 * _Point),(ask + 1000 * _Point),"Initiating Buy");
      
      Print("BUY!!!!!");
      
      
   }
   
   //Check if the 50 candle EA is above the 50 candle EA
   if( (myMovingAverageArray1[0] < myMovingAverageArray2[0]) 
   && ( myMovingAverageArray1[1] > myMovingAverageArray2[1]) )
   {
      trade.Sell(0.01,_Symbol,ask,(ask - 100 * _Point),(ask + 1000 * _Point),"Initiating SELL");
      
       //Print("SELL!!!!!");
   }
   
   
   
   
  } //End of onTick()
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+
//| TesterInit function                                              |
//+------------------------------------------------------------------+
void OnTesterInit()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| TesterPass function                                              |
//+------------------------------------------------------------------+
void OnTesterPass()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| TesterDeinit function                                            |
//+------------------------------------------------------------------+
void OnTesterDeinit()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| BookEvent function                                               |
//+------------------------------------------------------------------+
void OnBookEvent(const string &symbol)
  {
//---
   
  }
//+------------------------------------------------------------------+
