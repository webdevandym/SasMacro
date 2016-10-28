%macro MAKE_COL(DS_IN,DS_OUT,varin,varout,varout2,DEFCOL=3,DEFLEN=200,sep=%str(@),mergevar=&FALSE,
				invarlen=2000,catdel=%str( ),nodrop=&FALSE,breakchars=%str( -/:)); 

/*============================================================================*/
/*->divides the text into columns with a predetermined length*/
/*DS_IN -> input dataset*/
/*DS_OUT -> output dataset*/
/*varin -> input variable for modification*/
/*varout -> output variable*/
/*varout2 -> output variable after index >9, if varout length > 6 [not necessary, default: miss](SDTM)*/
/*DEFCOL -> define columns in spec [default: 3]*/
/*DEFLEN -> define length of columns [default: 200]*/
/*sep -> delimiter for splitting the text [default: @]*/
/*mergevar -> default: FALSE (connect all the variables suffix)*/
/*invarlen -> the length of time variable to merge columns [default: 2000]*/
/*catdel -> delimiter function CATX("&catdel.", <variale>) [default:<space>]*/
/*nodrop -> keep input variable (default: &FASLE)*/
/*breakchars -> chars for %linebreaks; [default: %str( -/:)] */
/*+check error (input data)*/
/*+auto upcase in and out variable*/
/**/
/*Author:  Andrey Maskharashvili*/
/*V. 1.10.2 (realise: 20160211 final)*/
/*==============================================================================*/
	%if %sysfunc(exist(&DS_IN))  %then %do; /*check existing input dataset*/

		%local rc dsid result PREFVAR var_tmp varLen varLen2;
		%let PREFVAR = &TRUE;
		%let varLen = &FALSE;
		%let varLen2 = &FALSE;
		%let VAROUT = %upcase(&VAROUT.);
		%let VARIN = %upcase(&VARIN.);

		%let dsid=%sysfunc(open(&DS_IN));	
		%if %sysfunc(varnum(&dsid,&VARIN.)) gt 0 %then %let result = &TRUE;  /*Check existing variable*/
		%else %let result = &FALSE;
		%let rc=%sysfunc(close(&dsid));

		%if &mergevar. %then %do;

			proc sql noprint; /*get var name in &vlist from input dataset*/ 
	 			select name into :vlist separated by ' '
	 				 from dictionary.columns
	  					where memname=upcase("&DS_IN");
	 		quit;

	 		data _null_; /*checking variables consoles*/
				%if ^%index(&vlist.,&VARIN.) %then %let PREFVAR = &FALSE;
			run;
			
		%end;

		/*%put &result;*/
		%if &PREFVAR. %then %do; 

			%if &deflen. gt 0 and &invarlen. gt 0  %then %do; /*check non-missing and positive vars */
				
				%if &mergevar. %then %do; /*connect all the variables suffix*/
					data _makecol_temp;
						length &VARIN._all $&invarlen.;
						set &DS_IN.;
						&VARIN._all = catx("&catdel.",of &VARIN.:);
					run;
					%let DS_IN = _makecol_temp;
					%let VARIN = &VARIN._all;
				%end;					 /*end of merge vars */

				%if &result. or &mergevar. %then %do; /*check existing in var or mergevar=&TRUE */

					proc sql noprint; /*returt max length of input var */
						select max(length(&VARIN.)) into:TXT_LENGTH from &DS_IN. WHERE &VARIN. IS not NULL;
					quit;

						/*%if &TXT_LENGTH. > 0 %then %do; /*check existing in-var*/

					data _null_; /*get length of the longest text*/
						call symput ('COLNUM',put(CEIL(&TXT_LENGTH./&DEFLEN.),best.));
					run;

					data &DS_OUT.; /*break the text into multiple columns*/
						set &DS_IN.;
						%linebreaks(&VARIN.,&DEFLEN.,&SEP.,breakchars=&breakchars.);
						%if &COLNUM. lt &DEFCOL. %then %let IorDef = &DEFCOL.;
						%else %let IorDef = &COLNUM.;
							&VAROUT = scan(&VARIN.,1,"&SEP.");
							%do i = 1 %to &iorDef.-1;
								%if &i. < 10 %then %do;
									&varout.&i. = scan(&varin.,&i.+1,"&sep.");
								%end; 
								%else %do;
									%if &varout2 ^= %then %do; /*variable for col after i=9, SDTM . If var2 miss get var*/
										%let var_tmp = &varout2.&i.;
										%if %length(&var_tmp.) > 8 %then %let varLen2 = &TRUE; /*Check length of var2 with index*/
									 %end;
									 %else %do;
										%let var_tmp = &varout.&i.;
										%if %length(&var_tmp.) > 8 %then %let varLen = &TRUE; /*Check length of var with index*/
									 %end; /* ENd check var */
								 &var_tmp. = scan(&varin.,&i.+1,"&sep.");
								%end;
							%end;

						%if &varLen2. %then %do; %warning("Variable &varout2. > 6 symbol! Check."); %end;
						%if &varLen.  %then %do; %warning("Variable &varout.10 and etc. > 8 symbol. Please check!"); %end;

					run;

					%if ^&nodrop %then %do; /*drop input var whith nodrop = &false */
						data &DS_OUT.;
							set &DS_OUT.;
							drop %scan(&VARIN.,1,"_"):;
						run;
					%end;

					%if  &deflen. ge &invarlen. %then 
					  %warning(%str(Length of define columns (DEFLEN val: &DEFLEN.) great then or equal temporary variable storage (INVARLEN val: &INVARLEN.). Check the input data, the results may be incorrect!));

						/*%end; /*end, check existing in-var*/
						/*%else %error(%scan(&varin.,1,"_") %str(not exists in input dataset));*/

				%end; /*end, check existing in var or mergevar=&TRUE */
				%else %error(%str(Var &VARIN. not exists in &DS_IN));
		 
			%end; /*end, check non-missing and positive vars */
			%else %error(%str(Length of define columns (DEFLEN val: &DEFLEN.) or temporary variable storage (INVARLEN val: &INVARLEN.) -> missing, less then or equal to 0. Check input Data !!!)); 

		%end;
		%else %error(%str(Var &VARIN. not exists in &DS_IN));

	%end; /*end, check existing input dataset*/
	%else %error(%str(Dataset [&DS_IN] not exists)); 


%mend MAKE_COL;