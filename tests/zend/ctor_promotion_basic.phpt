--TEST--
[Zend] Constructor promotion (basic example)
--SKIPIF--
<?php
if (version_compare(PHP_VERSION, '8.0', '<')) exit("Skip This test is for PHP 8.0+ only.");
?>
--FILE--
<?php // xhp

class Point {
    public function __construct(public int $x, public int $y, public int $z) {}
}

$point = new Point(1, 2, 3);

// Check that properties really are typed.
try {
    $point->x = "foo";
} catch (TypeError $e) {
    echo $e->getMessage(), "\n";
}

?>
--EXPECT--
Cannot assign string to property Point::$x of type int
