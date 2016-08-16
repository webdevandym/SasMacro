%macro getblflag(inds=&domain._ALL,out=&domain,sortvar=USUBJID &domain.CAT &domain.TESTCD,
					datevar=&domain.DTC,tagsort=&false.,time=,operDT=,operDA=);
	%local dateFormat;

	%setDefOption_getblflag

	%sort(&inds., &sortvar. &datevar.,tagsort=&tagsort.)

	%if &time. %then %let dateFormat = is8601dt;
		%else %let dateFormat = is8601da;

	data _getbl_temp;
		merge &inds.(in = in1)
			  DM (in = inDM keep = USUBJID RFSTDTC);
		by USUBJID;
		if in1*inDM;
			
		if ^missing(RFSTDTC) and ^missing(&domain.DTC) and ^missing(&domain.ORRES) then	do;
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
		if last.pre&domain.BLFL and pre&domain.BLFL then &domain.BLFL = "Y";
		if last.pre&domain.LSTFL and pre&domain.LSTFL then &domain.LSTFL = "Y";
	run;

%mend getblflag;

%macro getBlPreFlag(date,format,logOper=lt);
	
	%if %substr(&&format,%length(&&format.),1) ^= . %then %let format = &format..;
	%local procVar DMVar;
	%localvars(procVar DMVar)
	
	&procVar. = input(&date.,&format.);
	&DMVar. = input(RFSTDTC,&format.);
	if &procVar. &logOper. &DMVar. then pre&domain.BLFL = 1;
		else if &procVar. > &DMVar. then pre&domain.LSTFL = 1;

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
/****ADD missing time



%if %bquote(&missTime.)^= %then %do;

	%local edt_datevar useDate;
	%localvars(edt_datevar);

	if ^index(&datevar.,"T") and &datevar. ^= "" then &edt_datevar = catx("T",&datevar.,"&missTime.");
		else &edt_datevar = &datevar.;
	%let useDate = &edt_datevar.;

%end; %else %let useDate = &datevar.;;


*************/
