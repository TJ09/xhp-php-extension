/*
  +----------------------------------------------------------------------+
  | XHP                                                                  |
  +----------------------------------------------------------------------+
  | Copyright (c) 1998-2019 Zend Technologies Ltd. (http://www.zend.com) |
  | Copyright (c) 2009-2014 Facebook, Inc. (http://www.facebook.com)     |
  +----------------------------------------------------------------------+
  | This source file is subject to version 2.00 of the Zend license,     |
  | that is bundled with this package in the file LICENSE.ZEND, and is   |
  | available through the world-wide-web at the following url:           |
  | http://www.zend.com/license/2_00.txt.                                |
  | If you did not receive a copy of the Zend license and are unable to  |
  | obtain it through the world-wide-web, please send a note to          |
  | license@zend.com so we can mail you a copy immediately.              |
  +----------------------------------------------------------------------+
*/

%{
#include "xhp.hpp"
// PHP's if/else rules use right reduction rather than left reduction which
// means while parsing nested if/else's the stack grows until it the last
// statement is read. This is annoying, particularly because of a quirk in
// bison.
// http://www.gnu.org/software/bison/manual/html_node/Memory-Management.html
// Apparently if you compile a bison parser with g++ it can no longer grow
// the stack. The work around is to just make your initial stack ridiculously
// large. Unfortunately that increases memory usage while parsing which is
// dumb. Anyway, putting a TODO here to fix PHP's if/else grammar.
#define YYINITDEPTH 500
%}

%{
#undef yyextra
#define yyextra static_cast<yy_extra_type*>(xhpget_extra(yyscanner))
#undef yylineno
#define yylineno yyextra->first_lineno
#define cr(s) code_rope(s, yylineno)

using namespace std;

static void yyerror(void* yyscanner, void* _, const char* error) {
  if (yyextra->terminated) {
    return;
  }
  yyextra->terminated = true;
  yyextra->error = error;
}

static void replacestr(string &source, const string &find, const string &rep) {
  size_t j;
  while ((j = source.find(find)) != std::string::npos) {
    source.replace(j, find.length(), rep);
  }
}

%}

%expect 0
%name-prefix "xhp"
%pure-parser
%parse-param { void* yyscanner }
%parse-param { code_rope* root }
%lex-param { void* yyscanner }
%error-verbose

%left T_INCLUDE T_INCLUDE_ONCE T_EVAL T_REQUIRE T_REQUIRE_ONCE
%left ','
%left T_LOGICAL_OR
%left T_LOGICAL_XOR
%left T_LOGICAL_AND
%right T_PRINT
%right T_YIELD
%right T_YIELD_FROM
%left '=' T_PLUS_EQUAL T_MINUS_EQUAL T_MUL_EQUAL T_DIV_EQUAL T_CONCAT_EQUAL T_MOD_EQUAL T_AND_EQUAL T_OR_EQUAL T_XOR_EQUAL T_SL_EQUAL T_SR_EQUAL T_POW_EQUAL
%left '?' ':'
%right T_COALESCE
%left T_BOOLEAN_OR
%left T_BOOLEAN_AND
%left '|'
%left '^'
%left '&'
%nonassoc T_IS_EQUAL T_IS_NOT_EQUAL T_IS_IDENTICAL T_IS_NOT_IDENTICAL T_SPACESHIP
%nonassoc '<' T_IS_SMALLER_OR_EQUAL '>' T_IS_GREATER_OR_EQUAL
%left T_SL T_SR
%left '+' '-' '.'
%left '*' '/' '%'
%right '!'
%nonassoc T_INSTANCEOF
%right '~' T_INC T_DEC T_INT_CAST T_DOUBLE_CAST T_STRING_CAST T_UNICODE_CAST T_BINARY_CAST T_ARRAY_CAST T_OBJECT_CAST T_BOOL_CAST T_UNSET_CAST '@'
%right T_POW
%right '['
%nonassoc T_NEW T_CLONE
%left T_NOELSE
%left T_ELSEIF
%left T_ELSE
%left T_ENDIF
%right T_STATIC T_ABSTRACT T_FINAL T_PRIVATE T_PROTECTED T_PUBLIC
%right T_DOUBLE_ARROW

%token T_EXIT 326
%token T_IF 327

%token T_LNUMBER 317
%token T_DNUMBER 318
%token T_STRING 319
%token T_STRING_VARNAME 324
%token T_VARIABLE 320
%token T_NUM_STRING 325
%token T_INLINE_HTML 321
%token T_ENCAPSED_AND_WHITESPACE 322
%token T_CONSTANT_ENCAPSED_STRING 323

%token T_BACKTICKS_EXPR /* new in XHP; replaces '`' backticks_expr '`' */
%token T_ECHO 328
%token T_DO 329
%token T_WHILE 330
%token T_ENDWHILE 331
%token T_FOR 332
%token T_ENDFOR 333
%token T_FOREACH 334
%token T_ENDFOREACH 335
%token T_DECLARE 336
%token T_ENDDECLARE 337
%token T_AS 338
%token T_SWITCH 339
%token T_ENDSWITCH 340
%token T_CASE 341
%token T_DEFAULT 342
%token T_BREAK 343
%token T_CONTINUE 344
%token T_GOTO 345
%token T_FUNCTION 346
%token T_CONST 347
%token T_RETURN 348
%token T_TRY 349
%token T_CATCH 350
%token T_FINALLY 351
%token T_THROW 352
%token T_USE 353
%token T_GLOBAL 355
%token T_VAR 356
%token T_UNSET 357
%token T_ISSET 358
%token T_EMPTY 359
%token T_HALT_COMPILER 360
%token T_CLASS 361
%token T_INTERFACE 363
%token T_EXTENDS 364
%token T_IMPLEMENTS 365
%token T_OBJECT_OPERATOR 366
%token T_DOUBLE_ARROW 268
%token T_LIST 367
%token T_ARRAY 368
%token T_CALLABLE 369
%token T_CLASS_C 373
%token T_METHOD_C 375
%token T_FUNC_C 376
%token T_TRAIT_C 374
%token T_LINE 370
%token T_FILE 371
%token T_COMMENT 377
%token T_DOC_COMMENT 378
%token T_OPEN_TAG 379
%token T_OPEN_TAG_WITH_ECHO 380
%token T_OPEN_TAG_FAKE
%token T_CLOSE_TAG 381
%token T_WHITESPACE 382
%token T_HEREDOC
%token T_CURLY_OPEN 386
%token T_DOLLAR_OPEN_CURLY_BRACES 385
%token T_PAAMAYIM_NEKUDOTAYIM 387
%token T_NAMESPACE 388
%token T_NS_C 389
%token T_DIR 372
%token T_NS_SEPARATOR 390
%token T_ELLIPSIS 391
%token T_TRAIT 362
%token T_INSTEADOF 354
%token T_YIELD 267
%token T_COALESCE 282

%token T_XHP_WHITESPACE
%token T_XHP_TEXT
%token T_XHP_ATTRIBUTE
%token T_XHP_CATEGORY
%token T_XHP_CATEGORY_LABEL
%token T_XHP_CHILDREN
%token T_XHP_ANY
%token T_XHP_PCDATA
%token T_XHP_COLON
%token T_XHP_HYPHEN
%token T_XHP_BOOLEAN
%token T_XHP_NUMBER
%token T_XHP_MIXED
%token T_XHP_STRING
%token T_XHP_ENUM
%token T_XHP_FLOAT
%token T_XHP_CALLABLE
%token T_XHP_REQUIRED
%token T_XHP_LABEL

