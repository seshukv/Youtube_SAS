/**Creating a permanent library**/
libname you '/home/u59397728/sasuser.v94/Assignment 3/Datasets';

/**Importing the Dataset**/
proc import datafile= "/home/u59397728/sasuser.v94/Assignment 3/CSV/Youtube.csv"
                 out= you.youtube(rename=('Video.publish.time'n= VideoPublishTime  
                  'Comments.added'n=CommentsAdded 
                  'Average.percentage.viewed.(%)'n=AveragePercentViewed  
                  'Average.view.duration'n= AverageViewDuration  'Watch.time.(hours)'n=WatchTimeHrs
                   'Clicks.per.end.screen.element.sh'n = ClicksEndPercent 
                   'Impressions.click-through.rate.('n = ImpressionClick ))
                 dbms=csv
                 replace;
                 guessingrows= max;
    run;  

/*Checking for missing values*/
ods noproctitle;

proc format;
	value _nmissprint low-high="Non-missing";
run;

proc freq data=YOU.YOUTUBE;
	title3 "Missing Data Frequencies";
	title4 h=2 "Legend: ., A, B, etc = Missing";
	format VAR1 VideoPublishTime ClicksEndPercent CommentsAdded Shares Dislikes 
		Likes AveragePercentViewed AverageViewDuration Views WatchTimeHrs Subscribers 
		Impressions ImpressionClick _nmissprint.;
	tables VAR1 VideoPublishTime ClicksEndPercent CommentsAdded Shares Dislikes 
		Likes AveragePercentViewed AverageViewDuration Views WatchTimeHrs Subscribers 
		Impressions ImpressionClick / missing nocum;
run;

proc freq data=YOU.YOUTUBE noprint;
	table VAR1 * VideoPublishTime * ClicksEndPercent * CommentsAdded * Shares * 
		Dislikes * Likes * AveragePercentViewed * AverageViewDuration * Views * 
		WatchTimeHrs * Subscribers * Impressions * ImpressionClick / missing 
		out=Work._MissingData_;
	format VAR1 VideoPublishTime ClicksEndPercent CommentsAdded Shares Dislikes 
		Likes AveragePercentViewed AverageViewDuration Views WatchTimeHrs Subscribers 
		Impressions ImpressionClick _nmissprint.;
run;

proc print data=Work._MissingData_ noobs label;
	title3 "Missing Data Patterns across Variables";
	title4 h=2 "Legend: ., A, B, etc = Missing";
	format VAR1 VideoPublishTime ClicksEndPercent CommentsAdded Shares Dislikes 
		Likes AveragePercentViewed AverageViewDuration Views WatchTimeHrs Subscribers 
		Impressions ImpressionClick _nmissprint.;
	label count="Frequency" percent="Percent";
run;

title3;

proc delete data=Work._MissingData_;
run;

/**Checking for out of range values**/
ods noproctitle;
ods graphics / imagemap=on;

proc means data=YOU.YOUTUBE chartype mean std min max n vardef=df;
	var VAR1 VideoPublishTime ClicksEndPercent CommentsAdded Shares Dislikes Likes 
		AveragePercentViewed AverageViewDuration Views WatchTimeHrs Subscribers 
		Impressions ImpressionClick;
run;


/**using hpbin with pseudo_quantile method to categorize impressions into 3 bins**/
proc hpbin data=you.youtube output=you.bin numbin=3 pseudo_quantile;
  input Impressions;
  id VAR1 VideoPublishTime ClicksEndPercent CommentsAdded Shares 
  Dislikes Likes AveragePercentViewed AverageViewDuration Views 
  WatchTimeHrs Subscribers Impressions ImpressionClick;
run; 

/**Creating a custom format with labels low, medium and high**/    
proc format;
value YouCate  
      1 = "Low"        
      2 = "Medium"        
      3 = "High";
run;

/**Applying the custom created format to the BIN_Impressions**/
data you.bin;
SET you.bin;
format BIN_Impressions YouCate.;   
run;

/**using hpbin with pseudo_quantile method to categorize other variables**/
proc hpbin data=you.bin output=you.bin numbin=3 pseudo_quantile;
  input ClicksEndPercent CommentsAdded Shares 
  Dislikes Likes AveragePercentViewed Views 
  WatchTimeHrs Subscribers ImpressionClick;
  id VAR1 VideoPublishTime ClicksEndPercent CommentsAdded Shares 
  Dislikes Likes AveragePercentViewed AverageViewDuration Views 
  WatchTimeHrs Subscribers Impressions ImpressionClick BIN_Impressions;
run; 

