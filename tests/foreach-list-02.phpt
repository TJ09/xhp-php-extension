--TEST--
PHP5.5 List in Foreach 02
--SKIPIF--
<?php 
if (version_compare(PHP_VERSION, '5.5', '<')) exit("Skip This test is for PHP 5.5 only.");
?>
--FILE--
<?php //xhp

$data = [
  1 => ['p', 'a'],
  2 => ['s', 's'],
];
foreach($data as $k => list($v1, $v2)) {
  echo $v1.$v2;
}
--EXPECT--
pass