%token T_XHP_TAG_LT
%token T_XHP_TAG_GT
%token T_TYPELIST_LT
%token T_TYPELIST_GT
%token T_UNRESOLVED_OP
%token T_UNRESOLVED_LT

%token T_PUBLIC 316
%token T_PROTECTED 315
%token T_PRIVATE 314
%token T_FINAL 313
%token T_ABSTRACT 312
%token T_STATIC 311
%token T_ENDIF 310
%token T_ELSE 309
%token T_ELSEIF 308
%token T_CLONE 306
%token T_NEW 305
%token T_POW 304
%token T_UNSET_CAST 303
%token T_BOOL_CAST 302
%token T_OBJECT_CAST 301
%token T_ARRAY_CAST 300
%token T_STRING_CAST 299
%token T_DOUBLE_CAST 298
%token T_INT_CAST 297
%token T_DEC 296
%token T_INC 295
%token T_INSTANCEOF 294
%token T_SR 293
%token T_SL 292
%token T_IS_GREATER_OR_EQUAL 291
%token T_IS_SMALLER_OR_EQUAL 290
%token T_SPACESHIP 289
%token T_IS_NOT_IDENTICAL 288
%token T_IS_IDENTICAL 287
%token T_IS_NOT_EQUAL 286
%token T_IS_EQUAL 285
%token T_BOOLEAN_AND 284
%token T_BOOLEAN_OR 283
%token T_POW_EQUAL 281
%token T_SR_EQUAL 280
%token T_SL_EQUAL 279
%token T_XOR_EQUAL 278
%token T_OR_EQUAL 277
%token T_AND_EQUAL 276
%token T_MOD_EQUAL 275
%token T_CONCAT_EQUAL 274
%token T_DIV_EQUAL 273
%token T_MUL_EQUAL 272
%token T_MINUS_EQUAL 271
%token T_PLUS_EQUAL 270
%token T_YIELD_FROM 269
%token T_PRINT 266
%token T_LOGICAL_AND 265
%token T_LOGICAL_XOR 264
%token T_LOGICAL_OR 263
%token T_REQUIRE_ONCE 262
%token T_REQUIRE 261
%token T_EVAL 260
%token T_INCLUDE_ONCE 259
%token T_INCLUDE 258
%%

start:
  top_statement_list {
    *root = $1;
  }
;

reserved_non_modifiers:
  T_INCLUDE | T_INCLUDE_ONCE | T_EVAL | T_REQUIRE | T_REQUIRE_ONCE | T_LOGICAL_OR | T_LOGICAL_XOR | T_LOGICAL_AND
| T_INSTANCEOF | T_NEW | T_CLONE | T_EXIT | T_IF | T_ELSEIF | T_ELSE | T_ENDIF | T_ECHO | T_DO | T_WHILE | T_ENDWHILE
| T_FOR | T_ENDFOR | T_FOREACH | T_ENDFOREACH | T_DECLARE | T_ENDDECLARE | T_AS | T_TRY | T_CATCH | T_FINALLY
| T_THROW | T_USE | T_INSTEADOF | T_GLOBAL | T_VAR | T_UNSET | T_ISSET | T_EMPTY | T_CONTINUE | T_GOTO
| T_FUNCTION | T_CONST | T_RETURN | T_PRINT | T_YIELD | T_LIST | T_SWITCH | T_ENDSWITCH | T_CASE | T_DEFAULT | T_BREAK
| T_ARRAY | T_CALLABLE | T_EXTENDS | T_IMPLEMENTS | T_NAMESPACE | T_TRAIT | T_INTERFACE | T_CLASS
| T_CLASS_C | T_TRAIT_C | T_FUNC_C | T_METHOD_C | T_LINE | T_FILE | T_DIR | T_NS_C
;

semi_reserved:
  reserved_non_modifiers
| T_STATIC | T_ABSTRACT | T_FINAL | T_PRIVATE | T_PROTECTED | T_PUBLIC
;

identifier:
  T_STRING
| semi_reserved

top_statement_list:
  top_statement_list top_statement {
    $$ = $1 + $2;
  }
| /* empty */ {
    $$ = "";
  }
;

namespace_name:
  T_STRING
| namespace_name T_NS_SEPARATOR T_STRING {
    $$ = $1 + $2 + $3;
  }
;

name:
  namespace_name
| T_NAMESPACE T_NS_SEPARATOR namespace_name {
    $$ = $1 + $2 + $3;
  }
| T_NS_SEPARATOR namespace_name {
    $$ = $1 + $2;
  }
;

top_statement:
  statement
| function_declaration_statement
| class_declaration_statement
| trait_declaration_statement
| interface_declaration_statement
| T_HALT_COMPILER '(' ')' ';' {
    $$ = $1 + $2 + $3 + $4;
  }
| T_NAMESPACE namespace_name ';' {
    $$ = $1 + " " + $2 + $3;
  }
| T_NAMESPACE namespace_name '{' top_statement_list '}' {
    $$ = $1 + " " + $2 + $3 + $4 + $5;
  }
| T_NAMESPACE '{' top_statement_list '}' {
    $$ = $1 + $2 + $3 + $4;
  }
| T_USE mixed_group_use_declaration ';' {
    $$ = $1 + " " + $2 + $3;
  }
| T_USE use_type group_use_declaration ';' {
    $$ = $1 + " " + $2 + $3;
  }
| T_USE use_declarations ';' {
    $$ = $1 + " " + $2 + $3;
  }
| T_USE use_type use_declarations ';' {
    $$ = $1 + " " + $2 + " " + $3 + $4;
  }
| T_CONST const_list ';' {
    $$ = $1 + " " + $2 + $3;
  }
;

use_type:
  T_FUNCTION
| T_CONST
;

group_use_declaration:
  namespace_name T_NS_SEPARATOR '{' unprefixed_use_declarations possible_comma '}' {
    $$ = $1 + $2 + $3 + $4 + $5 + $6;
  }
| T_NS_SEPARATOR namespace_name T_NS_SEPARATOR '{' unprefixed_use_declarations possible_comma '}' {
    $$ = $1 + $2 + $3 + $4 + $5 + $6 + $7;
  }
;

mixed_group_use_declaration:
  namespace_name T_NS_SEPARATOR '{' inline_use_declarations possible_comma '}' {
    $$ = $1 + $2 + $3 + $4 + $5 + $6;
  }
| T_NS_SEPARATOR namespace_name T_NS_SEPARATOR '{' inline_use_declarations possible_comma '}' {
    $$ = $1 + $2 + $3 + $4 + $5 + $6 + $7;
  }
;

possible_comma:
  /* empty */ {
    $$ = "";
  }
| ','
;

inline_use_declarations:
  inline_use_declarations ',' inline_use_declaration {
    $$ = $1 + $2 + $3;
  }
| inline_use_declaration
;

unprefixed_use_declarations:
  unprefixed_use_declarations ',' unprefixed_use_declaration {
    $$ = $1 + $2 + $3;
  }
| unprefixed_use_declaration
;

use_declarations:
  use_declarations ',' use_declaration {
    $$ = $1 + $2 + $3;
  }
| use_declaration
;

inline_use_declaration:
  unprefixed_use_declaration
| use_type unprefixed_use_declaration {
    $$ = $1 + " " +  $2;
  }
;

unprefixed_use_declaration:
  namespace_name
