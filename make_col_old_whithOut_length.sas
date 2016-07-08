%macro make_col(ds_name,varin,varout,varout2,dsout=,defcol=3,deflen=200,sep=%str(@)
			,breakchars=%str( -/:),startNum=1);  
	
	
*V. 2.1mlite;
%*breaks the text into columns with a length of max 200.
if you use a macro code in the inside, lower it to the bottom,
change ds_name should be assigning a value to the final date set;

	proc sql noprint;
		select max(length(&varin.)) into:TXT_LENGTH from &ds_name. WHERE &VARIN. IS not NULL;
	quit;

	%local i index iorDef;
	%if %bquote(&dsout) = %then %let dsout = &ds_name.;
	%let i_end = %SYSEVALF(&TXT_LENGTH./&deflen.,ceil);

	data &dsout.;
		set &ds_name.;

		%linebreaks(&VARIN.,&DEFLEN.,&SEP.,breakchars=&breakchars.);

		%if &i_end. < &defcol. %then %let iorDef = &defcol.;
			%else %let iorDef = &i_end;

		&varout = scan(&varin.,1,"&sep.");

		%do i = 2 %to &iorDef.;
			
			%let index = %eval(&i+&startNum-2);
			%if %bquote(&varout2.)^= %then %do;

				%if %length(&varout.&index.) le 8 %then  &varout.&index. = scan(&varin.,&i.,"&sep."); 
					%else  &varout2.&index. = scan(&varin.,&i.,"&sep.");;

			%end; %else &varout.&index. = scan(&varin.,&i.,"&sep.");;

		%end;

	run; 

%mend make_col;


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
