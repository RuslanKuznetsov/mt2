//+------------------------------------------------------------------+
//|                                                          MT1.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"


#include <Trade\Trade.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\SymbolInfo.mqh>

input    double Lot          = 1; // Объем лота
input    double MinChannel   = 300; //Минимальная граница AB
input    double MaxChannel   = 800; //Максимальная граница AB
input    int    Slippage     = 10; //Проскальзывание
input    int    MagicNumber=443118; //Уникальный ID Советника (MagicNumber)
input string    TimeStart   = "10:01"; //Время начала работы советника
input string    TimeEnd     = "23:40"; //Время конца работы советника
input string    TimeOpen     = "22:00"; //Время открытия последней позиции
input double    Koeff       = 100;      //Отступ от цены (для трейлинга)
input double    Koeff2       = 100;      //Отступ от цены2 (для трейлинга)
input double    Koeff3       = 2;      //Отступ от цены2 (для трейлинга)
input double    Koeff4       = 4;      //Отступ от цены2 (для трейлинга)
input string    Trailing    = "Off";    //Трейлинг On/Off

int h;
bool UseTradePause;
bool stop1,stop2,stop3,stop4,stop5;
int eo_Bars,ExtHandle; 
double APoint,BPoint,CPoint,XPoint;
double PrevTick,Spread,stoploss;
//ulong ticket;
bool OpenLongPosition,OpenSellPosition,WinPos;
int breakABar,globalBar,ABar;
MqlDateTime dt_struct;
MqlTick Latest_Price; // Structure to get the latest prices
CSymbolInfo symbol_info;
int trailcount,losecount,wincount;
double GlobalBalance;

CTrade trade;
CPositionInfo myposition;
CAccountInfo account;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   UseTradePause=true;
   trailcount=0;
  //--- объект для работы со счетом

//--- получим номер счета, на котором запущен советник
   long login=account.Login();
   Print("Login=",login);
//--- выясним тип счета
   ENUM_ACCOUNT_TRADE_MODE account_type=account.TradeMode();
//--- если счет оказался реальным, прекращаем работу эксперта немедленно!

//--- выведем тип счета    
   Print("Тип счета: ",EnumToString(account_type));
//--- выясним, можно ли вообще торговать на данном счете
   if(account.TradeAllowed())
      Print("Торговля на данном счете разрешена");
   else
      Print("Торговля на счете запрещена: возможно, вход был совершен по инвест-паролю");
//--- выясним, разрешено ли торговать на счете с помощью эксперта
   if(account.TradeExpert())
      Print("Автоматическая торговля на счете разрешена");
   else
      Print("Запрещена автоматическая торговля с помощью экспертов и скриптов");
//--- допустимое количество ордеров задано или нет
   int orders_limit=account.LimitOrders();
   if(orders_limit!=0)Print("Максимально допустимое количество действующих отложенных ордеров: ",orders_limit);
//--- выведем имя компании и сервера
   Print(account.Company(),": server ",account.Server());
//--- напоследок выведем баланс и текущую прибыль на счете
   Print("Balance=",account.Balance(),"  Profit=",account.Profit(),"   Equity=",account.Equity());
   Print(__FUNCTION__,"  completed"); //---

   OpenLongPosition=false;
 //  h=FileOpen("ForIgor.txt",FILE_WRITE|FILE_ANSI|FILE_TXT);
 trade.SetDeviationInPoints(Slippage);
//--- режим заполнения ордера, нужно использовать тот режим, который разрешается сервером
   trade.SetTypeFilling(ORDER_FILLING_RETURN);
//--- режим логирования: лучше не вызывать этот метод вообще, класс сам выставит оптимальный режим
   trade.LogLevel(1); 
//--- какую функцию использовать для торговли: true - OrderSendAsync(), false - OrderSend()
   trade.SetAsyncMode(true);
//---
   if(h==INVALID_HANDLE){
      Alert("Ошибка открытия файла");
   }