| namespace_name T_AS T_STRING {
    $$ = $1 + " " + $2 + " " + $3;
  }
;

use_declaration:
  unprefixed_use_declaration
| T_NS_SEPARATOR unprefixed_use_declaration {
    $$ = $1 + $2;
  }
;

const_list:
  const_list ',' const_decl {
    $$ = $1 + $2 + $3;
  }
| const_decl
;

inner_statement_list:
  inner_statement_list inner_statement {
    $$ = $1 + $2;
  }
| /* empty */ {
    $$ = "";
  }
;

inner_statement:
  statement
| function_declaration_statement
| class_declaration_statement
| trait_declaration_statement
| interface_declaration_statement
| T_HALT_COMPILER '(' ')' ';' {
    $$ = $1 + $2 + $3 + $4;
  }
;

statement:
  unticked_statement
| T_STRING ':' {
    $$ = $1 + $2;
  }
| T_OPEN_TAG {
    $$ = "<?php\n";
  }
| T_OPEN_TAG_WITH_ECHO
| T_OPEN_TAG_FAKE {
    $$ = "";
  }
;

unticked_statement:
  '{' inner_statement_list '}' {
    $$ = $1 + $2 + $3;
  }
| if_stmt
| alt_if_stmt
| T_WHILE '(' expr ')' while_statement {
    $$ = $1 + $2 + $3 + $4 + $5;
  }
| T_DO statement T_WHILE '(' expr ')' ';' {
    $$ = $1 + " " + $2 + $3 + $4 + $5 + $6 + $7;
  }
| T_FOR '(' for_expr ';' for_expr ';' for_expr ')' for_statement {
    $$ = $1 + $2 + $3 + $4 + $5 + $6 + $7 + $8 + $9;
  }
| T_SWITCH '(' expr ')' switch_case_list {
    $$ = $1 + $2 + $3 + $4 + $5;
  }
| T_BREAK optional_expr ';' {
    $$ = $1 + " " + $2 + $3;
  }
| T_CONTINUE optional_expr ';' {
    $$ = $1 + " " + $2 + $3;
  }
| T_RETURN optional_expr ';' {
    $$ = $1 + " " + $2 + $3;
  }
| T_GLOBAL global_var_list ';' {
    $$ = $1 + " " + $2 + $3;
  }
| T_STATIC static_var_list ';' {
    $$ = $1 + " " + $2 + $3;
  }
| T_ECHO echo_expr_list ';' {
    $$ = $1 + " " + $2 + $3;
  }
| T_INLINE_HTML
| expr ';' {
    $$ = $1 + $2;
  }
| T_UNSET '(' unset_variables possible_comma ')' ';' {
    $$ = $1 + $2 + $3 + $4 + $5 + $6;
  }
| T_FOREACH '(' expr T_AS foreach_variable ')' foreach_statement {
    $$ = $1 + $2 + $3 + " " + $4 + " " + $5 + $6 + $7;
  }
| T_FOREACH '(' expr T_AS foreach_variable T_DOUBLE_ARROW foreach_variable ')' foreach_statement {
    $$ = $1 + $2 + $3 + " " + $4 + " " + $5 + $6 + $7 + $8 + $9;
  }
| T_DECLARE '(' const_list ')' declare_statement {
    $$ = $1 + $2 + $3 + $4 + $5;
  }
| ';' /* empty statement */
| T_TRY '{' inner_statement_list '}' catch_list finally_statement {
    $$ = $1 + $2 + $3 + $4 + $5 + $6;
  }
| T_THROW expr ';' {
    $$ = $1 + " " + $2 + $3;
  }
| T_GOTO T_STRING ';' {
    $$ = $1 + " " + $2 + $3;
  }
;

catch_list:
  /* empty */ {
    $$ = "";
  }
| catch_list T_CATCH '(' catch_name_list T_VARIABLE ')' '{' inner_statement_list '}' {
  $$ = $1 + $2 + $3 + " " + $4 + $5 + $6 + $7 + $8 + $9;
  }
;

catch_name_list:
  name
| catch_name_list '|' name {
    $$ = $1 + $2 + $3;
  }
;

finally_statement:
  /* empty */ {
    $$ = "";
  }
| T_FINALLY '{' inner_statement_list '}' {
    $$ = $1 + $2 + $3 + $4;
  }
;

unset_variables:
  unset_variable
| unset_variables ',' unset_variable {
    $$ = $1 + $2 + $3;
  }
;

unset_variable:
  variable
;

function_declaration_statement:
  function returns_ref T_STRING '(' parameter_list ')' return_type '{' inner_statement_list '}' {
    $$ = $1 + " " + $2 + $3 + $4 + $5 + $6 + $7 + $8 + $9 + $10;
  }
;

is_reference:
  /* empty */ {
    $$ = "";
  }
| '&'
;

is_variadic:
  /* empty */ {
    $$ = "";
  }
| T_ELLIPSIS
;

class_declaration_statement:
  class_modifiers T_CLASS T_STRING extends_from implements_list '{' class_statement_list '}' {
    $$ = $1 + " " + $2 + " "  + $3 + $4 + $5 + $6 + $7 + $8;
  }
  | T_CLASS T_STRING extends_from implements_list '{' class_statement_list '}' {
    $$ = $1 + " "  + $2 + $3 + $4 + $5 + $6 + $7;
  }
;

class_modifiers:
  class_modifier
| class_modifiers class_modifier {
    $$ = $1 + " " + $2;
  }
;

class_modifier:
  T_ABSTRACT
| T_FINAL
;

trait_declaration_statement:
  T_TRAIT T_STRING '{' class_statement_list '}' {
    $$ = $1 + " " + $2 + $3 + $4 + $5;
  }
;

interface_declaration_statement:
  T_INTERFACE T_STRING interface_extends_list '{' class_statement_list '}' {
    $$ = $1 + " " + $2 + $3 + $4 + $5 + $6;
  }
;

extends_from:
  /* empty */ {
    yyextra->has_parent = false;
    $$ = "";
  }
| T_EXTENDS name {
    yyextra->has_parent = true;
    $$ = " " + $1 + " " + $2;
  }
;

interface_extends_list:
  /* empty */ {
    $$ = "";
  }
| T_EXTENDS name_list {
    $$ = $1 + " " + $2;
  }
;

implements_list:
  /* empty */ {
    $$ = "";
  }
| T_IMPLEMENTS name_list {
    $$ = " " + $1 + " " + $2;
  }
;

foreach_variable:
  variable
| '&' variable {
    $$ = $1 + $2;
  }
| T_LIST '(' array_pair_list ')' {
    $$ = $1 + $2 + $3 + $4;
  }
| '[' array_pair_list ']' {
    $$ = $1 + $2 + $3;
  }
;

for_statement:
  statement
| ':' inner_statement_list T_ENDFOR ';' {
    $$ = $1 + $2 + $3 + $4;
  }
;

foreach_statement:
  statement
| ':' inner_statement_list T_ENDFOREACH ';' {
    $$ = $1 + $2 + $3 + $4;
  }
;

declare_statement:
  statement
| ':' inner_statement_list T_ENDDECLARE ';' {
    $$ = $1 + $2 + $3 + $4;
  }
;

switch_case_list:
  '{' case_list '}' {
    $$ = $1 + $2 + $3;
  }
| '{' ';' case_list '}' {
    $$ = $1 + $2 + $3 + $4;
  }
| ':' case_list T_ENDSWITCH ';' {
    $$ = $1 + $2 + $3 + $4;
  }
