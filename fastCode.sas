/*%start;*/

%macro fastCode(vars,del=,alg=input,informat=,globSep=%str( ),autoDom=)/minoperator;

	%local curOperation i invar outvar fmt brakets algPart simpleFmt;
	%put &alg.;
	%setDefOption_fastCode

	%*search algorithm for the point of insertion of variables; 
	%let algPart = %sysfunc(prxchange(%str(s/(?=[,\%)]).*//),-1,&alg.));
	%if %length(%sysfunc(compress(%bquote(&alg),%str(%))))) = %length(%bquote(&algPart)) %then 
		%if "%substr(%QSYSFUNC(REVERSE(%bquote(&algPart.))),1,1)" ^= "(" %then %let algPart = &algPart.(;
	%put &algPart.;
	%*received data processing;
	%do %while(%get_word(&vars, i, curOperation,sep=&globSep.));

		%let outvar = %scan(&curOperation,1,&del.);
		%let invar = %scan(&curOperation.,2,&del.);
		%let fmt = %scan(&curOperation,3,&del.);
		%let simpleFmt = &true.;
		%if &autoDom. %then %let outvar = &domain.&outvar.;
		

		%if %index(&alg.,input) or %index(&alg.,put) %then %do;

			%if %bquote(&fmt.) = %then %let fmt = ny.;
			%if &informat. %then %do;
				%if %substr(&fmt.,1,1) = ? and ^%index(&fmt.,$) %then %let fmt = ??$%substr(&fmt.,3);
				%if ^(%substr(&fmt.,1,1) # ($ ?)) %then %let fmt = $&fmt.;	
			%end;

			%*cheack length and last char of fmt;
			%if %length(&fmt.) > 2 %then 
				%if %sysfunc(compress(%substr(&fmt.,%length(&fmt.)-1),-lrc,i)) = %then %let simpleFmt = &false.;

			%if %sysfunc(compress(&fmt,.,k)) ^= . %then
				%if &simpleFmt. %then %let fmt = &fmt..;
					%else %let fmt = %sysfunc(compress(%scan(&fmt,1,-))).%str( )-%scan(&fmt,2,-);

			
		%end;

		%if %index(&alg.,none) or %bquote(&alg.) = %then &outvar. = &invar.;
			%else %chkPutPositionAndGetFormat(%bquote(&algPart.),&fmt.,%bquote(&brakets.),&invar.,&outvar.);;
			
	%end;

%mend fastCode;

%macro setDefOption_fastCode;

	%if %bquote(&alg.) ^= %then %let alg = %bquote(%sysfunc(compress(&alg.)));
	%let simpleFmt = &true;

	%*set informat-format option;
	%if %bquote(&informat.) = %then 
		%if %symexist(g_fastCode_informat) %then %let informat = &g_fastCode_informat;
			%else %let informat = &true.;
	
	%*auto set domain prefix;
	%if &autoDom. = %then 
		%if %symexist(g_fastCode_autoDom) %then %let autoDom = &g_fastCode_autoDom;
			%else %let autoDom = &false.;

	%*inner delimeter;
	%if %bquote(&del) = %then 
		%if %symexist(g_fastCode_del) %then %let del = &g_fastCode_del;
			%else %let del = %str(-);

%mend;

%macro chkPutPositionAndGetFormat(EXP,format,braketWithParam,inputVariable,outPutVariable)/minoperator;

	%local curFunc downCounter upperCounter newBrak curAddParam OutPutExp;
	%let downCounter = %eval(%sysfunc(count(%bquote(&EXP),%str(%())));
	%let curFunc = %qscan(&EXP, &downCounter.,%str(%());
	%let braketWithParam = %sysfunc(prxchange(%str(s/\%)/ %)/),-1,%bquote(&braketWithParam.)));

	%let upperCounter = 1;

	%do %while (&downCounter > 0 );

		 %let curAddParam = %scan(%bquote(&braketWithParam.),&upperCounter.,%str(%)));

	 	 %if &curFunc. # (put input) %then %let newBrak =,&format.);
	  		%else %let newBrak = &curAddParam.);

		  %if &upperCounter = 1 %then %let OutPutExp = &curFunc.(&inputVariable.&newBrak.;
		  	%else  %let OutPutExp = &curFunc.(&OutPutExp.&newBrak.;
 		  
		  %let upperCounter = %eval(&upperCounter+1);
		  %let downCounter = %eval(&downCounter-1);

		  %if &downCounter > 0 %then %let curFunc = %scan(&EXP, &downCounter.,%str(%());
		  
	%end;

	&outPutVariable. = &OutPutExp.

%mend chkPutPositionAndGetFormat;

/**/
/**/
/*data test;*/
/**/
/*	k=146;*/
/*	%fastCode(s*k*10. -r!h*k*10. -l,alg=strip(put()),del=*,globsep=!,informat=0);*/
/**/
/*	l=put(1,best. -r);*/
/*run;*/
