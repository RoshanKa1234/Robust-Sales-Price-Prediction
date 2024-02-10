
proc import datafile="/home/u63249191/Practice_sas/Dataset/housing_details.csv"
              out=practice.houses
              dbms=dlm replace ;
              delimiter = '09'x;
              getnames=yes;
              datarow=2;
              guessingrows=max;
run;

proc import datafile="/home/u63249191/Practice_sas/Dataset/value_of_sales.csv"
              out=Practice.values
              dbms=dlm replace ;
              delimiter = '09'x;
              getnames=yes;
              datarow=2;
              guessingrows=max;
run;

/* ID_House	Living_Area	Garage_Area	Count_Bedroom Count_Bathroom Central_Air Overall_Qual Year_construction	Age_of_Property	Price_of_Sale */
/* Change price of sale into dollar format */
/* Removing outliers value - week 8 - invalid data */
data housing; 
Set PRACTICE.HOUSES; 
run;

data values; 
Set PRACTICE.VALUES; 
format Price_of_Sale Dollar10.2;
run;


PROC SQL;
CREATE TABLE housing_full_table
AS
SELECT *
FROM housing
INNER JOIN values
ON
housing.ID_House = values.ID_House;
QUIT;

/* 1st - need to do descriptive statistics - missing values, outliers */
/* 2nd - fixing format, changes in the column */
/* 3rd - univariate analysis: hist, pie chart */
/* 4th - bivariate : scatter, line and etc */
/* 5th - feature engineering */
/* 6th - modelling  */

/* There are 5 records which have duplicate values */
proc sort data = housing_full_table out=nodup_emptable noduprecs dupout=duplicate_table; 
by ID_house; 
run;

/* Changing the format of data */
data no_spaces;
set nodup_emptable;
 Central_Air = compress(Central_Air);
run;

data first_format;
   set no_spaces;
   if Central_Air in ('y') then Central_Air = 'Y';
   else if Central_Air in ('n') then Central_Air = 'N';
run;

proc freq data=first_format ;
table Count_Bedroom Count_Bathroom Overall_Qual Central_Air;
run;

/* Dealing with the missing values */
proc means data=first_format n nmiss missing;
var Overall_Qual Year_construction	Age_of_Property	Price_of_Sale Living_Area Garage_Area Count_Bedroom	Count_Bathroom ; 
run;

/* printing all 200 records which means there is no missing values */
data Missing_air;
   set no_spaces;
   if missing(Central_Air) then output;
run;

/* Outlier detected from extreme observations */
ods select extremeobs; 
proc univariate data=first_format nextrobs = 3; 
	var Living_Area Garage_Area Overall_Qual Age_of_Property Price_of_Sale;
	hist;
run;

title "Listing of Patient Numbers and "
      "Invalid Data Values";

data PN_and_IDV out_living out_garage out_quality;
   set first_format;
 
   ***Check HR;
   if (Living_Area lt 47 and not missing(Living_Area)) or 
      Living_Area gt 141 then output out_living;
   ***Check SBP;
   if (Garage_Area <= 0 and not missing(Garage_Area)) or 
      Garage_Area gt 81 then output out_garage;
   ***Check DBP;
   if (Overall_Qual lt 2 and not missing(Overall_Qual)) or 
      Overall_Qual gt 106 then output out_quality;
   output PN_and_IDV;
run;



proc export data=first_format
outfile='/home/u63249191/Practice_sas/Dataset/asses_test.csv'
dbms=csv
replace;
run;