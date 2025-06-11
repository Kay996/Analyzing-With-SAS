/*sixform*/
Libname assign '/home/u64157075/Assignment';
Filename college '/home/u64157075/Assignment/CSIP53026form.csv';

Data sixform;   
 FORMAT
    	Total_CH_Learners Comma12.
        Learners1  Comma12. 
        Total_CH_Year2 Comma12. 
        Learners2 Comma12.  
        Total_CH_Year3 Comma12.  
        Learners3 Comma12.  
        GradPR BEST4.2
        VAF BEST4.2 
        Institution $CHAR30.
        Region  $CHAR25.
        GPercentFemale BEST2.;  
    INFORMAT
    	Total_CH_Learners Comma12.
        Learners1  Comma12. 
        Total_CH_Year2 Comma12. 
        Learners2 Comma12.  
        Total_CH_Year3 Comma12.  
        Learners3 Comma12.  
        GradPR BEST4.2
        VAF BEST4.2 
        Institution $CHAR30.
        Region  $CHAR25.
        GPercentFemale BEST2.;
        
    INFILE college  
        LRECL=150  
        ENCODING="WLATIN1"  
        TERMSTR=CRLF  
        DLM=','  
        MISSOVER  
        DSD  
        FIRSTOBS=2;

    INPUT  
       Total_CH_Learners : BEST12.  
        Learners1 : BEST12.  
        Total_CH_Year2 : BEST12.  
        Learners2 : BEST12.  
        Total_CH_Year3 : BEST12.  
        Learners3 : BEST12.  
        GradPR : BEST4.2  
        VAF : BEST4.2 
        Institution : $30.  
        Region : $25.   
        GPercentFemale : 2.;  
run;
 
data sixform_college;
    set sixform;
    rename 
      Total_CH_Learners = Year1_CH
      Learners1 = Year1_learners
      Total_CH_Year2 = Year2_CH
      Learners2 = Year2_learners
      Total_CH_Year3 = Year3_CH
      Learners3 = Year3_learners
      GradPR = Pass_rate
      VAF = VAF
      GPercentFemale = Grad_femalerate;
run;

proc print data=sixform_college;
run;


/*dropping subtotals & totals*/
proc sql;
    create table sixform_clean as
    select *
    from sixform_college
    where Region is not missing and Region not like "%Sub Total%";
quit;
proc print data=sixform_clean;
run;

/*checking missing values*/
proc means data=sixform_clean nmiss;
run;

proc print data=sixform_college;
    where missing(Year1_CH) or missing(Year1_learners) or missing(Year2_CH) or missing(Year2_learners) 
    or missing(Year3_CH) or missing(Year3_learners) or missing(Pass_Rate) or missing(VAF) 
    or missing(Grad_femalerate) or missing(Institution) or missing(Region);
run;


/*checking outliers and skewness to decide whether to replace with mean or median*/
ods output ExtremeObs=extreme_variables ;
proc univariate data= sixform_clean nextrobs= 10;
    var Year1_CH
            Year1_learners
            Year2_CH
            Year2_learners
            Year3_CH
            Year3_learners
            Pass_Rate
            VAF;
	histogram  / KERNEL normal(mu= est sigma= est) ;
    qqplot / normal(mu= est sigma= est) ;
    inset min q1 median q3 max skew kurt / position= SE ;
    run;
ods select all;

/*replacing with median*/

proc univariate data=sixform_clean noprint;
    var Year1_CH Year1_learners Year2_CH Year2_learners Pass_rate;
    output out=median_sixform
    median=Median_Year1_CH Median_Year1_learners Median_Year2_CH Median_Year2_learners Median_passrate;

data sixform_replace;
	 if _N_ = 1 then do;
        set median_sixform;
    end;
	set sixform_clean;
  	if Year1_CH = . then Year1_Ch = Median_Year1_CH;
  	if Year1_learners = . then Year1_learners = Median_Year1_learners;
    if Year2_CH = . then Year2_CH = Median_Year2_CH;
    if Year2_learners = . then Year2_learners = Median_Year2_learners;
    if Pass_rate = 0.01 then Pass_rate = Median_passrate;
    drop Median_Year1_CH Median_Year1_learners Median_Year2_CH Median_Year2_learners Median_passrate;
