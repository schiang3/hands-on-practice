proc import datafile= 'shuya_claim.csv' out = car_claim replace;
delimiter=',';
getnames= yes;
run;
/*proc print;
run;*/
title"dummy variables";
data car_claim;
set car_claim;
deduh=(EDU=1);
dedub=(EDU=2);*dummy variables for edu;
dedum=(EDU=3);
dgender =(GENDER="M");*male=1;
dparent1=(PARENT1="Yes");
dmstatus=(MSTATUS="Yes");
dcarused=(CAR_USE="Commercial");
dredcar=(RED_CAR="yes");
drevoked=(REVOKED="Yes");
run;
/*proc print;
run;*/
title "Descriptives";
proc means mean min p50 max;
var KIDSDRIV AGE HOMEKIDS YOJ INCOME HOME_VAL  TRAVTIME  BLUEBOOK TIF OLDCLAIM MVR_PTS CLM_AMT CAR_AGE CLM_FREQ;
run;
title "Histogram w/normal curve";
proc univariate normal;
var CLM_AMT KIDSDRIV AGE HOMEKIDS YOJ INCOME HOME_VAL  TRAVTIME  BLUEBOOK TIF OLDCLAIM MVR_PTS CLM_AMT CAR_AGE CLM_FREQ ;
histogram / normal (mu = est sigma = est);
run;
Title"freq Qualitative";
proc freq;
table  (dgender dparent1 dmstatus dcarused dredcar drevoked URBANICITY EDU)*CLAIM_FLAG;
run;
Title"BOXPLOTS";
proc sort;
by CLAIM_FLAG;
run;
proc boxplot; 
plot KIDSDRIV*CLAIM_FLAG;
plot AGE*CLAIM_FLAG; 
plot HOMEKIDS*CLAIM_FLAG;
plot YOJ*CLAIM_FLAG;
plot INCOME*CLAIM_FLAG;
plot HOME_VAL*CLAIM_FLAG;
plot TRAVTIME*CLAIM_FLAG;
plot BLUEBOOK*CLAIM_FLAG;
plot TIF*CLAIM_FLAG;
plot OLDCLAIM*CLAIM_FLAG;
plot MVR_PTS*CLAIM_FLAG;
plot CLM_AMT*CLAIM_FLAG; 
plot CAR_AGE*CLAIM_FLAG; 
plot CLM_FREQ*CLAIM_FLAG;
run;
proc sgscatter;
title "Scatterplot Matrix ";
matrix CLM_AMT KIDSDRIV AGE HOMEKIDS YOJ INCOME HOME_VAL  TRAVTIME  BLUEBOOK TIF OLDCLAIM MVR_PTS CAR_AGE CLM_FREQ;
run;
title "correlation";
proc corr;
var CLM_AMT KIDSDRIV AGE HOMEKIDS YOJ INCOME HOME_VAL TRAVTIME  BLUEBOOK TIF OLDCLAIM MVR_PTS CAR_AGE CLM_FREQ;
run;
title"logistic- standardized coefficients AND CORRB For analysis";
proc logistic;
model CLAIM_FLAG(event='1')= KIDSDRIV AGE INCOME HOMEKIDS YOJ HOME_VAL BLUEBOOK TIF  MVR_PTS OLDCLAIM CAR_AGE CLM_FREQ deduh dedub dedum dgender dparent1 dcarused dredcar drevoked URBANICITY/ stb corrb rsquare;
run;
title"logistic-  outliers for numerical(removed age)";
ods graphics on;
proc logistic;
model CLAIM_FLAG(event='1')= KIDSDRIV  HOMEKIDS YOJ INCOME HOME_VAL TRAVTIME  BLUEBOOK TIF MVR_PTS CAR_AGE CLM_FREQ / influence iplots ;
run;
ods graphics off;
Title"delete outlier";
data car_claim;
set car_claim;
if _n_  =10231 then delete;
run;
title"standardized coefficients 1(REMOVED AGE REDCAR dedub dedum )";
proc logistic;
model CLAIM_FLAG(event='1')=  KIDSDRIV INCOME HOMEKIDS YOJ INCOME HOME_VAL TRAVTIME  BLUEBOOK OLDCLAIM TIF MVR_PTS CAR_AGE CLM_FREQ deduh dgender dparent1 dmstatus dcarused drevoked URBANICITY/ stb rsquare;
run;
title"split data to train and test set";
proc surveyselect data=car_claim out= train seed=495857
samprate=0.75 outall;
run;
/*proc print data=train;
run;*/
proc freq data=train;
tables selected;
run;
*train_y =  to identify training records;
title"new_y for train";
data train;
set train;
if selected then train_y= CLAIM_FLAG;
run;
/*proc print;
run;*/
*run model selection with training set;
Title "Model selection stepwise";
*fit full model+options;
proc logistic data= train;
model train_y(event='1')= KIDSDRIV  HOMEKIDS YOJ INCOME HOME_VAL TRAVTIME  BLUEBOOK TIF MVR_PTS CAR_AGE CLM_FREQ deduh dgender dparent1 dmstatus dcarused drevoked URBANICITY /selection=stepwise rsquare;
run;
Title "Model selection-backward";
proc logistic data= train;
model train_y(event='1')= KIDSDRIV  HOMEKIDS YOJ INCOME HOME_VAL TRAVTIME  BLUEBOOK TIF MVR_PTS CAR_AGE CLM_FREQ deduh dgender dparent1 dmstatus dcarused drevoked URBANICITY /selection=backward rsquare;
run;
Title "Model selection-forward";
proc logistic data= train;
model train_y(event='1')= KIDSDRIV  HOMEKIDS YOJ INCOME HOME_VAL TRAVTIME  BLUEBOOK TIF MVR_PTS CAR_AGE CLM_FREQ deduh  dgender dparent1 dmstatus dcarused drevoked URBANICITY /selection=forward rsquare;
run;
Title "final model";
proc logistic data= train;
model train_y(event='1')= KIDSDRIV  HOMEKIDS  TRAVTIME INCOME HOME_VAL BLUEBOOK TIF MVR_PTS CLM_FREQ deduh dgender dparent1 dmstatus dcarused drevoked URBANICITY /stb influence iplots rsquare;
run;
Title "final model-(REMOVE INCOME HOME_VAL ) ";
proc logistic data= train;
model train_y(event='1')= KIDSDRIV  HOMEKIDS  TRAVTIME  BLUEBOOK TIF MVR_PTS CLM_FREQ deduh dgender dparent1 dmstatus dcarused drevoked URBANICITY/stb rsquare;
run;
Title "final model(2)-(REMOVE  INCOME HOME_VAL+ BLUEBOOK  ) ";
proc logistic data= train;
model train_y(event='1')= KIDSDRIV HOMEKIDS  TRAVTIME  TIF MVR_PTS CLM_FREQ deduh  dgender dparent1 dcarused dmstatus drevoked URBANICITY/stb rsquare;
run;
Title "final model(3)-(REMOVE  INCOME HOME_VAL+ HOMEKIDS ) ";
proc logistic data= train;
model train_y(event='1')= KIDSDRIV BLUEBOOK  TRAVTIME  TIF MVR_PTS CLM_FREQ deduh  dgender dparent1 dcarused dmstatus drevoked URBANICITY/stb rsquare;
run;
Title "final model(4)-(REMOVE  INCOME HOME_VAL HOMEKIDS BLUEBOOK ) ";
proc logistic data= train;
model train_y(event='1')= KIDSDRIV TRAVTIME  TIF MVR_PTS CLM_FREQ deduh  dgender dparent1 dcarused  dmstatus drevoked URBANICITY/stb rsquare;
run;

