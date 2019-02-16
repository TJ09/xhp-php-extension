--TEST--
Variadic Function Call 04
--SKIPIF--
<?php 
if (version_compare(PHP_VERSION, '5.6', '<')) exit("Skip This test is for PHP 5.5 only.");
?>
--FILE--
<?php //xhp
class :x {}
function variadic(...$args) { return $args[0]; }
echo variadic(1, 2, 3);
--EXPECT--
1