/*   
   if (_Digits == 3 || _Digits == 5)
   {

   }   
*/   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//   FileClose(h);
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void iLow321(datetime StartPauseTime)
{
      
  SymbolInfoTick(Symbol(),Latest_Price);
   globalBar  = iBars(NULL,0);

   
   int shift3 = 3;
   int shift2 = 2;
   int shift1 = 1;
   int i,k,z,n;
   bool flag;
   double ALowTemp1,ALowTemp2,ALowTemp3;

   datetime time3  = iTime(Symbol(),Period(),shift3); 
   double   open3  = iOpen(Symbol(),Period(),shift3); 
   double   high3  = iHigh(Symbol(),Period(),shift3); 
   double   low3   = iLow(Symbol(),Period(),shift3); 
   double   close3 = iClose(NULL,PERIOD_CURRENT,shift3); 
   long     volume3= iVolume(Symbol(),0,shift3); 
   int      bars3  = iBars(NULL,0); 
   
   datetime time2  = iTime(Symbol(),Period(),shift2); 
   double   open2  = iOpen(Symbol(),Period(),shift2); 
   double   high2  = iHigh(Symbol(),Period(),shift2); 
   double   low2   = iLow(Symbol(),Period(),shift2); 
   double   close2 = iClose(NULL,PERIOD_CURRENT,shift2); 
   long     volume2= iVolume(Symbol(),0,shift2); 
   int      bars2  = iBars(NULL,0); 
   
   datetime time1  = iTime(Symbol(),Period(),shift1); 
   double   open1  = iOpen(Symbol(),Period(),shift1); 
   double   high1  = iHigh(Symbol(),Period(),shift1); 
   double   low1   = iLow(Symbol(),Period(),shift1); 
   double   close1 = iClose(NULL,PERIOD_CURRENT,shift1); 
   long     volume1= iVolume(Symbol(),0,shift1); 
   int      bars1  = iBars(NULL,0); 

if (low2==low3)
{
 for(n=3;n<50;n++)
 {
  low3   = iLow(Symbol(),Period(),shift3+n); 
  if(low3!=low2) break;
 }
}        

  if (GlobalBalance!=AccountInfoDouble(ACCOUNT_BALANCE))
  {
   if (GlobalBalance<AccountInfoDouble(ACCOUNT_BALANCE)) {WinPos = true;losecount=0;wincount++;}
   if (GlobalBalance>AccountInfoDouble(ACCOUNT_BALANCE)) {WinPos = false;losecount++;wincount=0;}
   GlobalBalance=AccountInfoDouble(ACCOUNT_BALANCE);
  }


  
//   Comment(DoubleToString(low1)+"\n"+DoubleToString(low2)+"\n"+DoubleToString(low3)+"\n");
   //Формируем точку А,

   if (OrdersTotal()==0 && PositionsTotal()==0 && OpenLongPosition==true) {OpenLongPosition=false;APoint=0;BPoint=0;CPoint=0;PrevTick=0;breakABar=globalBar+3;stop2=false;stop3=false;stop4=false;}
   if (PositionsTotal()==0 && OrdersTotal()>0) {OpenLongPosition=false;}
   if (PositionsTotal()!=0)
   {
      if (CPoint>Latest_Price.last) CPoint=Latest_Price.last;
//      Print("CPoint:"+CPoint);
   }
   if (PositionsTotal()>0 && OpenLongPosition==false) {OpenLongPosition=true;CPoint=Latest_Price.last;}

   if (OpenLongPosition==false && low2<low1 && low2<low3 && APoint==0 && BPoint==0 && XPoint==0 && StartPauseTime<=time3 && breakABar<globalBar) 
   {
      APoint=low2;PrevTick=Latest_Price.last;
      ABar=globalBar;
      Print("APoint:"+low2);
      return;
     
   }   
   else if (OpenLongPosition==false && Latest_Price.last<APoint && APoint!=0) 
   {
      APoint=0;breakABar=globalBar;Print("Break APoint:"+Latest_Price.last);PrevTick=Latest_Price.last;return;
   }else if (OpenLongPosition==false && APoint!=0 && BPoint==0 && Latest_Price.last>APoint && (Latest_Price.last-APoint)>=MinChannel && (Latest_Price.last-APoint)<MaxChannel ) 
   {
      if (OrdersTotal()>0 && PositionsTotal()==0) delete_all_limit_orders();
      BPoint=Latest_Price.last;
      Print("BPoint:"+BPoint);
      return;
   }else if (OpenLongPosition==false && BPoint!=0 && Latest_Price.last>=BPoint && (Latest_Price.last-APoint)>=MinChannel && (Latest_Price.last-APoint)<=MaxChannel)
   {
      if (OrdersTotal()>0 && PositionsTotal()==0) delete_all_limit_orders();
      BPoint=Latest_Price.last;
      Print("BPoint:"+BPoint+"    ABar:"+ABar);
      return;    
   }
   else if (OpenLongPosition==false && APoint!=0 && BPoint!=0 && Latest_Price.last>BPoint && (Latest_Price.last-APoint)>=MaxChannel) 
   {
      if (OrdersTotal()>0 && PositionsTotal()==0) delete_all_limit_orders();
      if ((globalBar-ABar)<3)
      {
       init_params();return;
      }else
      {
       k=ABar;
       z=globalBar-ABar;  
       for(i=z;i>=2;i--)
       {
         ALowTemp3   = iLow(Symbol(),Period(),i-2); 
         ALowTemp2   = iLow(Symbol(),Period(),i-1); 
         ALowTemp1   = iLow(Symbol(),Period(),i);
         
         if (ALowTemp2==ALowTemp3)
         {
          for(n=3;n<50;n++)
          {
             ALowTemp3   = iLow(Symbol(),Period(),i-n); 
             if(ALowTemp3!=ALowTemp2) break;
          }
         }
         
         if (ALowTemp2<ALowTemp1 && ALowTemp2<ALowTemp3 && APoint<ALowTemp2) 
         {
            APoint=ALowTemp2;    
            PrevTick=Latest_Price.last;
            ABar=k+z-i+1;BPoint=Latest_Price.last;
            Print("New! APoint:"+APoint+"   New BPoint:"+BPoint+"    ABar:"+ABar+"     ABSpread:"+(BPoint-APoint));
            Print("ALowTemp1:"+ALowTemp1+"  ALowTemp2:"+ALowTemp2+"  ALowTemp3:"+ALowTemp3);
            return;
         }         
       }         
      }
     }
     else if (OrdersTotal()==0 && PositionsTotal()==0 && APoint!=0 && BPoint!=0 && Latest_Price.last<(BPoint-0.5*(BPoint-APoint)) && OpenLongPosition==false)
     {
      if (OrdersTotal()>0 && PositionsTotal()==0) delete_all_limit_orders();
      BuySLTP(CountLots(),Symbol(),BPoint-0.618*(BPoint-APoint)+Slippage,APoint,4*BPoint);
      Print("APoint:"+APoint+"   BPoint:"+BPoint+"    !!!Заявка на покупку по цене: "+DoubleToString((BPoint-0.618*(BPoint-APoint)+Slippage)));
      OpenLongPosition=true;
     }
     if (OpenLongPosition==true && Latest_Price.last>=(BPoint-0.382*(BPoint-APoint)) && stop2==false)
     {
      ChangeSL(BPoint-0.882*(BPoint-APoint),2*BPoint);
      stop2=true;
     }else if (OpenLongPosition==true && Latest_Price.last>=(BPoint-0.236*(BPoint-APoint)) && stop3==false)
     {
      ChangeSL(BPoint-0.786*(BPoint-APoint),2*BPoint);
      stop3=true;
     }else if (OpenLongPosition==true && Latest_Price.last>=BPoint && stop4==false)
     {
//      ChangeSL(BPoint-0.618*(BPoint-APoint)+2*Slippage,0);
        ChangeSL(BPoint-0.618*(BPoint-APoint)+2*Slippage,CPoint+1.618*(BPoint-CPoint));
//        ChangeSL(BPoint-0.618*(BPoint-APoint)+2*Slippage,4*BPoint);
//      SellSLTP(Lot,Symbol(),CPoint+1.272*(BPoint-CPoint),0,0);
        stop4=true;
        stoploss=BPoint-0.618*(BPoint-APoint)+2*Slippage;
        }
/*     }else if (OpenLongPosition==true && Latest_Price.last>=BPoint && stop4==true && Latest_Price.last>=CPoint+1.618*(BPoint-CPoint) && stop5==false)
     {
//      ChangeSL(BPoint-0.618*(BPoint-APoint)+2*Slippage,0);
//      ChangeSL(BPoint-0.618*(BPoint-APoint)+2*Slippage,CPoint+1.272*(BPoint-CPoint));
//        ChangeSL(CPoint+1.272*(BPoint-CPoint)-Koeff2,4*BPoint);
        ChangeSL(Latest_Price.last-Koeff,4*BPoint);
//      SellSLTP(Lot,Symbol(),CPoint+1.272*(BPoint-CPoint),0,0);
        stoploss=Latest_Price.last-Koeff; 
        stop5=true;
     }
*/
/*     else if (OpenLongPosition==true && Latest_Price.last>=BPoint && stop5==true && Latest_Price.last-stoploss>Koeff)
     {
//      ChangeSL(BPoint-0.618*(BPoint-APoint)+2*Slippage,0);
//      ChangeSL(BPoint-0.618*(BPoint-APoint)+2*Slippage,CPoint+1.272*(BPoint-CPoint));
        ChangeSL(Latest_Price.last-Koeff,4*BPoint);
//      SellSLTP(Lot,Symbol(),CPoint+1.272*(BPoint-CPoint),0,0);
        stoploss=Latest_Price.last-Koeff; 
     }
 */
     
   
/*   if (APoint!=0 && BPoint!=0 && XPoint==0) BPoint=Latest_Price.last;
   //Точка X еще не определена ни разу
   Spread=BPoint-APoint;
   if (Spread<0) {APoint=0;BPoint=0;XPoint=0;Spread=0;}
   if (APoint!=0 && BPoint!=0 && XPoint==0 && Spread>MinChannel && Latest_Price.last<PrevTick) XPoint=Latest_Price.last;
   if (XPoint!=0 && Latest_Price.last<BPoint) XPoint=Latest_Price.last;
   if (XPoint!=0 && Latest_Price.last>BPoint) {XPoint=0;BPoint=Latest_Price.last;}
   if (XPoint!=0 && XPoint<=(BPoint-0.5*Spread))  {
      FileWrite(h,"Заявка на покупку по цене: "+DoubleToString((APoint+0.618*Spread+Slippage)));
      BuySLTP(Lot,Symbol(),APoint+0.618*Spread+Slippage,APoint,3000);
      OpenLongPosition=true;
   }
*/
 //  FileWrite(h,TimeCurrent()+"     APoint:"+DoubleToString(APoint)+" BPoint:"+DoubleToString(BPoint)+" Spread:"+DoubleToString(BPoint-APoint)+" XPoint:"+DoubleToString(XPoint));
   PrevTick=Latest_Price.last;   
}

