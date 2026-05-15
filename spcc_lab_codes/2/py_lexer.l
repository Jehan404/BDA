/*
 * python_lexer.l — Simple Python Lexer using Flex
 *
 * HOW TO BUILD AND RUN:
 * ---------------------
 *   flex python_lexer.l
 *   gcc lex.yy.c -o python_lexer -lfl
 *   ./python_lexer input.py
 *
 * WHAT IT HANDLES:
 *   Keywords, Identifiers, Integer & Float literals,
 *   String literals, Operators, Delimiters, Comments, Errors
 */

%{
#include <stdio.h>
int line_num = 1;
%}

%option noyywrap

/* Reusable patterns */
DIGIT    [0-9]
LETTER   [a-zA-Z_]
ID       {LETTER}({LETTER}|{DIGIT})*
INT      {DIGIT}+
FLOAT    {DIGIT}+"."{DIGIT}+
STR_DQ   \"([^\\\"]|\\.)*\"
STR_SQ   \'([^\\\']|\\.)*\'

%%

/* ── Keywords ── */
"if"|"else"|"elif"|"while"|"for"|"def"|"return"|"class"|"import"|"True"|"False"|"None"|"and"|"or"|"not"|"in"|"is"|"pass"|"break"|"continue"
    { printf("Line %d: KEYWORD        (%s)\n", line_num, yytext); }

/* ── Operators ── */
"**"|"//"|"=="|"!="|">="|"<="|"+="|"-="
    { printf("Line %d: OPERATOR       (%s)\n", line_num, yytext); }
[+\-*/%=<>]
    { printf("Line %d: OPERATOR       (%s)\n", line_num, yytext); }

/* ── Delimiters ── */
[()[\]{},:.] { printf("Line %d: DELIMITER      (%s)\n", line_num, yytext); }

/* ── Literals ── */
{STR_DQ}|{STR_SQ}  { printf("Line %d: STRING         (%s)\n", line_num, yytext); }
{FLOAT}             { printf("Line %d: FLOAT          (%s)\n", line_num, yytext); }
{INT}               { printf("Line %d: INTEGER        (%s)\n", line_num, yytext); }

/* ── Identifier (must come after keywords) ── */
{ID}    { printf("Line %d: IDENTIFIER     (%s)\n", line_num, yytext); }

/* ── Ignored ── */
"#".*   { /* single-line comment, skip */ }
[ \t]   { /* whitespace, skip */ }
\n      { line_num++; }

/* ── Anything else is an error ── */
.   { printf("Line %d: UNKNOWN        (%s)\n", line_num, yytext); }

%%

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *f = fopen(argv[1], "r");
        if (!f) { fprintf(stderr, "Cannot open %s\n", argv[1]); return 1; }
        yyin = f;
    }
    yylex();
    return 0;
}