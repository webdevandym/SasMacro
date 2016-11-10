%macro ColorMe_FDK(invars=&g_key_FDK. &g_compare_FDK.,keyVars=&g_key_FDK.,indent=,fIndent=,decAlg=,
	putColor=BLUE,skipColor=);

	%if &g_FileExist_FDK. %then %do;

	%*Initialization local macro-vars, and generate amount of elements;
		%local i varin CountKey FlagColumnsName ChkMulti_fi ChkMulti_li ChkMulti_dec vindent vfindent vdec;
		%if &skipColor. = %then %let skipColor = %bquote(__);
		%if &keyVars. ^= %then %let CountKey = %sysfunc(countw(&keyVars.));
		%let ChkMulti_fi = &false.;
		%let ChkMulti_li = &false.;
		%let ChkMulti_dec = &false.;

	%* Test _row_ and painting;
		define flag_all_FDK / display noprint ;	
		 compute flag_all_FDK;
	 		  if (flag_all_FDK="Y") then call
					define(_row_, 'style', "style=[color=&putColor.]" );
	  	 endcomp;

	%* Test all _col_ for painting;
		%do %while(%get_word(&invars., i, varin));	

			%if &i.>&CountKey. %then %let FlagColumnsName = %scan(&g_flagVars_FDK.,%eval(&i.-&CountKey.+1)," "); 

			column rtf_&varin._StyleCol;
	  		define rtf_&varin._StyleCol / computed noprint;
			%if &i. > &CountKey. %then 
				define &FlagColumnsName. / display noprint;;

			compute rtf_&varin._StyleCol;
				%getStyle_FDK; 	 
				%if &i. > &CountKey. %then %do;
					if (&FlagColumnsName.="Y") then allStyle_FDK = catx(" ",color_FDK,style_FDK);
						else %end; allStyle_FDK = strip(style_FDK); 
				if ^missing(allStyle_FDK) then call define("&varin.", 'style', 'style=[' !! strip(allStyle_FDK) !!']' );
	   		endcomp;
		%end;
	%end;
%mend ColorMe_FDK;

%macro getStyle_FDK(index=&i.,skipIt=&skipColor.,useColor=&putColor.,fi=&&fIndent.,li=&&Indent.,dec=&&decAlg.,
	useVar=&Varin.);

%*create indent, and skip empty value or variable-value;
		length style_FDK color_FDK allStyle_FDK $200;
		style_FDK = '';
		color_FDK ='';
	
		%OverAllValue(fi,vfindent);
		%OverAllValue(li,vindent);
		%OverAllValue(dec,vdec);

		%if %bquote(&vfindent.) ^= %then %do;
			if ^missing(&vfindent.) then do;
				_fi_FDK = &vfindent. -  coalesce(&vindent., 0);
				style_FDK = catt(style_FDK,"\fi",(_fi_FDK)*20*&g_font_size);
			end;
		%end;

		%if %bquote(&vindent.) ^= %then
			if ^missing(&vindent.) then style_FDK = catt(style_FDK,"\li",(&vindent.)*20*&g_font_size);;

		%if %bquote(&vdec.) ^= %then
			if ^missing(&vdec.) then style_FDK = catt(style_FDK,"\tqdec\tx",(&vdec.)*20*&g_font_size);;

		%if ^%index(&skipIt.,&useVar.) and &index. > &CountKey. %then color_FDK = catt("color=","&useColor.");;

		if ^missing(style_FDK) then	style_FDK = catt("pretext='",'(*ESC*)R"',strip(style_FDK)," '");

%mend getStyle_FDK;

%macro OverAllValue(inValue,outValue);

	%if ^&&ChkMulti_&inValue. %then 
		%let &&outValue. = %sysfunc(prxchange(%str(s/\.(?!\d)//),-1,%scan(&&&inValue,&index," ")));

	%if %index(&&&outValue.,+) %then %do;
		%let ChkMulti_&inValue. = &true.;
		%let &outValue. = %sysfunc(compress(&&&outValue.,+));
	%end;

%mend;
/**************TEST*******************/
/*%let g_key_FDK = col1;*/
/*%let g_compare_FDK = col2 col3;*/
/*%ColorMe_FDK(indent=2 0 4,fIndent=3 5 .,decAlg=. . 5);*/
/**************....*******************/

%*final version (maybe :D);
