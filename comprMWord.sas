%macro comprMWord(inPutVariable,compressingChar,useMVar=&false.,oneExp=&true.,sep=%str( )
				,byteSep=187,minDupSymbol=);
	
/*	%put Start: &inPutVariable.;*/
	
	%local curChar i procCompressChar clearValeu MDPS exceptions SpecQuoted clearValeu getPartRegExp; 

	%if %bquote(&minDupSymbol.) = %then %let minDupSymbol = 2;
	%if &minDupSymbol. > 0 %then %let getPartRegExp = $2;

	%let i = 1;
	%let MDPS = %bquote({&minDupSymbol.,});
	%let exceptions = %str(%(%)%'%"{);
	%let SpecQuoted = %SYSFUNC(BYTE(&byteSep.));
	%let curChar = %qscan(%bquote(&compressingChar), &i,&sep.);
	

	%do %while(%bquote(&curChar.) ^=);
	
	 	%if %index(&exceptions.,%bquote(&curChar.)) %then %let procCompressChar = \&curChar.&MDPS.;
			%else %let procCompressChar = &curChar.&MDPS.;

		%let clearValeu = %qsysfunc(prxchange(%str(s/(\\|^)(.*)(?={+).*/&getPartRegExp./),-1,%bquote(&procCompressChar.)));
		%let i = %eval(&i + 1);
 		%let curChar = %qscan(%bquote(&compressingChar), &i,&sep.);
		
		%let inPutVariable = %qsysfunc(prxchange(%str(s/&procCompressChar./&clearValeu./),-1,%bquote(&&inPutVariable.)));

		
	%end;

/*	%put Result: &inPutVariable.;*/

	&inPutVariable.;

%mend comprMWord;



/******************TEST************************/
/*dm log "clear";*/
/**/
/*%let k = %str(aaaaaa);*/
/*%put &k.;*/
/*%let test =adaasssdf>s<dfddddddd((((((((((;*/
/*%put &test.;*/
/*%let test2 = %comprMWord(%bquote(&test.),%str(a s d %( <),minDupSymbol=2);*/
/*%put >>>>>&test2<<<<;*/
/******************TEST************************/

