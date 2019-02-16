--TEST--
Variadic Function Call 06
--SKIPIF--
<?php
if (version_compare(PHP_VERSION, '5.6', '<')) exit("Skip This test is for PHP 5.5 only.");
?>
--FILE--
<?php //xhp
class :x {}
function variadic($a, $b, $c) { return $c; }
$b = [2, 3];
echo variadic(1, ...array_values($b));
--EXPECT--
3
