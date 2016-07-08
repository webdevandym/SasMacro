%macro getblflag(inds=&domain._ALL,out=&domain,sortvar=,datevar=&domain.DTC,time=&TRUE);

	/*Define call macro: %getblflag(out=pre&domain.,sortvar=USUBJID &domain.CAT ,datevar=&domain.DTC);*/
	%sort(&domain._ALL, &sortvar. &datevar.);

	data _getbl_temp;
		merge &inds.(in = in1)
			    DM (in = inDM keep = USUBJID RFSTDTC);
		by USUBJID;
		if in1*inDM;

		%if &time. %then %do;
			*get date whith time;
			if ^missing(RFSTDTC) and ^missing(&domain.DTC) then
				if input(&datevar.,is8601dt.) <= input(RFSTDTC,is8601dt.) and ^missing(&domain.ORRES) then pre&domain.BLFL = 1;

		%end; %else %do;
			*get date out of time;
			if ^missing(RFSTDTC) and ^missing(&domain.DTC) then
				if input(&datevar.,is8601da.) <= input(scan(RFSTDTC,1,"T"),is8601da.) and ^missing(&domain.ORRES) then pre&domain.BLFL = 1;

		%end;

	run;


	%sort(getbl_temp_, &sortvar.  pre&domain.BLFL);

	data &out.;
		set getbl_temp_;
		by &sortvar. pre&domain.BLFL;
		if last.pre&domain.BLFL and pre&domain.BLFL= 1 then &domain.BLFL = "Y";
		&domain.seq=.;		
	run;

%mend getblflag;
