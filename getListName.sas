%macro getListName(progName,InId,listingName);
	%global &listingName.;
	data title;
		%read_title;
		if prog = "&prog." and prgid = &InId.;
		call symputx("&listingName",strip(substr(prgtype,1,1)!!number));
	run;
%mend;