run;
proc print data=sixform_replace;
run;



/*creating new variables*/
data sixform_college_new;
 retain Institution Region;
   format Grad_malerate BEST2.
    		CH_per_learnerY1 CH_per_learnerY2 CH_per_learnerY3 Avgch_per_learner Comma12.;
   informat Grad_malerate BEST2.
    		CH_per_learnerY1 CH_per_learnerY2 CH_per_learnerY3 Avgch_per_learner Comma12.;
 set sixform_replace;
    Grad_malerate = 100 - Grad_femalerate;
    CH_per_learnerY1 =  (Year1_CH / Year1_learners);
    CH_per_learnerY2 =  (Year2_CH / Year2_learners);
    CH_per_learnerY3 = (Year3_CH / Year3_learners);
    Avgch_per_learner = ((Year1_CH+Year2_CH+Year3_CH) / (Year1_learners+Year2_learners+Year3_learners));
run;
proc print data=sixform_college_new;
run;



/*************Re-ordering the variables*************/
proc sql;
	create table sixform_order as
	select 	Institution,
			Region,
            Year1_CH,
            Year1_learners,
            CH_per_learnerY1,
            Year2_CH,
            Year2_learners,
            CH_per_learnerY2,
            Year3_CH,
            Year3_learners,
            CH_per_learnerY3,
            Avgch_per_learner,
            Pass_Rate,
            VAF,
            Grad_malerate,
			Grad_femalerate
     from sixform_college_new;
quit;
proc print data=sixform_order;
run;



/*FE COLLEGE*/

Filename fe '/home/u64157075/Assignment/CSIP5302FE.csv';
Data fe_college;   
 FORMAT
 		ID BEST3.
 		Institution $CHAR30.
        Region  $CHAR25.
    	Total_CH_Learners Comma12.
        Learners1  Comma12. 
        Total_CH_Year2 Comma12. 
        Learners2 Comma12.  
        Total_CH_Year3 Comma12.  
        Learners3 Comma12.  
        GPercentMale BEST2.;  
    INFORMAT
   		ID BEST3.
    	Institution $CHAR30.
        Region  $CHAR25.
    	Total_CH_Learners Comma12.
        Learners1  Comma12. 
        Total_CH_Year2 Comma12. 
        Learners2 Comma12.  
        Total_CH_Year3 Comma12.  
        Learners3 Comma12.  
        GPercentMale BEST2.;
        
    INFILE fe
        LRECL=150  
        ENCODING="WLATIN1"  
        TERMSTR=CRLF  
        DLM=','  
        MISSOVER  
        DSD  
        FIRSTOBS=2;

    INPUT  
    	ID : BEST3.
    	Institution : $30.  
        Region : $25.  
        Total_CH_Learners : BEST12.  
        Learners1 : BEST12.  
        Total_CH_Year2 : BEST12.  
        Learners2 : BEST12.  
        Total_CH_Year3 : BEST12.  
        Learners3 : BEST12.  
        GPercentMale : 2.;
run;
proc contents data=fe_college;	

data fe_rename;
   set fe_college;
     rename 
   	  Total_CH_Learners = Year1_CH
      Learners1 = Year1_learners
      Total_CH_Year2 = Year2_CH
      Learners2 = Year2_learners
      Total_CH_Year3 = Year3_CH
      Learners3 = Year3_learners
      GPercentMale = Grad_malerate;
run;
proc print data=fe_rename;
run;


/*ID*/
data metrics;
    infile '/home/u64157075/Assignment/CSIP5302-FEmetric01.tab' dlm='09'x firstobs=2 missover;
    input ID GradePR2 VAF2;
    if ID = . then delete;
    GradePR2=round(GradePR2,0.01);
    VAF2=round(VAF2,0.01);
    rename 
    	GradePR2=Pass_Rate2;