void OnTick()
  {
  datetime StartPause,EndPause;
  StartPause = StringToTime(TimeStart);  
  EndPause   = StringToTime(TimeEnd); 
if((UseTradePause && (StartPause < EndPause) && (TimeCurrent() < StartPause ||  TimeCurrent() > EndPause)))
{
            if (OrdersTotal()!=0) delete_all_limit_orders();
            if (PositionsTotal()!=0) delete_all_positions();
            init_params();
            Comment("Пауза в работе советника");
            return;
} else if((UseTradePause && (StartPause > EndPause) && (TimeCurrent() < StartPause &&  TimeCurrent() > EndPause)))
{
            if (OrdersTotal()!=0) delete_all_limit_orders();
            if (PositionsTotal()!=0) delete_all_positions();
            init_params();
            Comment("Пауза в работе советника");
            return;
} else 
{
   Comment("Советник работает, открытых заявок: "+OrdersTotal()+"\nСоветник работает, открытых сделок: "+PositionsTotal()+"\nТочка А: "+APoint+"\nТочка B: "+BPoint+"\nТочка С: "+CPoint+"\nBalance: "+AccountInfoDouble(ACCOUNT_BALANCE));
   iLow321(StartPause);
}

/*  if (minCountPrev==0) 
  { 
   minCountPrev++;
  } else if (minCountPrev>0)
  {
   if ((dt_struct.min>minCount) || (dt_struct.min==0 && minCount==59)) minCount++; 
  }
*/


  }



