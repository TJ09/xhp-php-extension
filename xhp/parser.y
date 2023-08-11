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
%define api.prefix {xhp}
%define api.pure full
%parse-param { void* yyscanner }
%parse-param { code_rope* root }
%lex-param { void* yyscanner }
%define parse.error verbose

%precedence T_THROW
%precedence T_INCLUDE T_INCLUDE_ONCE T_REQUIRE T_REQUIRE_ONCE
%left ','
%left T_LOGICAL_OR
%left T_LOGICAL_XOR
%left T_LOGICAL_AND
%precedence T_PRINT
%precedence T_YIELD
%precedence T_DOUBLE_ARROW
%precedence T_YIELD_FROM
%precedence '=' T_PLUS_EQUAL T_MINUS_EQUAL T_MUL_EQUAL T_DIV_EQUAL T_CONCAT_EQUAL T_MOD_EQUAL T_AND_EQUAL T_OR_EQUAL T_XOR_EQUAL T_SL_EQUAL T_SR_EQUAL T_POW_EQUAL T_COALESCE_EQUAL
%left '?' ':'
%right T_COALESCE
%left T_BOOLEAN_OR
%left T_BOOLEAN_AND
%left '|'
%left '^'
%left T_AMPERSAND_NOT_FOLLOWED_BY_VAR_OR_VARARG T_AMPERSAND_FOLLOWED_BY_VAR_OR_VARARG
%nonassoc T_IS_EQUAL T_IS_NOT_EQUAL T_IS_IDENTICAL T_IS_NOT_IDENTICAL T_SPACESHIP
%nonassoc '<' T_IS_SMALLER_OR_EQUAL '>' T_IS_GREATER_OR_EQUAL
%left '.'
%left T_SL T_SR
%left '+' '-'
%left '*' '/' '%'
%precedence '!'
%precedence T_INSTANCEOF
%precedence '~' T_INT_CAST T_DOUBLE_CAST T_STRING_CAST T_ARRAY_CAST T_OBJECT_CAST T_BOOL_CAST T_UNSET_CAST '@'
%right T_POW
%precedence T_CLONE

/* Resolve danging else conflict */
%precedence T_NOELSE
%precedence T_ELSEIF
%precedence T_ELSE

%token T_LNUMBER 260
%token T_DNUMBER 261
%token T_STRING 262
%token T_NAME_FULLY_QUALIFIED 263
%token T_NAME_RELATIVE 264
%token T_NAME_QUALIFIED 265
%token T_VARIABLE 266
%token T_INLINE_HTML 267
%token T_ENCAPSED_AND_WHITESPACE 268
%token T_CONSTANT_ENCAPSED_STRING 269
%token T_STRING_VARNAME 270
%token T_NUM_STRING 271

%token T_INCLUDE 272
%token T_INCLUDE_ONCE 273
%token T_EVAL 274
%token T_REQUIRE 275
%token T_REQUIRE_ONCE 276
%token T_LOGICAL_OR 277
%token T_LOGICAL_XOR 278
%token T_LOGICAL_AND 279
%token T_PRINT 280
%token T_YIELD 281
%token T_YIELD_FROM 282
%token T_INSTANCEOF 283
%token T_NEW 284
%token T_CLONE 285
%token T_EXIT 286
%token T_IF 287
%token T_ELSEIF 288
%token T_ELSE 289
%token T_ENDIF 290
%token T_ECHO 291
%token T_DO 292
%token T_WHILE 293
%token T_ENDWHILE 294
%token T_FOR 295
%token T_ENDFOR 296
%token T_FOREACH 297
%token T_ENDFOREACH 298
%token T_DECLARE 299
%token T_ENDDECLARE 300
%token T_AS 301
%token T_SWITCH 302
%token T_ENDSWITCH 303
%token T_CASE 304
%token T_DEFAULT 305
%token T_MATCH 306
%token T_BREAK 307
%token T_CONTINUE 308
%token T_GOTO 309
%token T_FUNCTION 310
%token T_FN 311
%token T_CONST 312
%token T_RETURN 313
%token T_TRY 314
%token T_CATCH 315
%token T_FINALLY 316
%token T_THROW 317
%token T_USE 318
%token T_INSTEADOF 319
%token T_GLOBAL 320
%token T_STATIC 321
%token T_ABSTRACT 322
%token T_FINAL 323
%token T_PRIVATE 324
%token T_PROTECTED 325
%token T_PUBLIC 326
%token T_READONLY 327
%token T_VAR 328
%token T_UNSET 329
%token T_ISSET 330
%token T_EMPTY 331
%token T_HALT_COMPILER 332
%token T_CLASS 333
%token T_TRAIT 334
%token T_INTERFACE 335
%token T_ENUM 336
%token T_EXTENDS 337
%token T_IMPLEMENTS 338
%token T_NAMESPACE 339
%token T_LIST 340
%token T_ARRAY 341
%token T_CALLABLE 342
%token T_LINE 343
%token T_FILE 344
%token T_DIR 345
%token T_CLASS_C 346
%token T_TRAIT_C 347
%token T_METHOD_C 348
%token T_FUNC_C 349
%token T_NS_C 350

