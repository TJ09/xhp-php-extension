--TEST--
PHP5.5 List in Foreach 04
--SKIPIF--
<?php 
if (version_compare(PHP_VERSION, '7.1', '<')) exit("Skip This test is for PHP 7.1 only.");
?>
--FILE--
<?php //xhp

$data = [
  1 => ['p', 'a'],
  2 => ['s', 's'],
];
foreach($data as $k => [$v1, $v2]) {
  echo $v1.$v2;
}
--EXPECT--
pass
