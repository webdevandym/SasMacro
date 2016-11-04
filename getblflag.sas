%macro getblflag2(inds=&domain._ALL,out=&domain,sortVar=USUBJID &domain.CAT &domain.TESTCD,
					dateVar=&domain.DTC,resultVar=&domain.ORRES,ReferenceDate=RFSTDTC,
					tagsort=&false.,time=,operDT=,operDA=,additionSort=);

	%local dateFormat MergeSubjectDS PreffixOfVar;
	%let PreffixOfVar = &domain.;

	%setDefOption_getblflag

	%sort(&inds., &sortvar. &additionSort. &datevar.,tagsort=&tagsort.)
	
	%if "&ReferenceDate." ^= "RFSTDTC" %then %do;
		%let MergeSubjectDS = &false.;
		%let PreffixOfVar = A;
	%end; %else %let MergeSubjectDS = &true.;

	%if &time. %then %let dateFormat = is8601dt;
		%else %let dateFormat = is8601da;

	data _getbl_temp;
		%if ^&MergeSubjectDS. %then %do; 
			set &inds.;
		%end; %else %do;
				merge &inds.(in = in1)
					  DM (in = in2 keep = USUBJID RFSTDTC);
				by USUBJID;
				if in1*in2;
			%end;
			
		if ^missing(&ReferenceDate.) and ^missing(&dateVar.) and ^missing(&resultVar.) then	do;
			if index(&datevar.,"T") then do;

				%getBlPreFlag(&datevar.,&dateFormat.,logOper=&operDT.)

			end; else do;

				%getBlPreFlag(&datevar.,is8601da,logOper=&operDA.)

			end;
		end;

	run;

	proc datasets nolist;
  		modify _getbl_temp;
  		index create BLineIndex = (&sortvar.  pre&domain.BLFL pre&domain.LSTFL);
	quit;

	data &out.;
		set _getbl_temp;
		by &sortvar. pre&domain.BLFL pre&domain.LSTFL;
		if last.pre&domain.BLFL and pre&domain.BLFL then &PreffixOfVar.BLFL = "Y";
		if last.pre&domain.LSTFL and pre&domain.LSTFL then &PreffixOfVar.LSTFL = "Y";
	run;

%mend getblflag2;

%macro getBlPreFlag(date,format,logOper=lt);
	
	%if %sysfunc(compress(&&format.,.,k)) = %then %let format = &format..;
	%local procVar RefVar;
	%localvars(procVar RefVar)
	
	&procVar. = input(&date.,&format.);
	&RefVar. = input(&ReferenceDate.,&format.);
	if &procVar. &logOper. &RefVar. then pre&domain.BLFL = 1;
		else if &procVar. > &RefVar. then pre&domain.LSTFL = 1;

%mend getBlPreFlag;

%macro setDefOption_getblflag;

	%*use datetime or date;
	%if &time = %then 
		%if %symexist(g_getblflag_time) %then %let time = &g_getblflag_time.;
			%else %let time = &true.;
	
	%*set datetime operator;
	%if &operDT = %then 
		%if %symexist(g_getblflag_operDT) %then %let operDT = &g_getblflag_operDT.;
			%else %if &time. %then %let operDT = lt;
						%else %let operDT = le;

	%*set date operator;
	%if &operDA = %then 
		%if %symexist(g_getblflag_operDA) %then %let operDA = &g_getblflag_operDA.;
			%else %let operDA = le;

%mend;


/*%substr(&&format,%length(&&format.),1) ^= .*/

/****ADD missing time , old code if need can used




%if %bquote(&missTime.)^= %then %do;

	%local edt_datevar useDate;
	%localvars(edt_datevar);

	if ^index(&datevar.,"T") and &datevar. ^= "" then &edt_datevar = catx("T",&datevar.,"&missTime.");
		else &edt_datevar = &datevar.;
	%let useDate = &edt_datevar.;

%end; %else %let useDate = &datevar.;;


*************/
