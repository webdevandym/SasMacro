%macro maketrt(inds,outds,invar=AGECAT1,outvar=all_agecat,fmt=AGECAT.,addtotal=&TRUE.,where=,set_count=);
	
	%local word i;
	%if &set_count. = 2 %then %do;
		*exchange format;
		%let invar = INDOSGRP;
		%let fmt = INDOSGRP.;
	%end;
	
	%do %while(%get_word(&inds, i, word));
		
		%if %scan(&outds,&i," ") = %then %let outds_tm = &word._total; %else %let outds_tm = %scan(&outds,&i," ");;
		*Check Ds name;

		data &outds_tm.;
			set &word.;

			%if %bquote(&where)^=  %then where &where.;;
			&outvar.=input(&invar.,&fmt.);
			%if &set_count. = 3  %then  if &outvar. = 4;;
			output;

			%if &set_count. = 1 %then %do; *if SETI add 3 group;
				if &outvar.= 1 or &outvar.= 2 then do;
					&outvar.= 3;
					output;
				end;
			%end;
		run;
		
		%if &addtotal. and &set_count. = 1 %then %do; *add total group (1,2,4);
			data  &outds_tm.;
				set &outds_tm.;
				output;
				if &outvar. ^= 3 then do;
					&outvar. = 5;
					output;
				end;
			run;
		%end;
		

	%end;
	
	%if &set_count. = 3 %then %let g_treatment_num=1;
			%else %if &set_count. = 2 %then %let g_treatment_num=3;
				%else %let g_treatment_num=5;; %put Get trt group  g_treatment_num=&g_treatment_num.;

%mend maketrt;