| ':' ';' case_list T_ENDSWITCH ';' {
    $$ = $1 + $2 + $3 + $4 + $5;
  }
;

case_list:
  /* empty */ {
    $$ = "";
  }
| case_list T_CASE expr case_separator inner_statement_list {
    $$ = $1 + $2 + " " + $3 + $4 + $5;
  }
| case_list T_DEFAULT case_separator inner_statement_list {
    $$ = $1 + $2 + $3 + $4;
  }
;

case_separator:
  ':'
| ';'
;

while_statement:
  statement
| ':' inner_statement_list T_ENDWHILE ';' {
    $$ = $1 + $2 + $3 + $4;
  }
;

if_stmt_without_else:
  T_IF '(' expr ')' statement {
    $$ = $1 + $2 + $3 + $4 + $5;
  }
| if_stmt_without_else T_ELSEIF '(' expr ')' statement {
    $$ = $1 + $2 + $3 + $4 + $5 + $6;
  }
;

if_stmt:
  if_stmt_without_else %prec T_NOELSE
| if_stmt_without_else T_ELSE statement {
    $$ = $1 + $2 + " " + $3;
  }
;

alt_if_stmt_without_else:
  T_IF '(' expr ')' ':' inner_statement_list {
    $$ = $1 + $2 + $3 + $4 + $5;
  }
| alt_if_stmt_without_else T_ELSEIF '(' expr ')' ':' inner_statement_list {
    $$ = $1 + $2 + $3 + $4 + $5 + $6 + $7;
  }
;

alt_if_stmt:
  alt_if_stmt_without_else T_ENDIF ';' {
    $$ = $1 + $2 + $3;
  }
| alt_if_stmt_without_else T_ELSE ':' inner_statement_list T_ENDIF ';' {
    $$ = $1 + $2 + $3 + $4 + $5 + $6;
  }
;

parameter_list:
  non_empty_parameter_list
| /* empty */ {
    $$ = "";
  }
;

non_empty_parameter_list:
  parameter
  | non_empty_parameter_list ',' parameter {
    $$ = $1 + $2 + $3;
  }
;

parameter:
  optional_type is_reference is_variadic T_VARIABLE {
    $$ = $1 + $2 + $3 + $4;
  }
| optional_type is_reference is_variadic T_VARIABLE '=' expr {
    $$ = $1 + $2 + $3 + $4 + $5 + $6;
  }
;

optional_type:
  /* empty */ {
    $$ = "";
  }
| type_expr
;

type_expr:
  type
| '?' type {
    $$ = $1 + $2;
  }
;

type:
  T_ARRAY
| T_CALLABLE
| name
;

return_type:
  /* empty */ {
    $$ = "";
  }
| ':' type_expr {
    $$ = $1 + " " + $2;
  }
;

argument_list:
'(' ')' {
    $$ = $1 + $2;
  }
| '(' non_empty_argument_list possible_comma ')' {
    $$ = $1 + $2 + $3 + $4;
  }
;

non_empty_argument_list:
  argument
| non_empty_argument_list ',' argument {
    $$ = $1 + $2 + $3;
  }
;

argument:
  expr
| T_ELLIPSIS expr {
    $$ = $1 + $2;
  }
;

global_var_list:
  global_var_list ',' global_var {
    $$ = $1 + $2 + $3;
  }
| global_var
;

global_var:
 simple_variable
;

static_var_list:
  static_var_list ',' static_var {
    $$ = $1 + $2 + $3;
  }
| static_var
;

static_var:
  T_VARIABLE
| T_VARIABLE '=' expr {
    $$ = $1 + $2 + $3;
  }
;

class_statement_list:
  class_statement_list class_statement {
    $$ = $1 + $2;
  }
| /* empty */ {
    $$ = "";
  }
;

class_statement:
  variable_modifiers property_list ';' {
    $$ = $1 + " " + $2 + $3;
  }
| method_modifiers T_CONST class_const_list ';' {
    $$ = $1 + $2 + " " + $3 + $4;
  }
| T_USE name_list trait_adaptations {
    $$ = $1 + " " + $2 + $3;
  }
| method_modifiers function {
    yyextra->old_expecting_xhp_class_statements = yyextra->expecting_xhp_class_statements;
    yyextra->expecting_xhp_class_statements = false;
  } returns_ref identifier '(' parameter_list ')' return_type method_body {
    yyextra->expecting_xhp_class_statements = yyextra->old_expecting_xhp_class_statements;
    $$ = $1 + $2 + " " + $4 + $5 + $6 + $7 + $8 + $9 + $10;
  }
;

name_list:
  name
| name_list ',' name {
    $$ = $1 + $2 + $3;
  }
;

trait_adaptations:
  ';'
| '{' '}' {
    $$ = $1 + $2;
  }
| '{' trait_adaptation_list '}' {
    $$ = $1 + $2 + $3;
  }
;

trait_adaptation_list:
  trait_adaptation
| trait_adaptation_list trait_adaptation {
    $$ = $1 + $2;
  }
;

trait_adaptation:
  trait_precedence ';' {
    $$ = $1 + $2;
  }
| trait_alias ';' {
    $$ = $1 + $2;
  }
;

trait_precedence:
  absolute_trait_method_reference T_INSTEADOF name_list {
    $$ = $1 + " " + $2 + " " + $3;
  }
;

trait_alias:
  trait_method_reference T_AS T_STRING {
    $$ = $1 + $2 + $3;
  }
| trait_method_reference T_AS reserved_non_modifiers {
    $$ = $1 + $2 + $3;
  }
| trait_method_reference T_AS member_modifier identifier {
    $$ = $1 + $2 + $3 + $4;
  }
| trait_method_reference T_AS member_modifier {
    $$ = $1 + $2 + $3;
  }
;

trait_method_reference:
  identifier
| absolute_trait_method_reference
;

absolute_trait_method_reference:
  name T_PAAMAYIM_NEKUDOTAYIM identifier {
    $$ = $1 + $2 + $3;
  }
;

method_body:
  ';' /* abstract method */
| '{' inner_statement_list '}' {
    $$ = $1 + $2 + $3;
  }
;

variable_modifiers:
  non_empty_member_modifiers
| T_VAR {
    $$ = $1 + " ";
  }
;

method_modifiers:
  /* empty */ {
    $$ = "";
  }
| non_empty_member_modifiers {
    $$ = $1 + " ";
  }
;

non_empty_member_modifiers:
  member_modifier
| non_empty_member_modifiers member_modifier {
    $$ = $1 + " " + $2;
  }
;

member_modifier:
  T_PUBLIC
| T_PROTECTED
| T_PRIVATE
| T_STATIC
| T_ABSTRACT
| T_FINAL
;

property_list:
  property_list ',' property {
    $$ = $1 + $2 + $3;
  }
| property
;

property:
  T_VARIABLE
| T_VARIABLE '=' expr {
    $$ = $1 + $2 + $3;
  }
;

class_const_list:
  class_const_list ',' class_const_decl {
    $$ = $1 + $2 + $3;
  }
| class_const_decl
;

class_const_decl:
  identifier '=' expr {
    $$ = $1 + $2 + $3;
  }
;

const_decl:
  T_STRING '=' expr {
    $$ = $1 + $2 + $3;
  }
;

echo_expr_list:
  echo_expr_list ',' echo_expr {
    $$ = $1 + $2 + $3;
  }
| echo_expr
;

echo_expr:
  expr
;

for_expr:
  /* empty */ {
    $$ = "";
  }
