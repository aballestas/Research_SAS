/*SAS Code by: Anthony Ballestas*/
/*All World Bank data unless stated otherwise*/
PROC IMPORT DATAFILE="/home/u42330852/Data STA3024/(Test)Global Findex Database.xlsx"
		    OUT=Findex
		    DBMS=XLSX
		    REPLACE;
RUN;/** Import an XLSX file.  **/

/*(%trade of GDP)*/
PROC IMPORT DATAFILE="/home/u42330852/Data STA3024/Trade Openness .xlsx"
		    OUT=WBTrade
		    DBMS=XLSX
		    REPLACE;
RUN;


/*GDP per capita data*/
PROC IMPORT DATAFILE="/home/u42330852/Data STA3024/GDP Per Cap data .xlsx"
		    OUT=WBCap
		    DBMS=XLSX
		    REPLACE;
RUN;

/*Population data*/
PROC IMPORT DATAFILE="/home/u42330852/Data STA3024/WB Population.xlsx"
		    OUT=WBPop
		    DBMS=XLSX
		    REPLACE;
RUN;

/*Area in Km squared*/
PROC IMPORT DATAFILE="/home/u42330852/Data STA3024/WB Area.xlsx"
		    OUT=WBArea
		    DBMS=XLSX
		    REPLACE;
RUN;

/*Heritage Institute - Index of Economic Freedom 2017*/
/** https://www.heritage.org/index/trade-freedom  **/
PROC IMPORT DATAFILE="/home/u42330852/Data STA3024/Fredom_index2017_data.xlsx"
		    OUT=Freedom
		    DBMS=XLSX
		    REPLACE;
RUN;





/*Cleaning the data*/
data strip; 
	set Findex; 
	"Country Name"n = put("C"n, 50.);
	keep "Financial institution account (%"n "Country Name"n; 
	where "A"n = 2017;
run;
data strip2; 
	set WBTrade;
	"Trade %GDP"n = input ("2017"n, 8.);
	keep "Country Name"n "Trade %GDP"n;
run; 
data strip3; 
	set WBCap;
	"GDP per Capita"n = input("2017"n , 8.);
	Label "GDP per Capita"n = "GDP/Capita";
	keep "Country Name"n "GDP per Capita"n;
run; 
data strip4; 
	set WBPop;
	"WBPopulation"n = input("2017"n , 8.);
	Label "WBPopulation"n = "Population in 2017 (in thousands)";
	keep "Country Name"n "WBPopulation"n;
run; 
data strip5; 
	set WBArea;
	"WBArea"n = input("2017"n , 8.);
	Label "WBArea"n = "Surface area (sq. km)";
	keep "Country Name"n "WBArea"n;
run; 
data strip6; 
	set Freedom;
	"Trade Policy"n =  input("Trade Freedom"n , 8.);
	Label "Trade Policy"n = "measure tariff and non-tariff barriers";
	keep "Country Name"n "Trade Policy"n;
	if "Country Name"n = "" then delete;
run; 




/*sort the two data sets before merging*/
proc sort data= strip; 
by "Country Name"n ;
run;
proc sort data= Strip2;
by "Country Name"n;
run;
proc sort data= Strip3;
by "Country Name"n;
run;
proc sort data= Strip4;
by "Country Name"n;
run;
proc sort data= Strip5;
by "Country Name"n;
run;
proc sort data= Strip6;
by "Country Name"n;
run;



/*Merging the two data sets*/
data Margs; 
	set  strip strip2 strip3 strip4 strip5 strip6; 
	merge  strip strip2 strip3 strip4 strip5 strip6;
	by "Country Name"n;	
	if 'Financial institution account (%'n = . then delete; 
	if 'Trade Policy'n = . then delete;
run;

proc print data=margs;

data logT; 
set margs; 
"Financial institution account (%"n = log("Financial institution account (%"n);
"Trade %GDP"n = log("Trade %GDP"n);
"GDP per Capita"n = log("GDP per Capita"n);
"WBArea"n = log("WBArea"n);
"Trade Policy"n = ("Trade Policy"n);
run; 

	



/*Create the scatter plot*/
proc sgplot data= margs;
	scatter y = "Trade %GDP"n
			x = "Financial institution account (%"n;
	reg 	y = "Trade %GDP"n
			x = "Financial institution account (%"n ;
run; 




Title "Multi Regression";
proc reg data=Logt; 
model "Trade %GDP"n = 
	 "WBPopulation"n  
	 "GDP per Capita"n 
	 "WBArea"n
	 "Trade Policy"n
	 "Financial institution account (%"n;
run; 
quit;
title; 



proc corr data=margs;
var  "WBPopulation"n  
	 "GDP per Capita"n 
	 "WBArea"n
	 "Trade Policy"n
	 "Financial institution account (%"n;
run;




/*What to do next: 

- log everything 
- run new reg
- make the data base to fix error with countries
- bring in all wb data*/

 
 
/* Deleted stuff

	"Trade Freedom No."n = input("Trade Freedom"n , 8.);
		"Inflation No.(%)"n = input("Inflation (%)"n, 6.);
		"Government Integrity No."n = input ("Government Integrity"n, 8.);
		
	label "Inflation No.(%)"n= "Inflation (%)";
	label "Government Integrity No."n = "Government Integrity No.";
	label "GDP per Capita"n = "GDP per Capita";
	keep 
	"Financial institution account (%"n 
	"Country Name"n 
	"Inflation No.(%)"n  
	"Trade %GDP"n
	"GDP per Capita"n
	"WBPopulation"n;
	*"Financial institution account (%"n = log("Financial institution account (%"n);
*/
