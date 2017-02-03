%macro FindDiffKits(inds,outds,key=,compare=,inId=1,repnum=all,path=SAF\prev_&prevSafdate.,maxLen=1000,
	sortVar=,deleteTemplate=&true.,color=2,specFileName=,algorithm=2,specSubjProfile=&false.,
	checkNullDS=,orderNullColumns=,fix_retain=&false.)/minoperator;

%*Initialization global and local macro-vars;
	%global g_flagVars_FDK g_key_FDK g_compare_FDK g_FileExist_FDK;
	%local varin i new_compare base_compare new_key FullName ColNum newIndex newIndex2 
		CountVarsOfKey allVars_FDK regExp;
	
%*Set value to macro-vars;
	%let g_key_FDK = &key;
	%let g_compare_FDK = &compare;
	%let g_flagVars_FDK = ; 
	%let allVars_FDK = &key &compare;
	%if %bquote(&checkNullDS.) = %then %let checkNullDS = 0;

	%if &key. ^= %then %let CountVarsOfKey = %sysfunc(countw(&key));
		%else %do; %put WARNING: FindDiffKits macro -> Key is empty!!!; %return; %end;

%*RegExp: deleting RTF style from dataset for comparing with old version -> &rtf_par. &rtf_break. and etc.;
	%let regExp = "%str(s/\%(\*ESC\*\%)R[\%'\%"][\\\w]+ [\%'\%"]//)"; 

%*get filename auto or static;
	%if %bquote(&specFileName.) = %then %do;
		data title;
			%read_title;
			if prog = "&prog." and prgid = &inid.;
			call symput("FullName",strip(substr(prgtype,1,1)!!number));
		run;
	%end; %else %let FullName = &specFileName.;
	
	%let g_FileExist_FDK = %SYSFUNC(FILEEXIST(&list\&path.\&FullName..rtf));
	%put &g_FileExist_FDK.;

%if ^&checkNullDS. and &g_FileExist_FDK. %then %do;

	%if &specSubjProfile. %then %do;
		%do %while(%get_word(&allVars_FDK, i, varin));
							%local newLabel&i.;

							data _null_;
								set &inds.;
								call symputx("newLabel&i",strip(vlabel(&varin.)));
							run;										
		%end;
	%end;
	%let i = 0;
%*rename input variable,clone and delete special RTF  symbol;
	data _cloned_&inds.(rename = (%do %while(%get_word(&allVars_FDK, i, varin));
									%if &specSubjProfile. %then %let j =%eval(&i-1);
										%else %let j = &i;
									%if &varin # &key %then %do;
											columns&i. = col&j
											%let new_key = &new_key. col&j.;
										%end; %else %do;
												columns&i. = col&j._compare
												%let new_compare = &new_compare col&j._compare;
												%if &specSubjProfile. %then
													%let base_compare = &base_compare col%eval(&i.-1);
												%else %let base_compare = &base_compare col&i.;
											%end;
							 %end;));

		length &allVars_FDK. $&maxLen;
		set &inds.;

		%let i = 0;
		%do %while(%get_word(&allVars_FDK, i, varin));

				orig_col&i = &varin;
				%if &specSubjProfile. %then label orig_col&i  = "&&newLabel&i.";;
				sort_col&i = &varin;
				columns&i = &varin;
				columns&i = strip(prxchange(%str(&regExp.),-1,columns&i));
			%let ColNum = &ColNum &i;
		%end;
		drop &allVars_FDK.;
	run;


%*read file and put down in dataset;
	%read_rtf_table(filename=&list\&path.\&FullName..rtf, repno=&repnum., outds=_qc_FDK,ordercolumns=&ColNum.,
		max_cell_length=&maxLen.);

%*retain all Key columns, spec fix for same table;
	%if %bquote(&orderNullColumns.)^= %then %do;

		%if &orderNullColumns.^= &true. %then %sort(_cloned_&inds.,&orderNullColumns.);
		%local maxColums ColuNumRetainFix;

		%let ColuNumRetainFix = %sysfunc(prxchange(%str(s/\bcol(\d)/$1/),-1,%str(&new_key.)));
		%let maxColums = %scan(&ColuNumRetainFix.,-1);

		data _cloned_&inds.;
			 length col1-col&maxColums. $1000;
			 call missing(of col1-col&maxColums.);

			 set _cloned_&inds.;
			 %retaining_null_col_fix_bug(&ColuNumRetainFix.,&new_key., &maxLen.);
		run;

	%end;

%*preparation two datasets to merge, with selected algorithm;	
	%if &specSubjProfile. %then %do;
		%sort(_cloned_&inds.,&new_key.);
		data _qc_FDK;
			set _qc_FDK;
			temp+1;
			col0=strip(put(temp,best.));
			drop temp;
		run;
	%end; %else %do;
			%sort(_cloned_&inds.,&new_key. &new_compare.);
			%sort(_qc_FDK, &new_key. &base_compare.);

			data _cloned_&inds.;
				set _cloned_&inds.;
				by &new_key.;

				if first.col&CountVarsOfKey. then seq=.;
				seq +1;
			run;
			
			data _qc_FDK;
				set _qc_FDK;
				by &new_key.;

				if first.col&CountVarsOfKey. then seq=.;
				%if &fix_retain %then if col6 in ("Total reported MMSE" , "Total derived MMSE")
					then col5 = "Consciousness";;
				seq +1;
			run;
			%if &fix_retain %then %sort(_qc_FDK, &new_key. &base_compare.);;
		%end;
	
	
%*merge and painting ROW or COL in dataset;
	data _merged_FDK;
		merge _cloned_&inds.(in = in1) _qc_FDK(in = in2);
		by %if ^&specSubjProfile. %then &new_key. seq; %else col0;;
		if in1;

		if in1 and not in2 then do;
			%let i = 0;
			%if &algorithm = 1 %then %do;
				%do %while(%get_word(&ColNum, i, varin));			
						if ^missing (orig_col&i.) then
							orig_col&i = "(*ESC*)R'\chshdng0\chcbpat0\cf&color. '"!!orig_col&i;
					
				%end;
			%end; %else %do;
				flag_all_FDK="Y";
				%let g_flagVars_FDK = &g_flagVars_FDK. flag_all_FDK;
			%end;
		end; else if in1*in2 then do;
				%let i = 0;
				%do %while(%get_word(&base_compare, i, varin));	
	
					%if ^&specSubjProfile. %then %do;
						%let newIndex = %eval(&i. + &CountVarsOfKey.);
						%let newIndex2 = &newIndex.;
					%end; %else %do;
								%let newIndex = &i.;
								%let newIndex2 = %eval(&i. + &CountVarsOfKey.);
							%end;

					if &varin. ^= &varin._compare and ^missing (orig_col&newIndex2.) then
						%if &algorithm = 1 %then 
							orig_col&newIndex. = "(*ESC*)R'\chshdng0\chcbpat0\cf&color. '"!!orig_col&newIndex.;
						%else %do;
							flag_col&newIndex._FDK = "Y";
							%let g_flagVars_FDK = &g_flagVars_FDK. flag_col&newIndex._FDK;
						%end;
				%end;
			end;
	run;
	

	%let i = 0;
	%if &outds = %then %let outds = &inds.;

%*rename variables in the original names;
	data &outds.(rename = (%do %while(%get_word(&allVars_FDK, i, varin));
								orig_col&i = &varin.
							 %end;));
		set _merged_FDK;

		drop &base_compare. &new_key. %if &specSubjProfile. %then col1; %else seq;;
	run;


%*delete template datasets ->_cloned_&inds. _merged_FDK _qc_FDK;
	%if &deleteTemplate %then %do;
		proc datasets lib=work  memtype=data noprint;
			delete _cloned_&inds. _merged_FDK _qc_FDK;
		quit;

	%end;

%end;

	
	%if %bquote(&orderNullColumns.) ^=  and ^&checkNullDS. and &orderNullColumns.^= &true. %then 
		%sort(&outds.,&orderNullColumns.);
	
	%let sortVar = %sysfunc(prxchange(%str(s/\bcol(\d)/sort_col$1/),-1,%str(&sortVar.)));
	
	%if %bquote(&sortVar.) ^= and ^&checkNullDS. %then %sort(&outds.,&sortVar.);

%mend;



%macro retaining_null_col_fix_bug(ordercolumns, pagevars, max_cell_length);

	%local numordercols lastordercol i num;

	%let lastordercol = %scan(&pagevars, -1);
		
      by &pagevars notsorted;
      array ordercolumns[*] 
        %do %while(%get_word(&ordercolumns, i, num));
          col&num
        %end;;
      %let numordercols = %eval(&i - 1);
      array retained[&numordercols] $&max_cell_length _TEMPORARY_;
      drop i;
      
      do i = 1 to &numordercols;

        if ordercolumns[i] ^= '' or (first.&lastordercol. and ordercolumns[i] ^= '') then do;
          retained[i] = ordercolumns[i];
        end; else ordercolumns[i] = retained[i];

      end;

%mend retaining_null_col_fix_bug;
