%macro getblflag(inds=&domain._ALL,out=&domain,sortvar=USUBJID &domain.CAT &domain.TESTCD,
					datevar=&domain.DTC,time=&TRUE);
	%local dateFormat;

	%sort(&inds., &sortvar. &datevar.);

	%if &time. %then %let dateFormat = is8601dt.;
		%else %let dateFormat = is8601da.;;

	data _getbl_temp;
		merge &inds.(in = in1)
			  DM (in = inDM keep = USUBJID RFSTDTC);
		by USUBJID;
		if in1*inDM;
		
		if ^missing(RFSTDTC) and ^missing(&domain.DTC) and ^missing(&domain.ORRES) then		
				if input(&datevar.,&dateFormat.) <= input(RFSTDTC,&dateFormat.) then pre&domain.BLFL = 1;
	run;

	proc datasets nolist;
  		modify _getbl_temp;
  		index create bLineIndex = (&sortvar.  pre&domain.BLFL);
	quit;

	data &out.;
		set _getbl_temp;
		by &sortvar. pre&domain.BLFL;
		if last.pre&domain.BLFL and pre&domain.BLFL then &domain.BLFL = "Y";
	run;

%mend getblflag;