%token T_ATTRIBUTE 351
%token T_PLUS_EQUAL 352
%token T_MINUS_EQUAL 353
%token T_MUL_EQUAL 354
%token T_DIV_EQUAL 355
%token T_CONCAT_EQUAL 356
%token T_MOD_EQUAL 357
%token T_AND_EQUAL 358
%token T_OR_EQUAL 359
%token T_XOR_EQUAL 360
%token T_SL_EQUAL 361
%token T_SR_EQUAL 362
%token T_COALESCE_EQUAL 363
%token T_BOOLEAN_OR 364
%token T_BOOLEAN_AND 365
%token T_IS_EQUAL 366
%token T_IS_NOT_EQUAL 367
%token T_IS_IDENTICAL 368
%token T_IS_NOT_IDENTICAL 369
%token T_IS_SMALLER_OR_EQUAL 370
%token T_IS_GREATER_OR_EQUAL 371
%token T_SPACESHIP 372
%token T_SL 373
%token T_SR 374
%token T_INC 375
%token T_DEC 376
%token T_INT_CAST 377
%token T_DOUBLE_CAST 378
%token T_STRING_CAST 379
%token T_ARRAY_CAST 380
%token T_OBJECT_CAST 381
%token T_BOOL_CAST 382
%token T_UNSET_CAST 383
%token T_OBJECT_OPERATOR 384
%token T_NULLSAFE_OBJECT_OPERATOR 385
%token T_DOUBLE_ARROW 386
%token T_COMMENT 387
%token T_DOC_COMMENT 388
%token T_OPEN_TAG 389
%token T_OPEN_TAG_WITH_ECHO 390
%token T_CLOSE_TAG 391
%token T_WHITESPACE 392
%token T_START_HEREDOC 393
%token T_END_HEREDOC 394
%token T_DOLLAR_OPEN_CURLY_BRACES 395
%token T_CURLY_OPEN 396
%token T_PAAMAYIM_NEKUDOTAYIM 397
%token T_NS_SEPARATOR 398
%token T_ELLIPSIS 399
%token T_COALESCE 400
%token T_POW 401
%token T_POW_EQUAL 402
%token T_BAD_CHARACTER 405
%token T_AMPERSAND_FOLLOWED_BY_VAR_OR_VARARG 403
%token T_AMPERSAND_NOT_FOLLOWED_BY_VAR_OR_VARARG 404
// XHP-specific tokens
%token T_XHP_WHITESPACE 5002
%token T_XHP_TEXT 5003
%token T_XHP_ATTRIBUTE 5004
%token T_XHP_CATEGORY 5005
%token T_XHP_CATEGORY_LABEL 5006
%token T_XHP_CHILDREN 5007
%token T_XHP_ANY 5008
%token T_XHP_PCDATA 5009
%token T_XHP_COLON 5010
%token T_XHP_HYPHEN 5011
%token T_XHP_BOOLEAN 5012
%token T_XHP_NUMBER 5013
%token T_XHP_MIXED 5014
%token T_XHP_STRING 5015
%token T_XHP_ENUM 5016
%token T_XHP_FLOAT 5017
%token T_XHP_REQUIRED 5019
%token T_XHP_LABEL 5020

%token T_XHP_TAG_LT 5021
%token T_XHP_TAG_GT 5022
%token T_TYPELIST_LT 5023
%token T_TYPELIST_GT 5024
%token T_UNRESOLVED_OP 5025
%token T_UNRESOLVED_LT 5026
%token T_OPEN_TAG_FAKE 5027

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
| T_CLASS_C | T_TRAIT_C | T_FUNC_C | T_METHOD_C | T_LINE | T_FILE | T_DIR | T_NS_C | T_FN | T_MATCH
;