run;

proc print data=metrics;
run;

 
proc SQL;
    create table fe_college_join as
        select
            R.*
            , I.*
			
        from fe_rename R
            full join metrics I on R.ID = I.ID;
       
quit;
proc print data=fe_college_join;
run;


/*dropping sub totals*/
proc sql; 
    create table fe_drop as
    select *
    from fe_college_join
    where Region is not missing and Region not like "%Sub Total%";
quit;
proc print data=fe_drop;
run;



/*missing values handling*/
/*checking missing values*/
			 
proc print data=fe_drop;
    where missing(Year1_CH) or missing(Year1_learners) or missing(Year2_CH) or missing(Year2_learners) 
    or missing(Year3_CH) or missing(Year3_learners) or missing(Pass_Rate2) or missing(VAF2) 
    or missing(Grad_malerate) or missing(Institution) or missing(Region);
run;
 
proc means data=fe_drop nmiss;
run;

/*replacing mean and median for missing values*/ 
proc univariate data=fe_drop noprint;
    var Year1_CH Year1_learners Year2_CH Year2_learners Year3_CH Year3_learners 
    	Grad_malerate Pass_Rate2 VAF2;
   output out=median_fe
   median=Median_Year1_CH Median_Year1_learners Median_Year2_CH Median_Year2_learners 
   		  Median_Year3_CH Median_Year3_learners Median_Grad_malerate Median_passrate2 Median_VAF2;
run;


data fe_replace;
	if _N_= 1 then set median_fe;
  set fe_drop;
  	if Year1_CH = . then Year1_Ch = Median_Year1_CH;
  	if Year1_learners = . then Year1_learners = Median_Year1_learners;
    if Year2_CH = . then Year2_CH = Median_Year2_CH;
    if Year2_learners = . then Year2_learners = Median_Year2_learners;
    if Year3_CH = . then Year3_CH = Median_Year3_CH;
    if Year3_learners = . then Year3_learners = Median_Year3_learners;
    if Grad_malerate = . then Grad_malerate = Median_Grad_malerate;
    if Pass_Rate2 = . then Pass_Rate2 = Median_passrate2;
    if VAF2 = . then VAF2 = Median_VAF2;
    drop Median_Year1_CH Median_Year1_learners Median_Year2_CH Median_Year2_learners 
   		  Median_Year3_CH Median_Year3_learners Median_Grad_malerate Median_passrate2 Median_VAF2;
run;
proc print data=fe_replace;
proc means data=fe_replace nmiss;
run;



/****************creating new variables female% and ch per learner*******************/
data fe_college_new;
retain Institution Region;
    format Grad_femalerate BEST2.
    		CH_per_learnerY1 CH_per_learnerY2 CH_per_learnerY3 Avgch_per_learner Comma12.;
    informat Grad_femalerate BEST2.
    		CH_per_learnerY1 CH_per_learnerY2 CH_per_learnerY3 Avgch_per_learner Comma12.;
   set fe_replace; 
    Grad_femalerate  = 100 - Grad_malerate;
    CH_per_learnerY1 = (Year1_CH / Year1_learners);
    CH_per_learnerY2 = (Year2_CH / Year2_learners);
    CH_per_learnerY3 = (Year3_CH / Year3_learners);
   	Avgch_per_learner = ((Year1_CH+Year2_CH+Year3_CH) / (Year1_learners+Year2_learners+Year3_learners));
run;
proc print data=fe_college_new;
run;
proc means data=fe_college_new;
var Avgch_per_learner; 
run;



/**********re-order variables*****************/ 
proc sql;
	create table fe_order as
	select 	ID,
			Institution,
			Region,
			Year1_CH,
			Year1_learners,
			CH_per_learnerY1,
			Year2_CH,
			Year2_learners,
			CH_per_learnerY2,
			Year3_CH,
			Year3_learners,
			CH_per_learnerY3,
			Avgch_per_learner,
			Pass_Rate2,
			VAF2,
			Grad_malerate,
			Grad_femalerate
		from fe_college_new;
