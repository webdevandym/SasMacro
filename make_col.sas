%macro make_col(ds_name,varin,varout,varout2,dsout=,defcol=1,deflen=200,sep=%str(@)
			,breakchars=%str( -/:),startNum=1);  
	
	
*V. 2.4.3mlite;
%*breaks the text into columns with a fixed length;

	%local i index maxOfCol maxRowLength allVars colCnt;

	proc sql noprint;
		select max(length(&varin.)) into:maxRowLength from &ds_name. WHERE &VARIN. IS not NULL;
	quit;

	%if &maxRowLength. > . %then %let colCnt = %SYSEVALF(&maxRowLength./&deflen.,ceil);
		%else %do; 
			%error(%str(Given variable is empty, please check!)); 
			%return; 
		%end;

	%if %bquote(&dsout) = %then %let dsout = &ds_name.;

	%genVarList;

	data &dsout.;
		length &allVars. $&deflen.;
		set &ds_name.;

		call missing(of &allVars.);

		&VARIN. = compbl(&VARIN.);
		%linebreaks(&VARIN.,&DEFLEN.,&SEP.,breakchars=&breakchars.);

		%do i = 1 %to &maxOfCol.;
			%scan(&allVars.,&i.," ") = scan(&varin.,&i.,"&sep.");
		%end;

	run; 

%mend make_col;

%macro genVarList;

	%local index i;

	%if &colCnt. < &defcol. %then %let maxOfCol = &defcol.;
			%else %let maxOfCol = &colCnt;

	%let allVars = &varout;
	
	%do i = 2 %to &maxOfCol;

		%let index = %eval(&i+&startNum-2);
		%if %bquote(&varout2.)^= %then %do;

			%if %length(&varout.&index.) le 8 %then %let allVars = &allVars. &varout.&index.;
				%else %let allVars = &allVars. &varout2.&index.;

		%end; %else %let allVars = &allVars. &varout.&index.;;

	%end;

%mend;

%*if you use a macro code in the inside, lower it to the bottom,
change ds_name should be assigning a value to the final date set;

/***Example in code*****

data Example;
	set oneDs twoDs...;
	...code...
	%make_col(Example,<other param...>);
run;

*****Example out code*****

data Example;
	set oneDs twoDs...;
	...code...
run;
%make_col(Example,<other param...>);

********************

ds_name - input dataset
dsout - output dataset
varin - variable whith large text;
varout - prefix variable;
varout2 - prefix variable2 if varout whit index > 8 char (SPDECSPC1 > 8 char);
defcol - define columns;
deflen - define lenght of columns;
sep - separator for %linebreaks;
breakchars - char for break text;
startNum - number starting index variable;
********************/

/************* my change log
2.4:
*Now assigned to the variable length of parameter >>>deflen;
*Added genVarList macros to generate variable list;
*Change text separation algorithm (%genVarList macro);
2.4.1
*Now the output variables are overwritten before treatment;
2.4.2
*before %linebreak, input variable, is compbl.
*************/
