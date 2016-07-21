%macro getblflag(inds=&domain._ALL,out=&domain,sortvar=USUBJID &domain.CAT &domain.TESTCD,
					datevar=&domain.DTC,time=&TRUE,tagsort=&false.);
	%local dateFormat;

	%sort(&inds., &sortvar. &datevar.,tagsort=&tagsort.);

	%if &time. %then %let dateFormat = is8601dt;
		%else %let dateFormat = is8601da;;

	data _getbl_temp;
		merge &inds.(in = in1)
			  DM (in = inDM keep = USUBJID RFSTDTC);
		by USUBJID;
		if in1*inDM;
			
		if ^missing(RFSTDTC) and ^missing(&domain.DTC) and ^missing(&domain.ORRES) then	do;
			if index(&datevar.,"T") then do;

				%getBlPreFlag(&datevar.,&dateFormat.);

			end; else do;

				%getBlPreFlag(&datevar.,is8601da);

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

%macro getBlPreFlag(date,format);
	
	%if %substr(&&format,%length(&&format.),1) ^= . %then %let format = &format..;;
	%local procVar DMVar;
	%localvars(procVar DMVar);
	
	&procVar. = input(&date.,&format.);
	&DMVar. = input(RFSTDTC,&format.);
	if &procVar. < &DMVar. then pre&domain.BLFL = 1;
		else if &procVar. > &DMVar. then pre&domain.LSTFL = 1;

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
