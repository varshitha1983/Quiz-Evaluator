%{
#include "y.tab.h"  // Include parser header
#undef YY_DEBUG
%}

%%

"QUIZ"                  { return QUIZ; }
"QUESTION"              { return QUESTION; }
"TYPE"                  { return TYPE; }
"OPTIONS"               { return OPTIONS; }
"CORRECT"               { return CORRECT; }
"TRUE_FALSE"            { return TRUE_FALSE; }
"MCQ"                   { return MCQ; }
"NUMERIC"               { return NUMERIC; }
"FILL_IN_BLANK"         { return FILL_IN_BLANK; }
"THRESHOLD"             { return THRESHOLD; }

\"[^\"]*\"              { yylval.str = strdup(yytext + 1); yylval.str[strlen(yylval.str) - 1] = '\0'; return STRING; }  // Match strings without quotes
[0-9]+                  { yylval.num = atoi(yytext); return NUMBER; }    // Match numbers

[ \t\n]+                { /* Skip whitespace */ }

.                       { printf("Unexpected character: %s\n", yytext); }

%%