| non_empty_for_expr
;


non_empty_for_expr:
  non_empty_for_expr ',' expr {
    $$ = $1 + $2 + $3;
  }
| expr
;

anonymous_class:
  T_CLASS ctor_arguments extends_from implements_list '{' class_statement_list '}' {
    $$ = $1 + " " + $2 + $3 + $4 + $5 + $6 + $7;
  }
;

new_expr:
  T_NEW class_name_reference ctor_arguments {
    $$ = $1 + " " + $2 + $3;
  }
| T_NEW anonymous_class {
    $$ = $1 + " " + $2;
  }
;

expr:
  variable
| T_LIST '(' array_pair_list ')' '=' expr {
    $$ = $1 + $2 + $3 + $4 + $5 + $6;
  }
| '[' array_pair_list ']' '=' expr {
    $$ = $1 + $2 + $3 + $4 + $5;
  }
| variable '=' expr {
    $$ = $1 + $2 + $3;
  }
| variable '=' '&' variable {
    $$ = $1 + $2 + $3 + $4;
  }
| new_expr {
    $$ = $1;
  }
| T_CLONE expr {
    $$ = $1 + " " + $2;
  }
| variable T_PLUS_EQUAL expr {
    $$ = $1 + $2 + $3;
  }
| variable T_MINUS_EQUAL expr {
    $$ = $1 + $2 + $3;
  }
| variable T_MUL_EQUAL expr {
    $$ = $1 + $2 + $3;
  }
| variable T_POW_EQUAL expr {
    $$ = $1 + $2 + $3;
  }
| variable T_DIV_EQUAL expr {
    $$ = $1 + $2 + $3;
  }
| variable T_CONCAT_EQUAL expr {
    $$ = $1 + $2 + $3;
  }
| variable T_MOD_EQUAL expr {
    $$ = $1 + $2 + $3;
  }
| variable T_AND_EQUAL expr {
    $$ = $1 + $2 + $3;
  }
| variable T_OR_EQUAL expr {
    $$ = $1 + $2 + $3;
  }
| variable T_XOR_EQUAL expr {
    $$ = $1 + $2 + $3;
  }
| variable T_SL_EQUAL expr {
    $$ = $1 + $2 + $3;
  }
| variable T_SR_EQUAL expr {
    $$ = $1 + $2 + $3;
  }
| variable T_INC {
    $$ = $1 + $2;
  }
| T_INC variable {
    $$ = $1 + $2;
  }
| variable T_DEC {
    $$ = $1 + $2;
  }
| T_DEC variable {
    $$ = $1 + $2;
  }
| expr T_BOOLEAN_OR expr {
    $$ = $1 + $2 + $3;
  }
| expr T_BOOLEAN_AND expr {
    $$ = $1 + $2 + $3;
  }
| expr T_LOGICAL_OR expr {
    $$ = $1 + " " +  $2 + " " + $3;
  }
| expr T_LOGICAL_AND expr {
    $$ = $1 + " " + $2 + " " + $3;
  }
| expr T_LOGICAL_XOR expr {
    $$ = $1 + " " + $2 + " " + $3;
  }
| expr '|' expr {
    $$ = $1 + $2 + $3;
  }
| expr '&' expr {
    $$ = $1 + $2 + $3;
  }
| expr '^' expr {
    $$ = $1 + $2 + $3;
  }
| expr '.' expr {
    $$ = $1 + " " + $2 + " " + $3;
  }
| expr '+' expr {
    $$ = $1 + $2 + $3;
  }
| expr '-' expr {
    $$ = $1 + $2 + $3;
  }
| expr '*' expr {
    $$ = $1 + $2 + $3;
  }
| expr T_POW expr {
    $$ = $1 + $2 + $3;
  }
| expr '/' expr {
    $$ = $1 + $2 + $3;
  }
| expr '%' expr {
    $$ = $1 + $2 + $3;
  }
| expr T_SL expr {
    $$ = $1 + $2 + $3;
  }
| expr T_SR expr {
    $$ = $1 + $2 + $3;
  }
| '+' expr %prec T_INC {
    $$ = $1 + $2;
  }
| '-' expr %prec T_INC {
    $$ = $1 + $2;
  }
| '!' expr {
    $$ = $1 + $2;
  }
| '~' expr {
    $$ = $1 + $2;
  }
| expr T_IS_IDENTICAL expr {
    $$ = $1 + $2 + $3;
  }
| expr T_IS_NOT_IDENTICAL expr {
    $$ = $1 + $2 + $3;
  }
| expr T_IS_EQUAL expr {
    $$ = $1 + $2 + $3;
  }
| expr T_IS_NOT_EQUAL expr {
    $$ = $1 + $2 + $3;
  }
| expr '<' expr {
    $$ = $1 + $2 + $3;
  }
| expr T_IS_SMALLER_OR_EQUAL expr {
    $$ = $1 + $2 + $3;
  }
| expr '>' expr {
    $$ = $1 + $2 + $3;
  }
| expr T_IS_GREATER_OR_EQUAL expr {
    $$ = $1 + $2 + $3;
  }
| expr T_SPACESHIP expr {
    $$ = $1 + $2 + $3;
  }
| expr T_INSTANCEOF class_name_reference {
    $$ = $1 + " " + $2 + " " + $3;
  }
| '(' expr ')' {
    $$ = $1 + $2 + $3;
  }
| expr '?' expr ':' expr {
    $$ = $1 + $2 + $3 + $4 + $5;
  }
| expr '?' ':' expr {
    $$ = $1 + $2 + $3 + $4;
  }
| expr T_COALESCE expr {
    $$ = $1 + $2 + $3;
  }
| internal_functions_in_yacc
| T_INT_CAST expr {
    $$ = $1 + $2;
  }
| T_DOUBLE_CAST expr {
    $$ = $1 + $2;
  }
| T_STRING_CAST expr {
    $$ = $1 + $2;
  }
| T_UNICODE_CAST expr {
    $$ = $1 + $2;
  }
| T_BINARY_CAST expr {
    $$ = $1 + $2;
  }
| T_ARRAY_CAST expr {
    $$ = $1 + $2;
  }
| T_OBJECT_CAST expr {
    $$ = $1 + $2;
  }
| T_BOOL_CAST expr {
    $$ = $1 + $2;
  }
| T_UNSET_CAST expr {
    $$ = $1 + $2;
  }
| T_EXIT exit_expr {
    $$ = $1 + $2;
  }
| '@' expr {
    $$ = $1 + $2;
  }
| scalar
| T_BACKTICKS_EXPR
| T_PRINT expr {
    $$ = $1 + " " + $2;
  }
| T_YIELD
| T_YIELD expr {
    $$ = $1 + $2;
  }
| T_YIELD expr T_DOUBLE_ARROW expr {
    $$ = $1 + $2 + $3;
  }
| T_YIELD_FROM expr {
    $$ = $1 + $2;
  }
| function returns_ref '(' parameter_list ')' lexical_vars return_type '{' inner_statement_list '}' {
    $$ = $1 + $2 + $3 + $4 + $5 + $6 + $7 + $8 + $9 + $10;
  }
| T_STATIC function returns_ref '(' parameter_list ')' lexical_vars return_type '{' inner_statement_list '}' {
    $$ = $1 + " " + $2 + $3 + $4 + $5 + $6 + $7 + $8 + $9 + $10 + $11;
  }
;

function:
  T_FUNCTION
;

returns_ref:
  /* empty */ {
    $$ = "";
  }
