--TEST--
xhp_token_get_all should parse numbers as longs or doubles
--FILE--
<?php
$tokens = xhp_token_get_all(<<<'code'
<?php

0b1011010101001010110101010010101011010101010101101011001110111100
0b10110101_01001010_11010101_00101010_11010101_01010110_10110011_10111100
0b10110101_01001010_11010101_00101010_11010101_01010110_10110011_1011110
0b10110101
code
);

echo 'TOKENS:'. count($tokens) . PHP_EOL;
foreach($tokens as $tok) {
  if (is_array($tok)) {
  echo xhp_token_name($tok[0]).' '.$tok[2];
  } else {
  var_export($tok);
  }
  echo PHP_EOL;
}
--EXPECT--
TOKENS:9
T_OPEN_TAG 2
T_WHITESPACE 3
T_DNUMBER 3
T_WHITESPACE 4
T_DNUMBER 4
T_WHITESPACE 5
T_LNUMBER 5
T_WHITESPACE 6
T_LNUMBER 6
