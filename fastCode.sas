%macro fastCode(vars,del=,alg=input,informat=,globSep=%str( ),autoDom=)/minoperator;

	%local word i invar outvar fmt brakets algPart simpleFmt;

	%let alg = %sysfunc(compress(&alg.));
	%setDefOption_fastCode

	%*search algorithm for the point of insertion of variables; 
	%let algPart = %sysfunc(prxchange(%str(s/(?=[,\%)]).*//),-1,&alg.));

	%if %length(%bquote(&algPart)) < %length(&alg) %then 
			%let brakets = %substr(&alg.,%length(%bquote(&algPart.))+1);
		%else %do;
			%let algPart = &algPart.(;
			%let brakets =);
		%end;

	%*received data processing;
	%do %while(%get_word(&vars, i, word,sep=&globSep.));

		%let outvar = %scan(&word,1,&del.);
		%let invar = %scan(&word.,2,&del.);
		%let fmt = %scan(&word,3,&del.);
		%let simpleFmt = &true.;
		%if &autoDom. %then %let outvar = &domain.&outvar.;
		

		%if %index(&alg.,input) or %index(&alg.,put) %then %do;

			%if %bquote(&fmt.) = %then %let fmt = ny.;
			%if &informat. and ^(%substr(&fmt.,1,1) # ($ ?)) %then %let fmt = $&fmt.;
			%*cheack length and last char of fmt;
			%if %length(&fmt.) > 2 %then 
				%if ("%substr(&fmt.,%length(&fmt.)-2)" # (" -l" " -r" " -c" " -L" " -R" " -C")) 
					%then %let simpleFmt = &false.;

			%if %sysfunc(compress(&fmt,.,k)) ^= . and &simpleFmt. %then %let fmt = &fmt..;
			
			&outvar = &algPart.&invar.,&fmt.&brakets.

		%end; %else %if %index(&alg.,none) or %bquote(&alg.) = %then &outvar = &invar.;
						%else &outvar = &algPart.&invar.&brakets.;;
	%end;

%mend fastCode;

%macro setDefOption_fastCode;

	%let simpleFmt = &true;

	%*set informat-format option;
	%if &informat = %then 
		%if %symexist(g_fastCode_informat) %then %let informat = &g_fastCode_informat;
			%else %let informat = &true.;
	
	%*auto set domain prefix;
	%if &autoDom = %then 
		%if %symexist(g_fastCode_autoDom) %then %let autoDom = &g_fastCode_autoDom;
			%else %let autoDom = &false.;

	%*inner delimeter;
	%if &del = %then 
		%if %symexist(g_fastCode_del) %then %let del = &g_fastCode_del;
			%else %let del = %str(-);

%mend;


%*%substr(&fmt.,%length(&fmt.)) ^= .*%

%*v2.4.3 (new algorithm, add comment and FAQ)
		Author: Andrey
	def. call alg option -> <strip> <input> <put> and etc., <strip(input())> <strip(put())> and etc.,
		<strip(compbl())> and etc..
	strip(input()) -> strip(input(invar,format))
	vars -> varOut1-varIn1-Fmt1 -> varOut1 = strip(input(varIn1,Fmt1.))
	If foramt is empty -> def format = ny. or $ny., depending on the option <informat>
!brackets must always be paired for the option -> alg.
Option:
	1.informat=true -> $ + format -> ny. => $ny.
	1.1 for the format set point is not necessarily
	2.globSep -> separator between global variables
	3.del -> separator betwwen var. => varout varin fmt (if needed);


%*old vers. without multi operators (function);

/*%macro fastCode(vars,del=%str(-),alg=input,informat=&true.,globSep=%str( ))/minoperator;*/
/**/
/*	%local word i invar outvar fmt;*/
/*	%do %while(%get_word(&vars, i, word,sep=&globSep.));*/
/**/
/*		%let outvar = %scan(&word,1,&del.);*/
/*		%let invar = %scan(&word.,2,&del.);*/
/*		%let fmt = %scan(&word,3,&del.);*/
/**/
/*		%if &alg # (input put) %then %do;*/
/**/
/*			%if %bquote(&fmt.) = %then %let fmt = ny.;*/
/*			%if &informat. and ^(%substr(&fmt.,1,1) # ($ ?)) %then %let fmt = $&fmt.;*/
/*			%if %substr(&fmt.,%length(&fmt.)) ^= . %then %let fmt = &fmt..;*/
/**/
/*			&outvar = &alg(&invar.,&fmt.);*/
/**/
/*		%end; %else %if &alg = none %then &outvar = &invar.;*/
/*						%else &outvar = &alg(&invar.);;*/
/**/
/*	%end;*/
/**/
/*%mend fastCode;*/

%*v1.2;
