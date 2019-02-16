--TEST--
Variadic Function Call 05
--SKIPIF--
<?php 
if (version_compare(PHP_VERSION, '5.6', '<')) exit("Skip This test is for PHP 5.5 only.");
?>
--FILE--
<?php //xhp
class :x {}
function variadic(...$args) { return $args[0]; }
$b = [1, 2, 3];
echo variadic(...$b);
--EXPECT--
1
