--TEST--
Spaceship Operator
--FILE--
<?php
class :x {}
echo (1 <=> 1)."\n";
echo (1 <=> 2)."\n";
echo (2 <=> 1)."\n";
--EXPECT--
0
-1
1