| '&'
;

lexical_vars:
  /* empty */ {
    $$ = "";
  }
| T_USE '(' lexical_var_list ')' {
    $$ = $1 + $2 + $3 + $4;
  }
;

lexical_var_list:
  lexical_var_list ',' lexical_var {
    $$ = $1 + $2 + $3;
  }
| lexical_var
;

lexical_var:
| T_VARIABLE
| '&' T_VARIABLE {
    $$ = $1 + $2;
  }
;

function_call:
  name argument_list {
    $$ = $1 + $2;
  }
| class_name T_PAAMAYIM_NEKUDOTAYIM member_name argument_list {
    $$ = $1 + $2 + $3 + $4;
  }
| variable_class_name T_PAAMAYIM_NEKUDOTAYIM member_name argument_list {
    $$ = $1 + $2 + $3 + $4;
  }
| callable_expr argument_list {
    $$ = $1 + $2;
  }
;

class_name:
  T_STATIC
| name
;

class_name_reference:
  class_name
| new_variable
;

exit_expr:
  /* empty */ {
    $$ = "";
  }
| '(' optional_expr')' {
    $$ = $1 + $2 + $3;
  }
;

ctor_arguments:
  /* empty */ {
    $$ = "";
  }
| argument_list
;

dereferencable_scalar:
  T_ARRAY '(' array_pair_list ')' {
    $$ = $1 + $2 + $3 + $4;
  }
| '[' array_pair_list ']' {
    $$ = $1 + $2 + $3;
  }
| T_CONSTANT_ENCAPSED_STRING
;

scalar:
  T_LNUMBER
| T_DNUMBER
| T_LINE
| T_FILE
| T_DIR
| T_TRAIT_C
| T_METHOD_C
| T_FUNC_C
| T_NS_C
| T_CLASS_C
| T_HEREDOC
| '"' encaps_list '"' {
    $$ = $1 + $2 + $3;
  }
| dereferencable_scalar
| constant
;

constant:
  name
| class_name T_PAAMAYIM_NEKUDOTAYIM identifier {
    $$ = $1 + $2 + $3;
  }
| variable_class_name T_PAAMAYIM_NEKUDOTAYIM identifier {
    $$ = $1 + $2 + $3;
  }
;

optional_expr:
  /* empty */ {
    $$ = "";
  }
| expr
;

variable_class_name:
  dereferencable
;

dereferencable:
  variable
| '(' expr ')' {
    $$ = $1 + $2 + $3;
  }
| dereferencable_scalar
;

callable_expr:
  callable_variable
| '(' expr ')' {
    $$ = $1 + $2 + $3;
  }
| dereferencable_scalar
;

callable_variable:
  simple_variable
| dereferencable '[' optional_expr ']' {
    $$ = $1 + $2 + $3 + $4;
  }
| constant '[' optional_expr ']' {
    $$ = $1 + $2 + $3 + $4;
  }
| dereferencable '{' expr '}' {
    $$ = $1 + $2 + $3;
  }
| dereferencable T_OBJECT_OPERATOR property_name argument_list {
    $$ = $1 + $2 + $3 + $4;
  }
| function_call
;

variable:
  callable_variable
| static_member
| dereferencable T_OBJECT_OPERATOR property_name {
    $$ = $1 + $2 + $3;
  }
;

simple_variable:
  T_VARIABLE
| '$' '{' expr '}' {
    $$ = $1 + $2 + $3 + $4;
  }
| '$' simple_variable {
    $$ = $1 + $2;
  }
;

static_member:
  class_name T_PAAMAYIM_NEKUDOTAYIM simple_variable {
    $$ = $1 + $2 + $3;
  }
| variable_class_name T_PAAMAYIM_NEKUDOTAYIM simple_variable {
    $$ = $1 + $2 + $3;
  }
;

new_variable:
  simple_variable
| new_variable '[' optional_expr ']' {
    $$ = $1 + $2 + $3 + $4;
  }
| new_variable '{' expr '}' {
    $$ = $1 + $2 + $3 + $4;
  }
| new_variable T_OBJECT_OPERATOR property_name {
    $$ = $1 + $2 + $3;
  }
| class_name T_PAAMAYIM_NEKUDOTAYIM simple_variable
| new_variable T_PAAMAYIM_NEKUDOTAYIM simple_variable
;

member_name:
  identifier
| '{' expr '}' {
    $$ = $1 + $2 + $3;
  }
| simple_variable
;

property_name:
  T_STRING
| '{' expr '}' {
    $$ = $1 + $2 + $3;
  }
| simple_variable
| xhp_attribute_reference
;

array_pair_list:
  non_empty_array_pair_list
;

possible_array_pair:
  /* empty */ {
    $$ = "";
  }
| array_pair
;

non_empty_array_pair_list:
  non_empty_array_pair_list ',' possible_array_pair {
    $$ = $1 + $2 + $3;
  }
| possible_array_pair
;

array_pair:
  expr T_DOUBLE_ARROW expr {
    $$ = $1 + $2 + $3;
  }
| expr
| expr T_DOUBLE_ARROW '&' variable {
    $$ = $1 + $2 + $3 + $4;
  }
| '&' variable {
    $$ = $1 + $2;
  }
| expr T_DOUBLE_ARROW T_LIST '(' array_pair_list ')' {
    $$ = $1 + $2 + $3 + $4 + $5 + $6;
  }
| T_LIST '(' array_pair_list ')' {
    $$ = $1 + $2 + $3 + $4;
  }
;

encaps_list:
  T_ENCAPSED_AND_WHITESPACE {
    $$ = $1;
  }
| encaps_list T_ENCAPSED_AND_WHITESPACE {
    $$ = $1 + $2;
  }
| encaps_list encaps_var {
    $$ = $1 + $2;
  }
| encaps_var {
    $$ = $1;
  }
;

encaps_var:
  T_VARIABLE {
    $$ = $1;
  }
| T_VARIABLE '[' encaps_var_offset ']' {
    $$ = $1 + $2 + $3 + $4;
  }
| T_VARIABLE T_OBJECT_OPERATOR T_STRING {
    $$ = $1 + $2 + $3;
  }
| T_DOLLAR_OPEN_CURLY_BRACES expr '}' {
    $$ = $1 + $2 + $3;
  }
| T_DOLLAR_OPEN_CURLY_BRACES T_STRING_VARNAME '}' {
    $$ = $1 + $2 + $3;
  }
| T_DOLLAR_OPEN_CURLY_BRACES T_STRING_VARNAME '[' expr ']' '}' {
    $$ = $1 + $2 + $3 + $4 + $5 + $6;
  }
| T_CURLY_OPEN variable '}' {
    $$ = $1 + $2 + $3;
  }
;

encaps_var_offset:
  T_STRING
| T_NUM_STRING
| '-' T_NUM_STRING {
    $$ = $1 + $2;
  }
| T_VARIABLE
;

internal_functions_in_yacc:
  T_ISSET '(' isset_variables possible_comma ')' {
    $$ = $1 + $2 + $3 + $4 + $5;
  }
| T_EMPTY '(' variable ')' {
    $$ = $1 + $2 + $3 + $4;
  }
| T_INCLUDE expr {
    $$ = $1 + " " + $2;
  }
| T_INCLUDE_ONCE expr {
    $$ = $1 + " " + $2;
  }
| T_EVAL '(' expr ')' {
    $$ = $1 + $2 + $3 + $4;
  }