semi_reserved:
  reserved_non_modifiers
| T_STATIC | T_ABSTRACT | T_FINAL | T_PRIVATE | T_PROTECTED | T_PUBLIC | T_READONLY
;

ampersand:
  T_AMPERSAND_FOLLOWED_BY_VAR_OR_VARARG
| T_AMPERSAND_NOT_FOLLOWED_BY_VAR_OR_VARARG
;

identifier:
  T_STRING
| semi_reserved

top_statement_list:
  top_statement_list top_statement {
    $$ = $1 + $2;
  }
| %empty {
    $$ = "";
  }
;

namespace_declaration_name:
  identifier
| T_NAME_QUALIFIED
;

namespace_name:
  T_STRING
| T_NAME_QUALIFIED;

legacy_namespace_name:
  namespace_name
| T_NAME_FULLY_QUALIFIED;

name:
  T_STRING
| T_NAME_QUALIFIED
| T_NAME_FULLY_QUALIFIED
| T_NAME_RELATIVE
;

attribute_decl:
  class_name
| class_name argument_list {
    $$ = $1 + $2;
  }
;

attribute_group:
  attribute_decl
| attribute_group ',' attribute_decl {
    $1 + $2 + $3;
  }
;

attribute:
  T_ATTRIBUTE attribute_group possible_comma ']' {
    $$ = $1 + $2 + $3 + $4;
  }
;

attributes:
  attribute
| attributes attribute {
    $$ = $1 + $2;
  }
;

attributed_statement:
  function_declaration_statement
| class_declaration_statement
| trait_declaration_statement
| interface_declaration_statement
| enum_declaration_statement
;

top_statement:
  statement
| attributed_statement
| attributes attributed_statement  {
    $$ = $1 + $2;
  }
| T_HALT_COMPILER '(' ')' ';' {
    $$ = $1 + $2 + $3 + $4;
  }
| T_NAMESPACE namespace_declaration_name ';' {
    $$ = $1 + " " + $2 + $3;
  }
