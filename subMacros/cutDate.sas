%macro cutDate(stDate=,EndDate=,cutThis=&before_cut.,deleteRec=&False.,incut_date=&cut_date.,
				newDate=&False.,ongoing=&false.,oneDate=&false.);

		%if &cutThis. %then %do;
			%local word i;
			%do %while(%get_word(&stDate, i, word));

				if input(scan(&word.,1,"T"),??is8601da.) > &incut_date. then cd_deleteThis = "Y";

					%if ^&oneDate. %then %do;
						%let endDtTmp = %scan(&EndDate.,&i," ");
						else if input(scan(&endDtTmp.,1,"T"),??is8601da.) > &incut_date. then do;

							%if &newDate. %then &endDtTmp. = put(&incut_date.,is8601da. -l); 
								%else &endDtTmp. = "";; 
							cd_newDate = "Y"; 
							%if &ongoing. and ^&newDate. %then &domain.ENRF="ONGOING";;

						end;
					%end;
	
			%end;
			%if &deleteRec. %then if cd_deleteThis ^= "Y";;
		%end;

%mend cutDate;
