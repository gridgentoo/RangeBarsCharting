//+------------------------------------------------------------------+
//|                                                          ATR.mq5 |
//|                   Copyright 2009-2017, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "2009-2017, MetaQuotes Software Corp."
#property link        "http://www.mql5.com"
#property description "Average True Range"
//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  DodgerBlue
#property indicator_label1  "ATR"
//--- input parameters
input int InpAtrPeriod=14;  // ATR period
//--- indicator buffers
double    ExtATRBuffer[];
double    ExtTRBuffer[];
//--- global variable
int       ExtPeriodATR;

//
//
//

#include <AZ-INVEST/SDK/RangeBarIndicator.mqh>
RangeBarIndicator rangeBarsIndicator;

//
//
//

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- check for input value
   if(InpAtrPeriod<=0)
     {
      ExtPeriodATR=14;
      printf("Incorrect input parameter InpAtrPeriod = %d. Indicator will use value %d for calculations.",InpAtrPeriod,ExtPeriodATR);
     }
   else ExtPeriodATR=InpAtrPeriod;
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtATRBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtTRBuffer,INDICATOR_CALCULATIONS);
//---
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,InpAtrPeriod);
//--- name for DataWindow and indicator subwindow label
   string short_name="ATR("+string(ExtPeriodATR)+")";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
   PlotIndexSetString(0,PLOT_LABEL,short_name);
//--- initialization done
  }
//+------------------------------------------------------------------+
//| Average True Range                                               |
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
   //
   // Process data through MedianRenko indicator
   //
   
   if(!rangeBarsIndicator.OnCalculate(rates_total,prev_calculated,time))
      return(0);
   
   //
   // Make the following modifications in the code below:
   //
   // rangeBarsIndicator.GetPrevCalculated() should be used instead of prev_calculated
   //
   // rangeBarsIndicator.Open[] should be used instead of open[]
   // rangeBarsIndicator.Low[] should be used instead of low[]
   // rangeBarsIndicator.High[] should be used instead of high[]
   // rangeBarsIndicator.Close[] should be used instead of close[]
   //
   // rangeBarsIndicator.IsNewBar (true/false) informs you if a renko brick completed
   //
   // rangeBarsIndicator.Time[] shold be used instead of Time[] for checking the renko bar time.
   // (!) rangeBarsIndicator.SetGetTimeFlag() must be called in OnInit() for rangeBarsIndicator.Time[] to be used
   //
   // rangeBarsIndicator.Tick_volume[] should be used instead of TickVolume[]
   // rangeBarsIndicator.Real_volume[] should be used instead of Volume[]
   // (!) rangeBarsIndicator.SetGetVolumesFlag() must be called in OnInit() for Tick_volume[] & Real_volume[] to be used
   //
   // rangeBarsIndicator.Price[] should be used instead of Price[]
   // (!) rangeBarsIndicator.SetUseAppliedPriceFlag(ENUM_APPLIED_PRICE _applied_price) must be called in OnInit() for rangeBarsIndicator.Price[] to be used
   //
   
   int _prev_calculated = rangeBarsIndicator.GetPrevCalculated();
   
   //
   //
   //  
  
   int i,limit;
//--- check for bars count
   if(rates_total<=ExtPeriodATR)
      return(0); // not enough bars for calculation
//--- preliminary calculations
   if(_prev_calculated==0)
     {
      ExtTRBuffer[0]=0.0;
      ExtATRBuffer[0]=0.0;
      //--- filling out the array of True Range values for each period
      for(i=1;i<rates_total && !IsStopped();i++)
         ExtTRBuffer[i]=MathMax(rangeBarsIndicator.High[i],rangeBarsIndicator.Close[i-1])-MathMin(rangeBarsIndicator.Low[i],rangeBarsIndicator.Close[i-1]);
      //--- first AtrPeriod values of the indicator are not calculated
      double firstValue=0.0;
      for(i=1;i<=ExtPeriodATR;i++)
        {
         ExtATRBuffer[i]=0.0;
         firstValue+=ExtTRBuffer[i];
        }
      //--- calculating the first value of the indicator
      firstValue/=ExtPeriodATR;
      ExtATRBuffer[ExtPeriodATR]=firstValue;
      limit=ExtPeriodATR+1;
     }
   else limit=_prev_calculated-1;
//--- the main loop of calculations
   for(i=limit;i<rates_total && !IsStopped();i++)
     {
      ExtTRBuffer[i]=MathMax(rangeBarsIndicator.High[i],rangeBarsIndicator.Close[i-1])-MathMin(rangeBarsIndicator.Low[i],rangeBarsIndicator.Close[i-1]);
      ExtATRBuffer[i]=ExtATRBuffer[i-1]+(ExtTRBuffer[i]-ExtTRBuffer[i-ExtPeriodATR])/ExtPeriodATR;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