/*void BuySLTP(double volume, double bidprice,string symbol, double SL,double TP)
{

//--- 3. пример покупки по указанному символу символу с заданными SL и TP
   double point=SymbolInfoDouble(symbol,SYMBOL_POINT);         // пункт
   double bid=SymbolInfoDouble(symbol,SYMBOL_BID);             // текущая цена для закрытия LONG
   int    digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS); // количество знаков после запятой
   double SL1=NormalizeDouble(SL,digits);                              // нормализуем Stop Loss
   double TP1=NormalizeDouble(TP,digits);                              // нормализуем Take Profit
//--- получим текущую цену открытия для LONG позиций
   double open_price=NormalizeDouble(bidprice,digits);                             
   if(!trade.BuyLimit(volume,open_price,symbol,SL1,TP1,ORDER_TIME_DAY,0,""))
     {
      //--- сообщим о неудаче
      Print("Метод Buy() потерпел неудачу. Код возврата=",trade.ResultRetcode(),
            ". Описание кода: ",trade.ResultRetcodeDescription());
     }
   else
     {
      Print("Метод Buy() выполнен успешно. Код возврата=",trade.ResultRetcode(),
            " (",trade.ResultRetcodeDescription(),")");
     }
}
*/
  
  
void BuySLTP(double volume, string symbol,double bidprice,double SL,double TP)
{
  datetime TimeOpen2;
  TimeOpen2 = StringToTime(TimeOpen);  

//--- 3. пример покупки по указанному символу символу с заданными SL и TP
   double point=SymbolInfoDouble(symbol,SYMBOL_POINT);         // пункт
   double bid=SymbolInfoDouble(symbol,SYMBOL_BID);             // текущая цена для закрытия LONG
   int    digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS); // количество знаков после запятой
   double SL1=NormalizeDouble(SL,digits);                              // нормализуем Stop Loss
   double TP1=NormalizeDouble(TP,digits);                              // нормализуем Take Profit