quit;
proc print data=fe_order;
run;



/*****************Join table fe and sixform******************/

proc sql;
	create table college_join as
	select Institution, Region, Year1_CH, Year1_learners, CH_per_learnerY1,
           Year2_CH, Year2_learners, CH_per_learnerY2, Year3_CH, Year3_learners, CH_per_learnerY3,
           Avgch_per_learner, Pass_Rate, VAF, Grad_malerate, Grad_femalerate
    from sixform_order
 	UNION ALL
	select Institution, Region, Year1_CH, Year1_learners, CH_per_learnerY1, Year2_CH, Year2_learners, CH_per_learnerY2,
           Year3_CH, Year3_learners, CH_per_learnerY3, Avgch_per_learner, Pass_Rate2 as Pass_Rate, VAF2 as VAF, 
           Grad_malerate, Grad_femalerate
    from fe_order;
quit;
proc print data=college_join;



/******************* define id *******************/

data college_id;
	retain ID;
    set college_join;  
    ID = _N_;  
run;

proc print data=college_id;
run;



/*************** defining size by contact hour per learner *************************/

proc means data=college_join;
var Avgch_per_learner;
run;
data college_records;
	retain ID Institution Region Year1_CH Year1_learners CH_per_learnerY1
           Year2_CH Year2_learners CH_per_learnerY2 Year3_CH Year3_learners CH_per_learnerY3
           Avgch_per_learner Pass_rate VAF Grad_malerate Grad_femalerate Size;
	format ID BEST3. Size  $CHAR25.;
	informat  ID BEST3. Size  $CHAR25.;
    set college_join;
     ID = _N_;

    /*size based on Avgch_per_learners*/
    max = 860;
    min = 76;
    range = max - min;
    bin = int(range / 5);
  	if Avgch_per_learner >= min and Avgch_per_learner < (min + bin) then Size = "Small";
    else if Avgch_per_learner >= (min + bin) and Avgch_per_learner < (min + 2 * bin) then Size = "Small-Medium";
    else if Avgch_per_learner >= (min + 2 * bin) and Avgch_per_learner < (min + 3 * bin) then Size = "Medium";
    else if Avgch_per_learner >= (min + 3 * bin) and Avgch_per_learner < (min + 4 * bin) then Size = "Large-Medium";
    else if Avgch_per_learner >= (min + 4 * bin) then Size = "Large";
    drop bin min max range;
run;
proc print data=college_records;
	var Size Avgch_per_learner;


/*********creating a size table************/
title "Size Category of Institutions";
data size_category;
    input Size $ 1-15 Range $ 16-50;
    datalines;
Small           76 <= Avgch_per_learner < 232
Small_Medium    232 <= Avgch_per_learner < 388
Medium          388 <= Avgch_per_learner < 544
Large_Medium    544 <= Avgch_per_learner < 700
Large           Avgch_per_learner >= 700
;
run;

proc print data=size_category;
run;


/***************checking data summary*******************/

proc contents data=college_records;

proc means data=college_records;

proc freq data=college_records;
tables Region Institution Size;

title "Statistical Summary of Average CH per Learner by Region and Institution";
proc tabulate data=college_records format=6.2;
    class Institution Region;
    var Avgch_per_learner;
    table 
        Institution * Region, 
        Avgch_per_learner* (n min q1 median mean q3 max std);
run;

title "Statistical Summary of Pass Rate by Region and Institution";
proc tabulate data=college_records format=6.2;
    class  Institution Region;
    var Pass_rate;
    table 
        Institution * Region, 
        Pass_rate * (n min q1 median mean q3 max std);
run;

title "Statistical Summary of VAF by Region and Institution";
proc tabulate data=college_records format=6.2;
    class Institution Region;
    var vaf;
    table 
        Institution * Region,  
        vaf * (n min q1 median mean q3 max std);
run;



/****************** EDA *********************/
/**************Correlation between variables****************/

proc corr data=college_records;
    var avgch_per_learner pass_rate vaf;
  