| T_NAMESPACE namespace_declaration_name '{' top_statement_list '}' {
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
  legacy_namespace_name T_NS_SEPARATOR '{' unprefixed_use_declarations possible_comma '}' {
    $$ = $1 + $2 + $3 + $4 + $5 + $6;
  }
;

mixed_group_use_declaration:
  legacy_namespace_name T_NS_SEPARATOR '{' inline_use_declarations possible_comma '}' {
    $$ = $1 + $2 + $3 + $4 + $5 + $6;
  }
;

possible_comma:
  %empty {
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
  legacy_namespace_name
| legacy_namespace_name T_AS T_STRING {
    $$ = $1 + " " + $2 + " " + $3;
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
| %empty {
    $$ = "";
  }
;

inner_statement:
  statement
| attributed_statement
| attributes attributed_statement
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
    $$ = $1;
  }
| T_OPEN_TAG_WITH_ECHO
| T_OPEN_TAG_FAKE {
    $$ = "";
  }
| T_CLOSE_TAG {
    $$ = $1;
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
| T_GOTO T_STRING ';' {
    $$ = $1 + " " + $2 + $3;
  }
;

catch_list:
  %empty {
    $$ = "";
  }
| catch_list T_CATCH '(' catch_name_list optional_variable ')' '{' inner_statement_list '}' {
  $$ = $1 + $2 + $3 + $4 + " " + $5 + $6 + $7 + $8 + $9;
  }
;

catch_name_list:
  class_name
| catch_name_list '|' class_name {
    $$ = $1 + $2 + $3;
  }
;

optional_variable:
  %empty {
    $$ = "";
  }
| T_VARIABLE
;

finally_statement:
  %empty {
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

function_name:
  T_STRING
| T_READONLY
;

function_declaration_statement:
  function returns_ref function_name '(' parameter_list ')' return_type '{' inner_statement_list '}' {
    $$ = $1 + " " + $2 + $3 + $4 + $5 + $6 + $7 + $8 + $9 + $10;
  }
;

is_reference:
  %empty {
    $$ = "";
  }
| T_AMPERSAND_FOLLOWED_BY_VAR_OR_VARARG
;

is_variadic:
  %empty {
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
| T_READONLY
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

enum_declaration_statement:
  T_ENUM T_STRING enum_backing_type implements_list '{' class_statement_list '}' {
    $$ = $1 + " " + $2 + $3 + $4 + $5 + $6 + $7;
  }
;

enum_backing_type:
  %empty {
    $$ = "";
  }
| ':' type_expr {
    $$ = $1 + $2;
  }
;

enum_case:
  T_CASE identifier enum_case_expr ';' {
    $$ = $1 + $2 + $3 + $4;
  }
;

enum_case_expr:
  %empty {
    $$ = "";
  }
| '=' expr {
    $$ = $1 + $2;
  }
;

extends_from:
  %empty {
    yyextra->has_parent = false;
    $$ = "";
  }
| T_EXTENDS class_name {
    yyextra->has_parent = true;
    $$ = " " + $1 + " " + $2;
  }
;

interface_extends_list:
  %empty {
    $$ = "";
  }
| T_EXTENDS class_name_list {
    $$ = $1 + " " + $2;
  }
;

implements_list:
  %empty {
    $$ = "";
  }
| T_IMPLEMENTS class_name_list {
    $$ = " " + $1 + " " + $2;
  }
;

foreach_variable:
  variable
| ampersand variable {
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
  %empty {
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

match:
  T_MATCH '(' expr ')' '{' match_arm_list '}' {
    $$ = $1 + $2 + $3 + $4 + $5 + $6 + $7;
  }
;

match_arm_list:
  %empty {
    $$ = "";
  }
| non_empty_match_arm_list possible_comma {
    $$ = $1 + $2;
  }
;

non_empty_match_arm_list:
  match_arm
| non_empty_match_arm_list ',' match_arm {
    $$ = $1 + $2 + $3;
  }
;

match_arm:
  match_arm_cond_list possible_comma T_DOUBLE_ARROW expr {
    $$ = $1 + $2 + $3 + $4;
  }
| T_DEFAULT possible_comma T_DOUBLE_ARROW expr {
    $$ = $1 + $2 + $3 + $4;
  }
;

match_arm_cond_list:
  expr
| match_arm_cond_list ',' expr {
    $$ = $1 + $2 + $3;
  }
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
  non_empty_parameter_list possible_comma {
    $$ = $1 + $2;
  }
| %empty {
    $$ = "";
  }
;

non_empty_parameter_list:
  attributed_parameter
  | non_empty_parameter_list ',' attributed_parameter {
    $$ = $1 + $2 + $3;
  }
;

attributed_parameter:
  attributes parameter {
    $$ = $1 + $2;
  }
| parameter
;

optional_property_modifiers:
  %empty {
    $$ = "";
  }
| optional_property_modifiers property_modifier {
    $$ = $1 + $2 + " ";
  }
;

property_modifier:
  T_PUBLIC
| T_PROTECTED
| T_PRIVATE
| T_READONLY
;

parameter:
  optional_property_modifiers optional_type_without_static
  is_reference is_variadic T_VARIABLE {
    $$ = $1 + $2 + $3 + $4 + $5;
  }
| optional_property_modifiers optional_type_without_static
  is_reference is_variadic T_VARIABLE '=' expr {
    $$ = $1 + $2 + $3 + $4 + $5 + $6 + $7;
  }
;

optional_type_without_static:
  %empty {
    $$ = "";
  }
| type_expr_without_static
;

type_expr:
  type
| '?' type {
    $$ = $1 + $2;
  }
| union_type
| intersection_type
;

type:
  type_without_static
| T_STATIC
;

union_type_element:
  type
| '(' intersection_type ')' {
    $$ = $1 + $2 + $3;
  }
;

union_type:
  union_type_element '|' union_type_element {
    $$ = $1 + $2 + $3;
  }
| union_type '|' union_type_element {
    $$ = $1 + $2 + $3;
  }
;

intersection_type:
  type T_AMPERSAND_NOT_FOLLOWED_BY_VAR_OR_VARARG type {
    $$ = $1 + $2 + $3;
  }
| intersection_type T_AMPERSAND_NOT_FOLLOWED_BY_VAR_OR_VARARG type {
    $$ = $1 + $2 + $3;
  }
;

type_expr_without_static:
  type_without_static
| '?' type_without_static {
    $$ = $1 + $2;
  }
| union_type_without_static
| intersection_type_without_static
;

type_without_static:
  T_ARRAY
| T_CALLABLE
| name
;

union_type_without_static_element:
  type_without_static
| '(' intersection_type_without_static ')' {
    $$ = $1 + $2 + $3;
  }
;

union_type_without_static:
  union_type_without_static_element '|' union_type_without_static_element {
    $$ = $1 + $2 + $3;
  }
| union_type_without_static '|' union_type_without_static_element {
    $$ = $1 + $2 + $3;
  }
;

intersection_type_without_static:
  type_without_static T_AMPERSAND_NOT_FOLLOWED_BY_VAR_OR_VARARG type_without_static {
    $$ = $1 + $2 + $3;
  }
| intersection_type_without_static T_AMPERSAND_NOT_FOLLOWED_BY_VAR_OR_VARARG type_without_static {
    $$ = $1 + $2 + $3;
  }
;

return_type:
  %empty {
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
| '(' T_ELLIPSIS ')' {
    $$ = $1 + $2 + $3;
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
| identifier ':' expr {
    $$ = $1 + $2 + $3;
  }
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
| %empty {
    $$ = "";
  }
;

attributed_class_statement:
  variable_modifiers optional_type_without_static property_list ';' {
    $$ = $1 + " " + $2 + $3 + $4;
  }
| method_modifiers T_CONST class_const_list ';' {
    $$ = $1 + $2 + " " + $3 + $4;
  }
| method_modifiers function {
    yyextra->old_expecting_xhp_class_statements = yyextra->expecting_xhp_class_statements;
    yyextra->expecting_xhp_class_statements = false;
  } returns_ref identifier '(' parameter_list ')' return_type method_body {
    yyextra->expecting_xhp_class_statements = yyextra->old_expecting_xhp_class_statements;
    $$ = $1 + $2 + " " + $4 + $5 + $6 + $7 + $8 + $9 + $10;
  }
| enum_case
;

class_statement:
  attributed_class_statement
| attributes attributed_class_statement {
    $$ = $1 + $2;
  }
| T_USE class_name_list trait_adaptations {
    $$ = $1 + " " + $2 + $3;
  }
;

class_name_list:
  class_name
| class_name_list ',' class_name {
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
  absolute_trait_method_reference T_INSTEADOF class_name_list {
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
  class_name T_PAAMAYIM_NEKUDOTAYIM identifier {
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
  %empty {
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
| T_READONLY
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
  %empty {
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
| T_NEW attributes anonymous_class {
    $$ = $1 + " " + $2 + $3;
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
| variable '=' ampersand variable {
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
| variable T_COALESCE_EQUAL expr {
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
| expr T_AMPERSAND_NOT_FOLLOWED_BY_VAR_OR_VARARG expr {
    $$ = $1 + $2 + $3;
  }
| expr T_AMPERSAND_FOLLOWED_BY_VAR_OR_VARARG expr {
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
| '+' expr %prec '~' {
    $$ = $1 + $2;
  }
| '-' expr %prec '~' {
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
| '`' backticks_expr '`' {
    $$ = $1 + $2 + $3;
  }
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
| T_THROW expr {
    $$ = $1 + " " + $2;
  }
| inline_function {
    $$ = $1;
  }
| attributes inline_function {
    $$ = $1 + $2;
  }
| T_STATIC inline_function {
    $$ = $1 + $2;
  }
| attributes T_STATIC inline_function {
    $$ = $1 + $2 + $3;
  }
| match
;

inline_function:
  function returns_ref '(' parameter_list ')' lexical_vars return_type
  '{' inner_statement_list '}' {
    $$ = $1 + $2 + $3 + $4 + $5 + $6 + $7 + $8 + $9 + $10;
  }
| fn returns_ref '(' parameter_list ')' return_type
  T_DOUBLE_ARROW expr {
    $$ = $1 + $2 + $3 + $4 + $5 + $6 + $7 + $8;
  }
;

fn:
  T_FN
;

function:
  T_FUNCTION
;

returns_ref:
  %empty {
    $$ = "";
  }
| ampersand
;

lexical_vars:
  %empty {
    $$ = "";
  }
| T_USE '(' lexical_var_list possible_comma ')' {
    $$ = $1 + $2 + $3 + $4 + $5;
  }
;

lexical_var_list:
  lexical_var_list ',' lexical_var {
    $$ = $1 + $2 + $3;
  }
| lexical_var
;

lexical_var:
  T_VARIABLE
| ampersand T_VARIABLE {
    $$ = $1 + $2;
  }
;

function_call:
  name argument_list {
    $$ = $1 + $2;
  }
| T_READONLY argument_list {
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
| '(' expr ')' {
    $$ = $1 + $2 + $3;
  }
;

exit_expr:
  %empty {
    $$ = "";
  }
| '(' optional_expr')' {
    $$ = $1 + $2 + $3;
  }
;

backticks_expr:
  %empty {
    $$ = "";
  }
| T_ENCAPSED_AND_WHITESPACE {
    $$ = $1;
  }
| encaps_list {
    $$ = $1;
  }
;

ctor_arguments:
  %empty {
    $$ = "";
  }
| argument_list
;

dereferenceable_scalar:
  T_ARRAY '(' array_pair_list ')' {
    $$ = $1 + $2 + $3 + $4;
  }
| '[' array_pair_list ']' {
    $$ = $1 + $2 + $3;
  }
| T_CONSTANT_ENCAPSED_STRING
| '"' encaps_list '"' {
    $$ = $1 + $2 + $3;
  }
;

scalar:
  T_LNUMBER
| T_DNUMBER
| T_START_HEREDOC T_ENCAPSED_AND_WHITESPACE T_END_HEREDOC { $$ = $1 + $2 + $3; }
| T_START_HEREDOC T_END_HEREDOC { $$ = $1 + $2; }
| T_START_HEREDOC encaps_list T_END_HEREDOC { $$ = $1 + $2 + $3; }
| dereferenceable_scalar
| constant
| class_constant
;

constant:
  name
| T_LINE
| T_FILE
| T_DIR
| T_TRAIT_C
| T_METHOD_C
| T_FUNC_C
| T_NS_C
| T_CLASS_C
;

class_constant:
  class_name T_PAAMAYIM_NEKUDOTAYIM identifier {
    $$ = $1 + $2 + $3;
  }
| variable_class_name T_PAAMAYIM_NEKUDOTAYIM identifier {
    $$ = $1 + $2 + $3;
  }
;

optional_expr:
  %empty {
    $$ = "";
  }
| expr
;

variable_class_name:
  fully_dereferenceable
;

fully_dereferenceable:
  variable
| '(' expr ')' {
    $$ = $1 + $2 + $3;
  }
| dereferenceable_scalar
| class_constant
;

array_object_dereferenceable:
  fully_dereferenceable
| constant
;

callable_expr:
  callable_variable
| '(' expr ')' {
    $$ = $1 + $2 + $3;
  }
| dereferenceable_scalar
;

callable_variable:
  simple_variable
| array_object_dereferenceable '[' optional_expr ']' {
    $$ = $1 + $2 + $3 + $4;
  }
| array_object_dereferenceable '{' expr '}' {
    $$ = $1 + $2 + $3;
  }
| array_object_dereferenceable T_OBJECT_OPERATOR property_name argument_list {
    $$ = $1 + $2 + $3 + $4;
  }
| array_object_dereferenceable T_NULLSAFE_OBJECT_OPERATOR property_name argument_list {
    $$ = $1 + $2 + $3 + $4;
  }
| function_call
;

variable:
  callable_variable
| static_member
| array_object_dereferenceable T_OBJECT_OPERATOR property_name {
    $$ = $1 + $2 + $3;
  }
| array_object_dereferenceable T_NULLSAFE_OBJECT_OPERATOR property_name {
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
| new_variable T_NULLSAFE_OBJECT_OPERATOR property_name {
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
  %empty {
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
| expr T_DOUBLE_ARROW ampersand variable {
    $$ = $1 + $2 + $3 + $4;
  }
| ampersand variable {
    $$ = $1 + $2;
  }
| T_ELLIPSIS expr {
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
  encaps_list encaps_var {
    $$ = $1 + $2;
  }
| encaps_list T_ENCAPSED_AND_WHITESPACE {
    $$ = $1 + $2;
  }
| encaps_var {
    $$ = $1;
  }
| T_ENCAPSED_AND_WHITESPACE encaps_var {
    $$ = $1 + $2;
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
| T_VARIABLE T_NULLSAFE_OBJECT_OPERATOR T_STRING {
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
  %empty {
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
  %empty {
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
  ':' T_XHP_LABEL {
    $$ = "getAttribute('" + $2 + "')";
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
| T_CALLABLE {
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
| %empty {
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
| T_CALLABLE {
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
| T_START_HEREDOC T_ENCAPSED_AND_WHITESPACE T_END_HEREDOC
| T_START_HEREDOC T_END_HEREDOC
| T_START_HEREDOC encaps_list T_END_HEREDOC
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
| %empty {
    $$ = "null";
  }
;

xhp_attribute_is_required:
  T_XHP_REQUIRED {
    $$ = "1";
  }
| %empty {
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