| T_REQUIRE expr {
    $$ = $1 + " " + $2;
  }
| T_REQUIRE_ONCE expr {
    $$ = $1 + " " + $2;
  }
;

isset_variables:
  isset_variable
| isset_variables ',' isset_variable {
    $$ = $1 + $2 + $3;
  }
;

isset_variable:
  expr
;

//
// XHP Extensions
xhp_label_ws:
    xhp_bareword                       { $$ = $1;}
  | xhp_label_ws ':'
    xhp_bareword                       { $$ = $1 + ":" + $3;}
  | xhp_label_ws '-'
    xhp_bareword                       { $$ = $1 + "-" + $3;}
;


ident_no_semireserved:
    T_STRING
  | T_XHP_ATTRIBUTE
  | T_XHP_CATEGORY
  | T_XHP_CHILDREN
  | T_XHP_REQUIRED
  | T_XHP_ENUM
;

xhp_bareword:
    ident_no_semireserved
  | T_EXIT
  | T_FUNCTION
  | T_CONST
  | T_RETURN
  | T_YIELD
  | T_TRY
  | T_CATCH
  | T_FINALLY
  | T_THROW
  | T_IF
  | T_ELSEIF
  | T_ENDIF
  | T_ELSE
  | T_WHILE
  | T_ENDWHILE
  | T_DO
  | T_FOR
  | T_ENDFOR
  | T_FOREACH
  | T_ENDFOREACH
  | T_DECLARE
  | T_ENDDECLARE
  | T_INSTANCEOF
  | T_AS
  | T_SWITCH
  | T_ENDSWITCH
  | T_CASE
  | T_DEFAULT
  | T_BREAK
  | T_CONTINUE
  | T_GOTO
  | T_ECHO
  | T_PRINT
  | T_CLASS
  | T_INTERFACE
  | T_EXTENDS
  | T_IMPLEMENTS
  | T_NEW
  | T_CLONE
  | T_VAR
  | T_EVAL
  | T_INCLUDE
  | T_INCLUDE_ONCE
  | T_REQUIRE
  | T_REQUIRE_ONCE
  | T_NAMESPACE
  | T_USE
  | T_GLOBAL
  | T_ISSET
  | T_EMPTY
  | T_HALT_COMPILER
  | T_STATIC
  | T_ABSTRACT
  | T_FINAL
  | T_PRIVATE
  | T_PROTECTED
  | T_PUBLIC
  | T_UNSET
  | T_LIST
  | T_ARRAY
  | T_LOGICAL_OR
  | T_LOGICAL_AND
  | T_LOGICAL_XOR
  | T_CLASS_C
  | T_FUNC_C
  | T_METHOD_C
  | T_LINE
  | T_FILE
  | T_DIR
  | T_NS_C
  | T_TRAIT
  | T_TRAIT_C
  | T_INSTEADOF
;

// Tags
expr:
  xhp_tag_expression {
    $$ = $1;
    yyextra->used = true;
  }
;

xhp_tag_expression:
  xhp_singleton
| xhp_tag_open xhp_children xhp_tag_close {
    if (yyextra->include_debug) {
      char line[16];
      sprintf(line, "%lu", (unsigned long)$1.lineno());
      $$ = $1 + $2 + "), __FILE__, " + line +")";
    } else {
      $$ = $1 + $2 + "))";
    }
  }
;

xhp_singleton:
  xhp_tag_start xhp_attributes '/' T_XHP_TAG_GT {
    if (yyextra->include_debug) {
      char line[16];
      sprintf(line, "%lu", (unsigned long)$1.lineno());
      $1.xhpLabel(yyextra->force_global_namespace);
      $$ = "new " + $1 + "(array(" + $2 + "), array(), __FILE__, " + line + ")";
    } else {
      $1.xhpLabel(yyextra->force_global_namespace);
      $$ = "new " + $1 + "(array(" + $2 + "), array())";
    }
  }
;

xhp_tag_open:
  xhp_tag_start xhp_attributes T_XHP_TAG_GT {
    yyextra->pushTag($1.c_str());
    $1.xhpLabel(yyextra->force_global_namespace);
    $$ ="new " + $1 + "(array(" + $2 + "), array(";
  }
;

xhp_tag_close:
  T_XHP_TAG_LT '/' T_XHP_LABEL T_XHP_TAG_GT {
    if (yyextra->peekTag() != $3.c_str()) {
      string e1 = $3.c_str();
      string e2 = yyextra->peekTag();

      string e = "syntax error, mismatched tag </" + e1 + ">, expecting </" + e2 + ">";
      yyerror(yyscanner, NULL, e.c_str());
      yyextra->terminated = true;
    }
    yyextra->popTag();
    if (yyextra->haveTag()) ; // ST_XHP_CHILD_START
  }
| T_XHP_TAG_LT '/' T_XHP_TAG_GT {
    // empty end tag -- SGML SHORTTAG
    yyextra->popTag();
    if (yyextra->haveTag()) ; // ST_XHP_CHILD_START
    $$ = "))";
  }
;

xhp_tag_start:
  T_XHP_TAG_LT T_XHP_LABEL {
    $$ = $2;
  }
;

// Children
xhp_literal_text:
  T_XHP_TEXT {
    $1.strip_lines();
    $$ = $1;
  }
| xhp_literal_text T_XHP_TEXT {
    $2.strip_lines();
    $$ = $1 + $2;
  }
;

xhp_children:
  /* empty */ {
    $$ = "";
  }
| xhp_literal_text {
    // ST_XHP_CHILD_START
    $$ = "'" + $1 + "',";
  }
| xhp_children xhp_child {
    // ST_XHP_CHILD_START
    $$ = $1 + $2 + ",";
  }
| xhp_children xhp_child xhp_literal_text {
    // ST_XHP_CHILD_START
    $$ = $1 + $2 + ",'" + $3 + "',";
  }
;

xhp_child:
  xhp_tag_expression
| '{' expr '}' {
    // ST_XHP_CHILD_START
    $$ = $2;
  }
;

// Attributes
xhp_attributes:
  /* empty */ {
    $$ = "";
  }
| xhp_attributes xhp_attribute {
    $$ = $1 + $2 + ",";
  }
;

xhp_attribute:
  T_XHP_LABEL '=' xhp_attribute_value {
    $$ = "'" + $1 + "' => " + $3;
  }
;

xhp_attribute_value:
  T_XHP_TEXT {
    $$ = $1;
  }
| '{' expr '}' {
    $$ = $2;
  }
;

// Attribute when referenced as an object property ($foo->:attr)
xhp_attribute_reference:
  T_XHP_LABEL {
    $$ = "getAttribute('" + $1 + "')";
  }
;

// Elements
class_type:
  T_CLASS
| class_modifiers T_CLASS {
    $$ = $1 + " " + $2;
  }
;

class_declaration_statement:
  class_type T_XHP_LABEL extends_from implements_list '{' {
    yyextra->expecting_xhp_class_statements = true;
    yyextra->attribute_decls = "";
    yyextra->attribute_inherit = "";
    yyextra->used_attributes = false;
  } class_statement_list {
    yyextra->expecting_xhp_class_statements = false;
  } '}' {
    $2.xhpLabel(false);
    $$ = $1 + " " + $2 + $3 + $4 + $5 + $7;
    if (yyextra->used_attributes) {
      $$ = $$ +
        "protected static function &__xhpAttributeDeclaration() {" +
          "static $_ = -1;" +
          "if ($_ === -1) {" +
            "$_ = array(" + yyextra->attribute_decls + ") + " +
              yyextra->attribute_inherit +
              (yyextra->has_parent
                ? "parent::__xhpAttributeDeclaration();"
                : "[];"
              ) +
          "}" +
          "return $_;"
        "}";
    }
    $$ = $$ + $9;
    yyextra->used = true;
  }