proc sgscatter data=college_records; 
matrix avgch_per_learner pass_rate vaf /group=Institution diagonal=(histogram kernel);
run;



/**************checking the overall data distribution***********************/

ods output ExtremeObs=extreme_variables ;
proc univariate data=college_join normal;
    var 	AVgch_per_learner
            Pass_Rate
            VAF;
    histogram  / KERNEL normal(mu= est sigma= est) ;
    qqplot / normal(mu= est sigma= est) ;
    inset  skew kurt / position= SE ;
run;
ods select all;

title "Overall Distribution of Male Graduate Rate"; 
proc sgplot data=college_records;
   vbox Grad_malerate;
   xaxis label="Regional Male Graduate Rate";
run; 

title "Overall Distribution of Female Graduate Rate"; 
proc sgplot data=college_records;
   vbox Grad_femalerate;
   xaxis label="Overall Female Graduate Rate";
run; 



/*******Examining the effects, T test, glm, non-parametrics & transformation********/

/************************Transposing************************************************/

Proc transpose data=college_records 
			   out = Longyear 	   
			   name=Year
			   Prefix = Avgch_per_learner;
			   Var  CH_per_learnerY1 CH_per_learnerY2 CH_per_learnerY3;
			   by ID Institution Region notsorted;
run; 
proc print data=Longyear;

Proc transpose data=college_records 
			   out = LongGender 	   
			   name=Gender
			   Prefix = Graduaterate;
			   Var  Grad_malerate Grad_femalerate;
			   by ID Institution Region notsorted;
run; 
proc print data=LongGender;


/***********transformation***************/

options cmplib=(assign.trans);    
proc fcmp outlib=assign.trans.functions; 
    function p3(x);  
		return (x*x*x);
	endsub;

	function p2(x);  
		return (x*x);
	endsub;

   function sqrttran(x);  
  		return ((x)** 0.5); 
  	endsub;

    function logtran(x);   
		return (log(1+x));
	endsub;

	function log10tran(x);   
		return (log10(x));
	endsub;

	function rcpsqrtran(x);  
		return ((1+x)**-0.5);
	endsub;

    function rcptran(x);    
		return ((1+x)**-1);
	endsub;

	function rcp2tran(x);
		return ((1+x)**-2);
	endsub;

	function rcp3tran(x);
		return ((1+x)**-3);
	endsub;
 run;
 
 
 
/**************** 1. effect of institution type on ch per learner*****************/

proc ttest
	data = college_records;
	class Institution; 
	var Avgch_per_learner; 
run; 

proc GLM data= college_records ;
    class Institution;
    model Avgch_per_learner=Institution;
    means Institution  / lsd hovtest=levene ;
    output out= glm_inch p= predicted r= residual;
quit;
proc univariate data=glm_inch normal; 
    var residual;
    histogram  / KERNEL normal(mu= est sigma= est) ;
    qqplot / normal(mu= est sigma= est) ;
    inset n nmiss min q1 median q3 max skew kurt / position= SE ;
run; 
proc print data=glm_inch;
    var Avgch_per_learner predicted residual;
    title "Actual vs Predicted Values and Residuals";
run; 
proc sgplot data=glm_inch;
    scatter x=Avgch_per_learner y=predicted;
    reg x=Avgch_per_learner y=predicted;
    title "Actual vs Predicted avgch_per_learner";
run; 
proc sgplot 
	data=glm_inch;
	scatter x=predicted y=residual;
 	refline 0 / axis=y;
run;

/*trans CH*/
data tranch;
set college_records; 
	trnchlog = logtran(Avgch_per_learner);
	trnchlog10 = log10tran(Avgch_per_learner);
	trnchp3=p3(Avgch_per_learner);
	trnchp2=p2(Avgch_per_learner);
	trnchsqrt=sqrttran(Avgch_per_learner);
	trnchrcp=rcptran(Avgch_per_learner);
	trnchrcpsqrt=rcpsqrtran(Avgch_per_learner);
	trnchrecipsqr=rcp2tran(Avgch_per_learner);
	trnchrecipcub=rcp3tran(Avgch_per_learner);
