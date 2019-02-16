--TEST--
Symmetric Array Destructuring 02
--SKIPIF--
<?php
if (version_compare(PHP_VERSION, '7.1', '<')) exit("Skip This test is for PHP 7.1+.");
?>
--FILE--
<?php //xhp
class :x {}

['x' => $x, 'y' => $y] = ['y' => 4, 'x' => 3];

var_dump($x, $y);
--EXPECT--
int(3)
int(4)
