%macro setalign(start,count,columns=,alg=,ind=,fstInd=,across=&FALSE.,endCol=&false.,strictMod=&false.,
	Suffix=,Prefix=col);
 %* v 2.4.2b;
 %if &alg.^= and &ind.^= and &strictMod. %then %do; %error(%str(Please set only one parameter !)); %return; %end;

 %local offsetAlg i;

 %if &alg.^= and &ind. ^= %then %let offsetAlg = indent = &ind.,dec_align = &alg.;
  %else	%if &alg.^= %then %let offsetAlg = dec_align = &alg.;
   %else %let offsetAlg = indent = &ind.;;
  	
 %if %bquote(&fstInd.) ^= %then %let offsetAlg = &offsetAlg. ,first_line_indent = &fstInd.;;

 %if %bquote(&columns.) = %then %do;

	%local colName innerCounter;
	%if &across. %then %let colName = %nrstr(_c&i._);
		%else %let colName = %nrstr(&Prefix.&i.&Suffix.);;

	%if &endCol. %then %let innerCounter = &count.;
		%else %let innerCounter = %eval(&start.+&count.-1);;

	 %do i = &start. %to &innerCounter.;
	 	%rtf_style(%unquote(&colName.),&offsetAlg.); 
	 %end;

 %end; %else %do;

	%local word;
	%do %while(%get_word(&columns., i, word));
		%rtf_style(&word.,&offsetAlg.);
	%end;

 %end;

%mend setalign;


%*endCol - number of last column;



/**** TEST

%setalign(2,4,ind=3,endcol=0,across=1);


*********/

/*************

2.4.1
*add Suffix param , for col;


2.4.2
*add Prefix param , for col; :D

*************************/