run; 

proc univariate data= tranch normal ;
    var 
	trnchlog trnchlog10 trnchp3
	trnchp2 trnchsqrt trnchrcp
	trnchrcpsqrt trnchrecipsqr trnchrecipcub;
	histogram  / KERNEL normal(mu= est sigma= est) ;
    qqplot / normal(mu= est sigma= est) ;
    inset n nmiss min q1 median q3 max skew kurt / position= SE ;
run;   
    
/*apply non-parametric since the transformation doesn't make better*/
ods graphics on;
proc npar1way 
	data = college_records
	wilcoxon
	median
	plots=(wilcoxonboxplot medianplot);
	class Institution;
	var Avgch_per_learner;
run;
ods graphics off;




/**************** 2. effect of region on ch per learner*************/

proc GLM data= college_records ;
    class Region;
    model Avgch_per_learner=Region;
    means Region  / lsd hovtest=levene ;
    output out= glm_rch p= predicted r= residual;
quit;

proc univariate data=glm_rch normal; 
    var residual;
    histogram  / KERNEL normal(mu= est sigma= est) ;
    qqplot / normal(mu= est sigma= est) ;
    inset n nmiss min q1 median q3 max skew kurt / position= SE ;
run; 
 
/*apply non-para test*/
ods graphics on;
proc npar1way
	data = college_records
	wilcoxon
	median
	plots=(wilcoxonboxplot medianplot);
	class Region;
	var Avgch_per_learner;
run;
ods graphics off;



/********************** 3.interation effect of region and year on ch *************/

proc GLM data= Longyear ;
    class Region Year;
    model Avgch_per_learner1 = Year Region*Year;
 	lsmeans Year Region*Year;
    output out=glm_ry_ch p= predicted r= residual;
quit;
proc univariate data=glm_ry_ch normal;
    var residual;
    histogram  / KERNEL normal(mu= est sigma= est) ;
    qqplot / normal(mu= est sigma= est) ;
    inset n nmiss min q1 median q3 max skew kurt / position= SE ;
run;

/*tested with wilcoxon since the normality assumption of residuals are violated*/
ods graphics on; 
proc npar1way
	data = Longyear
	wilcoxon
	median
	plots=(wilcoxonboxplot medianplot);
	class Year;
	var Avgch_per_learner1;
run; 
ods graphics off;



/********************** 4.effect of institution type and size on ch and interaction between them*************/
    
proc GLM data= college_records ;
    class Institution Size;
    model Avgch_per_learner = Institution Size Institution*Size; /*interaction*/
 	lsmeans Institution Size Institution*Size;
    output out=glm_inr_ch p= predicted r= residual;
quit;
ods graphics on; 
proc univariate data=glm_inr_ch normal; 
    var residual;
    histogram  / KERNEL normal(mu= est sigma= est) ;
    qqplot / normal(mu= est sigma= est) ;
    inset n nmiss min q1 median q3 max skew kurt / position= SE ;
run; 
proc npar1way
	data = college_records
	wilcoxon
	median
	plots=(wilcoxonboxplot medianplot);
	class Size;
	var Avgch_per_learner;
run; 
ods graphics off;



/****************** 5.effect of gender/variance between male and female graduated rate **************************/
 
proc GLM data= LongGender ;
    class Gender ;
    model Graduaterate1= Gender;
    means Gender / lsd hovtest=levene;;
    output out=glm_gpr p= predicted r= residual;
run;
proc univariate data=glm_gpr normal;
    var residual;
    histogram  / KERNEL normal(mu= est sigma= est) ;
    qqplot / normal(mu= est sigma= est) ;
    inset n nmiss min q1 median q3 max skew kurt / position= SE ;
run;

/*tested with wilcoxon since the normality assumption of residuals are violated*/
ods graphics on; 
proc npar1way
	data = LongGender
	wilcoxon
	median
	plots=(wilcoxonboxplot medianplot);
	class Gender;
	var Graduaterate1;
run; 
ods graphics off;



