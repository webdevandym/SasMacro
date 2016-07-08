%macro rtf_title(indent, first_line_indent);
  %local li fi;
  %let li = \li%scan(%sysevalf((&indent)*20*&g_font_size),1,".");
  %if %superq(first_line_indent) ^= %then
    %let fi = \fi%scan(%sysevalf((&first_line_indent - &indent)*20*&g_font_size),1,".");
  (*ESC*)R%str(%')&li&fi%str(%')
%mend;