;

// Element attribute declaration
class_statement:
  T_XHP_ATTRIBUTE xhp_attribute_decls ';' {
    yyextra->used = true;
    yyextra->used_attributes = true;
    $$ = ""; // this will be injected when the class closes
  }
;

xhp_attribute_decls:
  xhp_attribute_decl {}
| xhp_attribute_decls ',' xhp_attribute_decl {}
;

xhp_attribute_decl:
  xhp_attribute_decl_type xhp_label_ws xhp_attribute_default xhp_attribute_is_required {
    $1.strip_lines();
    $2.strip_lines();
    yyextra->attribute_decls = yyextra->attribute_decls +
      "'" + $2 + "'=>array(" + $1 + "," + $3 + "," + $4 + "),";
  }
| T_XHP_LABEL {
    $1.strip_lines();
    $1.xhpLabel(yyextra->force_global_namespace);
    yyextra->attribute_inherit = yyextra->attribute_inherit +
        $1 + "::__xhpAttributeDeclaration() + ";
  }
;

xhp_attribute_decl_type:
  T_XHP_STRING {
    $$ = "1, null";
  }
| T_XHP_BOOLEAN {
    $$ = "2, null";
  }
| T_XHP_NUMBER {
    $$ = "3, null";
  }
| T_ARRAY xhp_attribute_array_type {
    $$ = "4, " + $2;
  }
| class_name {
    $$ = "5, " + $1 + "::class";
  }
| T_VAR {
    $$ = "6, null";
  }
| T_XHP_MIXED {
    $$ = "6, null";
  }
| T_XHP_ENUM '{' xhp_attribute_enum '}' {
    $$ = "7, array(" + $3 + ")";
  }
| T_XHP_FLOAT {
    $$ = "8, null";
  }
| T_XHP_CALLABLE {
    $$ = "9, null";
  }
;

xhp_attribute_array_type:
  T_TYPELIST_LT xhp_attribute_array_key_type ',' xhp_attribute_array_value_type T_TYPELIST_GT {
    $$ = "array(" + $2 + "," + $4 + ")";
  }
| T_TYPELIST_LT xhp_attribute_array_value_type T_TYPELIST_GT {
    $$ = "array(null," + $2 + ")";
  }
| /* empty */ {
    $$ = "null";
  }
;

xhp_attribute_array_key_type:
  T_XHP_STRING {
    $$ = "1";
  }
| T_XHP_NUMBER {
    $$ = "3";
  }
;

xhp_attribute_array_value_type:
  T_XHP_STRING {
    $$ = "1";
  }
| T_XHP_BOOLEAN {
    $$ = "2";
  }
| T_XHP_NUMBER {
    $$ = "3";
  }
| T_ARRAY xhp_attribute_array_type {
    $$ = "4," + $2;
  }
| class_name {
    $$ = "5," + $1 + "::class";
  }
| T_XHP_FLOAT {
    $$ = "8";
  }
| T_XHP_CALLABLE {
    $$ = "9";
  }
;

xhp_attribute_enum_value:
  T_LNUMBER
| T_DNUMBER
| T_CONSTANT_ENCAPSED_STRING
| T_LINE
| T_FILE
| T_DIR
| T_TRAIT_C
| T_METHOD_C
| T_FUNC_C
| T_NS_C
| T_CLASS_C
| T_HEREDOC
;

xhp_attribute_enum:
  xhp_attribute_enum_value {
    $1.strip_lines();
    $$ = $1;
  }
| xhp_attribute_enum ',' xhp_attribute_enum_value {
    $3.strip_lines();
    $$ = $1 + ", " + $3;
  }
;

xhp_attribute_default:
  '=' expr {
    $2.strip_lines();
    $$ = $2;
  }
| /* empty */ {
    $$ = "null";
  }
;

xhp_attribute_is_required:
  T_XHP_REQUIRED {
    $$ = "1";
  }
| /* empty */ {
    $$ = "0";
  }
;

// Element category declaration
class_statement:
  T_XHP_CATEGORY xhp_category_list ';' {
    yyextra->used = true;
    $$ =
      "protected function &__xhpCategoryDeclaration() {" +
         code_rope("static $_ = array(") + $2 + ");" +
        "return $_;" +
      "}";
  }
;

xhp_category_list:
  T_XHP_CATEGORY_LABEL {
    $$ = "'" + $1 + "' => 1";
  }
| xhp_category_list ',' T_XHP_CATEGORY_LABEL {
    $$ = $1 + ",'" + $3 + "' => 1";
  }
;

// Element child list
class_statement:
  T_XHP_CHILDREN xhp_children_decl ';' {
    // ST_XHP_CHILDREN_DECL is popped in the scanner on ';'
    yyextra->used = true;
    $$ = "protected function &__xhpChildrenDeclaration() {" + $2 + "}";
  }
;

xhp_children_decl:
  xhp_children_paren_expr {
    $$ = "static $_ = " + $1 + "; return $_;";
  }
| T_XHP_ANY {
    $$ = "static $_ = 1; return $_;";
  }
| T_EMPTY {
    $$ = "static $_ = 0; return $_;";
  }
;

xhp_children_paren_expr:
  '(' xhp_children_decl_expr ')' {
    $$ = "array(0, 5, " + $2 + ")";
  }
| '(' xhp_children_decl_expr ')' '*' {
    $$ = "array(1, 5, " + $2 + ")";
  }
| '(' xhp_children_decl_expr ')' '?' {
    $$ = "array(2, 5, " + $2 + ")";
  }
| '(' xhp_children_decl_expr ')' '+' {
    $$ = "array(3, 5, " + $2 + ")";
  }
;

xhp_children_decl_expr:
  xhp_children_paren_expr
| xhp_children_decl_tag {
    $$ = "array(0, " + $1 + ")";
  }
| xhp_children_decl_tag '*' {
    $$ = "array(1, " + $1 + ")";
  }
| xhp_children_decl_tag '?' {
    $$ = "array(2, " + $1 + ")";
  }
| xhp_children_decl_tag '+' {
    $$ = "array(3, " + $1 + ")";
  }
| xhp_children_decl_expr ',' xhp_children_decl_expr {
    $$ = "array(4, " + $1 + "," + $3 + ")";
  }
| xhp_children_decl_expr '|' xhp_children_decl_expr {
    $$ = "array(5, " + $1 + "," + $3 + ")";
  }
;

xhp_children_decl_tag:
  T_XHP_ANY {
    $$ = "1, null";
  }
| T_XHP_PCDATA {
    $$ = "2, null";
  }
| T_XHP_LABEL {
    $1.xhpLabel(yyextra->force_global_namespace);
    $$ = "3, \'" + $1 + "\'";
  }
| T_XHP_CATEGORY_LABEL {
    $$ = "4, \'" + $1 + "\'";
  }
;

// Make XHP classes usable anywhere you see a real class
name:
  T_XHP_LABEL {
    yyextra->used = true;
    $1.xhpLabel(yyextra->force_global_namespace); $$ = $1;
  }
;

%%

const char* yytokname(int tok) {
  if (tok < 255) {
    return NULL;
  }
  return yytname[YYTRANSLATE(tok)];
}