//--- получим текущую цену открытия для LONG позиций
   double open_price=NormalizeDouble(bidprice,digits);

   if (TimeCurrent() < TimeOpen2)
   {
     Print(TimeCurrent());
     Print(TimeOpen);
//   if(!trade.Buy(volume,symbol,NormPrice(open_price),NormPrice(SL1),NormPrice(TP1),""))
      if(!trade.BuyLimit(volume,NormPrice(open_price),Symbol(),NormPrice(SL1),NormPrice(TP1),ORDER_TIME_DAY,TimeCurrent()+60*60,""))  
      {
      //--- сообщим о неудаче
         Print("Метод Buy() потерпел неудачу. Код возврата=",trade.ResultRetcode(),
               ". Описание кода: ",trade.ResultRetcodeDescription());
      }
      else
      {
         Print("Метод Buy() выполнен успешно. Код возврата=",trade.ResultRetcode(),
               " (",trade.ResultRetcodeDescription(),")");
      }
    }else Print("Сделка не может быть открыта после: "+TimeOpen);
}

void SellSLTP(double volume, string symbol,double bidprice,double SL,double TP)
{
  datetime TimeOpen2;
  TimeOpen2 = StringToTime(TimeOpen);  

//--- 3. пример покупки по указанному символу символу с заданными SL и TP
   double point=SymbolInfoDouble(symbol,SYMBOL_POINT);         // пункт
   double bid=SymbolInfoDouble(symbol,SYMBOL_BID);             // текущая цена для закрытия LONG
   int    digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS); // количество знаков после запятой
   double SL1=NormalizeDouble(SL,digits);                              // нормализуем Stop Loss
   double TP1=NormalizeDouble(TP,digits);                              // нормализуем Take Profit
