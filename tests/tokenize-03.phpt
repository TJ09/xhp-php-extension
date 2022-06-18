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

0xFFFFFFFFFFFFFFFF
0xFFFF_FFFF_FFFF_FFFF
0x8FFF_FFFF_FFFF_FFFF
0x7FFF_FFFF_FFFF_FFFF
0xFFFF_FFFF_FFFF_FFF
0xFFFF

0o1000000000000000000000
0o1000_000_000_000_000_000_000
0o1000_000_000_000_000_000
0o100
code
);

foreach($tokens as $tok) {
  if (is_array($tok) && xhp_token_name($tok[0]) !== 'T_WHITESPACE') {
	echo xhp_token_name($tok[0]).' '.$tok[1];
	echo PHP_EOL;
  }
}
--EXPECT--
T_OPEN_TAG <?php

T_DNUMBER 0b1011010101001010110101010010101011010101010101101011001110111100
T_DNUMBER 0b10110101_01001010_11010101_00101010_11010101_01010110_10110011_10111100
T_LNUMBER 0b10110101_01001010_11010101_00101010_11010101_01010110_10110011_1011110
T_LNUMBER 0b10110101
T_DNUMBER 0xFFFFFFFFFFFFFFFF
T_DNUMBER 0xFFFF_FFFF_FFFF_FFFF
T_DNUMBER 0x8FFF_FFFF_FFFF_FFFF
T_LNUMBER 0x7FFF_FFFF_FFFF_FFFF
T_LNUMBER 0xFFFF_FFFF_FFFF_FFF
T_LNUMBER 0xFFFF
T_DNUMBER 0o1000000000000000000000
T_DNUMBER 0o1000_000_000_000_000_000_000
T_LNUMBER 0o1000_000_000_000_000_000
T_LNUMBER 0o100