/**Applying the custom created format to new columns in the dataset**/
data you.bin;
SET you.bin;
format BIN_ClicksEndPercent BIN_CommentsAdded BIN_Shares 
  BIN_Dislikes BIN_Likes BIN_AveragePercentViewed BIN_Views 
  BIN_WatchTimeHrs BIN_Subscribers BIN_ImpressionClick YouCate.;   
run;
    
/**Chi sqare test between BIN_Impressions and BIN_Views**/    
PROC FREQ DATA=you.bin;
TABLE BIN_Impressions*BIN_Views
/chisq Expected;
RUN;

/**Chi sqare test between BIN_Shares and BIN_Likes**/  
PROC FREQ DATA=you.bin;
TABLE BIN_Shares*BIN_Likes
/chisq Expected;
RUN;

/**Chi sqare test between BIN_Shares and BIN_Views**/ 
PROC FREQ DATA=you.bin;
TABLE BIN_Shares*BIN_Views
/chisq Expected; 
RUN;

/**Chi sqare test between BIN_Subscribers and BIN_WatchTimeHrs**/ 
PROC FREQ DATA=you.bin;
TABLE BIN_WatchTimeHrs*BIN_Subscribers
/chisq Expected; 
RUN;

/**Chi sqare test between BIN_ClicksEndPercent and BIN_Views**/ 
PROC FREQ DATA=you.bin;
TABLE BIN_ClicksEndPercent*BIN_Views
/chisq Expected;  
RUN;

/** 1. Correlation check for Impressions vs Views**/
/* 1. Scatter Plot*/
proc sgplot data=you.bin;
	reg x=Impressions y=Views / nomarkers cli alpha=0.01;
	scatter x=Impressions y=Views;
	xaxis grid;
	yaxis grid;
	title 'Impressions vs Views';	
run;

/* 2. Correlation analysis*/
ods noproctitle;
ods graphics / imagemap=on;

proc corr data=YOU.BIN pearson spearman nosimple plots=none;
	var Impressions;
	with Views;
run;

/* 2. Correlation check for Shares vs Likes*/
/* 1. Scatter Plot*/
proc sgplot data=you.bin;
	reg x=Shares y=Likes / nomarkers cli alpha=0.01;
	scatter x=Shares y=Likes;
	xaxis grid;
	yaxis grid;
	title 'Shares vs Likes';	
run;

/* 2. Correlation analysis*/
ods noproctitle;
ods graphics / imagemap=on;

proc corr data=YOU.BIN pearson spearman nosimple plots=none;
	var Shares;
	with Likes;
run;

/* 3. Correlation check for Shares vs Views*/
/* 1. Scatter Plot*/
proc sgplot data=you.bin;
	reg x=Shares y=Views / nomarkers cli alpha=0.01;
	scatter x=Shares y=Views;
	xaxis grid;
	yaxis grid;
	title 'Shares vs Views';	
	
run;

/* 2. Correlation analysis*/
ods noproctitle;
ods graphics / imagemap=on;

proc corr data=YOU.BIN pearson spearman nosimple plots=none;
	var Shares;
	with Views;
run;


/* 4. Correlation check for WatchTimeHrs vs Subscribers*/
/* 1. Scatter Plot*/
proc sgplot data=you.bin;
	reg x=Subscribers y=WatchTimeHrs / nomarkers cli alpha=0.01;
	scatter x=Subscribers y=WatchTimeHrs;
	xaxis grid;
	yaxis grid;
	title 'WatchTimeHrs vs Subscribers';	
	
run;

/* 2. Correlation analysis*/
ods noproctitle;
ods graphics / imagemap=on;

proc corr data=YOU.BIN pearson spearman nosimple plots=none;
	var Subscribers;
	with WatchTimeHrs;
run;

/* 5. Correlation check for ClicksEndPercent vs Views*/
/* 1. Scatter Plot*/
proc sgplot data=you.bin;
	reg x=Views y=ClicksEndPercent / nomarkers cli alpha=0.01;
	scatter x=Views y=ClicksEndPercent;
	xaxis grid;
	yaxis grid;
	title 'ClicksEndPercent vs Views';		
run;

/* 2. Correlation analysis*/
ods noproctitle;
ods graphics / imagemap=on;

proc corr data=YOU.BIN pearson spearman nosimple plots=none;
	var ClicksEndPercent;
	with Views;
run;


/** Regression model for predicting view**/
ods noproctitle;
ods graphics / imagemap=on;

proc reg data=YOU.BIN alpha=0.05 plots(only)=(diagnostics residuals 
		observedbypredicted);
	model Views=Impressions Subscribers Shares /;
	run;
quit;

