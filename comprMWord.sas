%macro comprMWord(inPutVariable,compressingChar,useMVar=&false.,oneExp=&true.,sep=%str( )
				,byteSep=187,minDupSymbol=);
	
	%*%put Start: &inPutVariable.;
	
	%local curChar i procCompressChar clearValeu MDPS exceptions SpecQuoted clearValeu; 
	%if %bquote(&minDupSymbol.) = %then %let minDupSymbol = 2;
	%let i = 1;
	%let MDPS = %bquote({&minDupSymbol.,});
	%let exceptions = %str(%(%)%'%"{);
	%let SpecQuoted = %SYSFUNC(BYTE(&byteSep.));
	%let curChar = %qscan(%bquote(&compressingChar), &i,&sep.);


	%do %while(%bquote(&curChar.) ^=);

	 	%if %index(&exceptions.,%bquote(&curChar.)) %then %let procCompressChar = \&curChar.&MDPS.;
			%else %let procCompressChar = &curChar.&MDPS.;
		
		%let clearValeu = %qsysfunc(prxchange(%str(s/(\\|^)(.*)(?={+).*/$2/),-1,%bquote(&procCompressChar.)));
		%let i = %eval(&i + 1);
 		%let curChar = %qscan(%bquote(&compressingChar), &i,&sep.);
		%if &minDupSymbol. = 0 %then %let clearValeu = ;
		%let inPutVariable = %qsysfunc(prxchange(%str(s/&procCompressChar./&clearValeu./),-1,%bquote(&&inPutVariable.)));

		
	%end;

	%*%put Result: &inPutVariable.;

	&inPutVariable.;

%mend comprMWord;

/*%let k = %str(aaaaaa);*/
/*%put &k.;*/
/*%let test =adasssdfdfddddddd;*/
/*%let test2 = %comprMWord(&test.,%str(s d),minDupSymbol=1);*/
/*%put >>>>>&test2<<<<;*/
