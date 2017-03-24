/****************************************************/
/* File: parse.h                                    */
/* The parser interface for the TINY compiler       */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/

#ifndef _PARSE_H_
#define _PARSE_H_


int yyerror (char * message);

/* yylex calls getToken to make Yacc/Bison output
* compatible with ealier versions of the TINY scanner
*/
static int yylex (void);
/* Function parse returns the newly
 * constructed syntax tree
 */
TreeNode * parse(void);

#endif