Title"final model(3)-REMOVED  INCOME HOME_VAL HOMEKIDS ";
proc logistic data= train;
model train_y(event='1')= KIDSDRIV  TRAVTIME  BLUEBOOK TIF MVR_PTS CLM_FREQ deduh  dgender dparent1 dmstatus dcarused drevoked URBANICITY/ ctable pprob=(0.1 to 0.8 by 0.05);
output out=pred(where= (train_y= .)) p= phat lower=lcl upper=ucl;
run;
*this is done for your test set-use pred;
Title"final model(3) threshold=0.3";
data probs;
set pred;
pred_y=0; *initializing;
*if predicted prob. > cut-off, assign 1;
if phat > 0.3 then  pred_y =1;
run;
/*proc print;
run;*/
*generate conf. matrix;
proc freq;
tables CLAIM_FLAG*pred_y / norow nocol nopercent;
run;
Title"final model(3) threshold=0.35";
data probs2;
set pred;
pred_y=0; *initializing;
*if predicted prob. > cut-off, assign 1;
if phat > 0.35 then  pred_y =1;
run;
*generate conf. matrix;
proc freq;
tables CLAIM_FLAG*pred_y / norow nocol nopercent;
run;
Title"final model(3) threshold=0.2";
data probs3;
set pred;
pred_y=0; *initializing;
*if predicted prob. > cut-off, assign 1;
if phat > 0.2 then  pred_y =1;
run;
*generate conf. matrix;
proc freq;
tables CLAIM_FLAG*pred_y / norow nocol nopercent;
run;

Title "final model(4)-(REMOVE  INCOME HOME_VAL HOMEKIDS BLUEBOOK ) ";
proc logistic data= train;
model train_y(event='1')= KIDSDRIV TRAVTIME  TIF MVR_PTS CLM_FREQ deduh  dgender dparent1 dcarused  dmstatus drevoked URBANICITY/ ctable pprob=(0.1 to 0.8 by 0.05);
output out=pred2(where= (train_y= .)) p= phat lower=lcl upper=ucl;
run;
Title"final model(4) threshold=0.3";
data probs;
set pred2;
pred2_y=0; *initializing;
*if predicted prob. > cut-off, assign 1;
if phat > 0.3 then  pred2_y =1;
run;
/*proc print;
run;*/
*generate conf. matrix;
proc freq;
tables CLAIM_FLAG*pred2_y / norow nocol nopercent;
run;
Title"final model(4) threshold=0.35";
data probs2;
set pred2;
pred2_y=0; *initializing;
*if predicted prob. > cut-off, assign 1;
if phat > 0.35 then  pred2_y =1;
run;
*generate conf. matrix;
proc freq;
tables CLAIM_FLAG*pred2_y / norow nocol nopercent;
run;
Title"final model(4) threshold=0.2";
data probs3;
set pred2;
pred2_y=0; *initializing;
*if predicted prob. > cut-off, assign 1;
if phat > 0.2 then  pred2_y =1;
run;
*generate conf. matrix;
proc freq;
tables CLAIM_FLAG*pred2_y / norow nocol nopercent;
run;

