%macro getUNdate(indate,delLeng,monLeng);
	
	%if %bquote(&delLeng)= %then %let delLeng = 0;;
	%if %bquote(&monLeng)= %then %let monLeng = 3;;

	if &indate ^="" then do;
		day = substr(&indate,1,2);
		month = substr(&indate,%eval(3+&delLeng),&monLeng.);
		year = substr(&indate,%eval(3+&monLeng.+&delLeng*2),4);
		if day in("00" "__") then day = "UN";
		if month in ("000" "__" "___") then month = "UN";
		if year in ("0000" "__" "___" "____") then year = "UN";
	end;

%mend getUNdate;
