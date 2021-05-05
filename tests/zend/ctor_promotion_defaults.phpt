--TEST--
[Zend]Constructor promotion with default values
--SKIPIF--
<?php
if (version_compare(PHP_VERSION, '8.0', '<')) exit("Skip This test is for PHP 8.0+ only.");
?>
--FILE--
<?php // xhp

class Point {
    public function __construct(
        public float $x = 0.0,
        public float $y = 1.0,
        public float $z = 2.0
    ) {}
}

var_dump(new Point(10.0));
var_dump(new Point(10.0, 11.0));
var_dump(new Point(10.0, 11.0, 12.0));

?>
--EXPECT--
object(Point)#1 (3) {
  ["x"]=>
  float(10)
  ["y"]=>
  float(1)
  ["z"]=>
  float(2)
}
object(Point)#1 (3) {
  ["x"]=>
  float(10)
  ["y"]=>
  float(11)
  ["z"]=>
  float(2)
}
object(Point)#1 (3) {
  ["x"]=>
  float(10)
  ["y"]=>
  float(11)
  ["z"]=>
  float(12)
}
