--TEST--
Yield keyword 04
--FILE--
<?php
function yieldTest() {
  $a = yield from [1,2,3,4,5];
}
foreach(yieldTest() as $b) {
	echo $b;
}
echo PHP_EOL;
function yieldTest2() {
  $a = yield
	from [1,2,3,4,5];
}
foreach(yieldTest2() as $b) {
	echo $b;
}
--EXPECT--
12345
12345
