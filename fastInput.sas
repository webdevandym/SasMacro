%macro fastInput(vars,del=%str(-),alg=input,informat=&true.)/minoperator;

	%local word i invar outvar fmt;
	%do %while(%get_word(&vars, i, word));

		%let outvar = %scan(&word,1,"&del.");
		%let invar = %scan(&word,2,"&del.");
		%let fmt = %scan(&word,3,"&del.");

		%if &alg # (input put) %then %do;
			%if %bquote(&fmt.) = %then %let fmt = ny.;
			%if &informat. and %substr(&fmt.,1,1) ^= $ %then %let fmt = $&fmt.;
			%if %substr(&fmt.,%length(&fmt.)) ^= . %then %let fmt = &fmt..;
			&outvar = &alg(&invar.,&fmt.);
		%end; %else &outvar = &alg(&invar.);;

	%end;

%mend;