//--- получим текущую цену открытия для LONG позиций
   double open_price=NormalizeDouble(bidprice,digits);

   if (TimeCurrent() < TimeOpen2)
   {
     Print(TimeCurrent());
     Print(TimeOpen);
//   if(!trade.Buy(volume,symbol,NormPrice(open_price),NormPrice(SL1),NormPrice(TP1),""))
      if(!trade.SellLimit(volume,NormPrice(open_price),Symbol(),NormPrice(SL1),NormPrice(TP1),ORDER_TIME_DAY,TimeCurrent()+60*60,""))  
      {
      //--- сообщим о неудаче
         Print("Метод Sell() потерпел неудачу. Код возврата=",trade.ResultRetcode(),
               ". Описание кода: ",trade.ResultRetcodeDescription());
      }
      else
      {
         Print("Метод Sell() выполнен успешно. Код возврата=",trade.ResultRetcode(),
               " (",trade.ResultRetcodeDescription(),")");
      }
    }else Print("Сделка не может быть открыта после: "+TimeOpen);
}



//+------------------------------------------------------------------+

void ChangeSL2(double stoploss,double takeprofit)
  {
   if(PositionsTotal()!=0)//проверка наличия открытых ордеров
   for(int i = PositionsTotal(); i >=0; i--) //ищем последний открытый ордер
     if(PositionSelectByTicket(i))
        if(trade.RequestMagic() == MagicNumber)//если используется магик
         {       
          trade.PositionModify(PositionSelect(_Symbol),NormPrice(stoploss),NormPrice(takeprofit));
          if(GetLastError()==0)
            Print("Уровень стоп-лосс и тейк-профит модифицированы: ", "стоп-лосс: ", stoploss, "тейк-профит: ", takeprofit);
         }
         Print(GetLastError());
  }
void ChangeSL(double stoploss,double takeprofit)
  {
        if(!trade.PositionModify(_Symbol, NormPrice(stoploss),NormPrice(takeprofit)))
        {
           Alert("Ошибка изменения позиции:",GetLastError(),"!!");
           return;
        }
  }



double NormPrice(double Price)
{
int point;
double ostatok,ostatok2,newprice;
point=SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_SIZE);
 
ostatok=MathMod(Price,point);
if (ostatok>=point/2) 
   {
      ostatok2=point;
   }else ostatok2=0;
newprice=Price-ostatok+ostatok2;
return newprice;
}


bool OpenLongPosition22()
{
bool res;
res = false;
if (OrdersTotal()==0 && PositionsTotal()>0) res = true;
return res;
}

void delete_all_limit_orders()
{
   int orders=OrdersTotal();
   for(int i=0;i<=orders;i++)
   {
      ulong ticket=OrderGetTicket(i);
      if(ticket!=0)
      {
         if(OrderSelect(ticket))
         trade.OrderDelete(ticket);
         i--;
         Sleep(40);
      }
      }
}

void delete_all_positions2()
{

   int positions=PositionsTotal();
   for(int i=0;i<=positions;i++)
   {
      ulong ticket=PositionGetTicket(i);
      if(ticket!=0)
      {
         if(PositionSelect(ticket))
         trade.PositionClose(ticket,-1);
         i--;
      }
    }
}

void init_params()
{

APoint=0;
BPoint=0;
CPoint=0;
OpenLongPosition=false;
stop1=false;
stop2=false;
stop3=false;
stop4=false;
stop5=false;
trailcount=0;
PrevTick=0;
breakABar=0;
}

int CountLots()
{
double price;
int newprice;
price=AccountInfoDouble(ACCOUNT_BALANCE);
newprice=price/28500;
return newprice;
}

int MartinGaleCountLots()
{
int newtrail;
if (trailcount==0) {trailcount=1;}
newtrail=trailcount;
if (losecount>=2) trailcount=MathRound(newtrail*Koeff3);
if (wincount>=2) trailcount=MathRound(newtrail/Koeff4);
if (trailcount==0) {trailcount=CountLots()/2;}
return trailcount;
}



void delete_all_positions()
  {
   int count;

   ulong ticket;
   count=PositionsTotal();
   while (count > 0)
   {
      for(int i=0; i<count; i++)
      {
         if ((ticket = PositionGetTicket(i)) > 0) 
            trade.PositionClose(ticket);
            count=PositionsTotal();
      }
   }

  }
  