/************************ 6.interaction effect of insitution, region on passrate*********************/

proc ttest 
	data = college_records;
	class Institution;
	var Pass_Rate; 
run; 
ods graphics on;
proc GLM data= college_records;
    class  Institution Region;
    model Pass_rate =  Institution Region Institution*Region;
    lsmeans Institution Region Institution*Region; 
    output out= glm_inrpr p= predicted r= residual;
quit;
ods graphics off;
 
proc univariate data=glm_inrpr normal;
    var residual;
    histogram  / KERNEL normal(mu= est sigma= est) ;
    qqplot / normal(mu= est sigma= est) ;
    inset n nmiss min q1 median q3 max skew kurt / position= SE ;
run;
proc print data=glm_inrpr;
    var Pass_rate predicted residual;
    title "Actual vs Predicted Values and Residuals";
run; 
proc sgplot data=glm_inrpr;
    scatter x=Pass_rate y=predicted;
    reg x=Pass_rate y=predicted;
    title "Actual vs Predicted Passrate";
run;
proc sgplot 
	data=glm_inrpr;
	scatter x=predicted y=residual;
 	refline 0 / axis=y; 
run; 




/******************** 7.effect of interation of institution and size on pr***********************/
ods graphics on;
proc GLM data= college_records;
    class  Institution Size;
    model Pass_rate = Size Institution*Size;   
    lsmeans Size Institution*Size; 
    output out= glm_insize p= predicted r= residual;
quit;
ods graphics off;
proc univariate data=glm_insize normal;
    var residual;
    histogram  / KERNEL normal(mu= est sigma= est) ;
    qqplot / normal(mu= est sigma= est) ;
    inset n nmiss min q1 median q3 max skew kurt / position= SE ;
run; 
proc print data=glm_insize;
    var Pass_rate predicted residual;
    title "Actual vs Predicted Values and Residuals";
run;
proc sgplot data=glm_insize;
    scatter x=Pass_rate y=predicted;
    reg x=Pass_rate y=predicted;
    title "Actual vs Predicted Passrate";
run; 
proc sgplot 
	data=glm_insize;
	scatter x=predicted y=residual;
 	refline 0 / axis=y;
run;



/********************* 8.effect of institution & region on vaf***********************/

proc ttest 
	data = college_records;
	class Institution;
	var vaf; 
run; 
ods graphics on;
proc GLM data= college_records ; 
    class Institution Region;
    model VAF = Institution Region Institution*Region;
    lsmeans Institution Region Institution*Region; 
    output out=glm_inr_vaf p= predicted r= residual;
quit; 
proc univariate data=glm_inr_vaf normal;
    var residual;
    histogram  / KERNEL normal(mu= est sigma= est) ;
    qqplot / normal(mu= est sigma= est) ;
    inset n nmiss min q1 median q3 max skew kurt / position= SE ;
run;
proc sgplot data=glm_inr_vaf;
    scatter x=Pass_rate y=predicted;
    reg x=Pass_rate y=predicted;
    title "Actual vs Predicted Passrate";
run; 
proc sgplot 
	data=glm_inr_vaf;
	scatter x=predicted y=residual;
 	refline 0 / axis=y;
run;



/***************** 9.effect of vaf on passrate***********************/
 
proc reg data=college_records;
  model pass_rate = vaf / p r cli clm;
  output out=pr_vaf p=yhat r=resid;
run;

proc univariate 
	data = pr_vaf;
	var resid;
	qqplot /normal(mu=est sigma=est);
	histogram /normal;
run; 
proc sgplot data=pr_vaf;  
  reg x=vaf y=pass_rate/clm cli;
run;                              
 
proc sgplot data=pr_vaf;
  histogram resid;             
  density resid / type=normal;  
run;

proc sgplot data=pr_vaf;  
  reg x=vaf y=pass_rate;   
  loess x=vaf y=vaf; 
run;
 
proc sgplot data=pr_vaf;
  loess x=yhat y=resid;     
  refline 0 / axis=y;       
run;







/********************************************************* *************************/
 
