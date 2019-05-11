--TEST--
Closing PHP tag inside control structures 02
--FILE--
<?php

if (true) {
	if (true) {
?>
pass
<?php
	}
}
--EXPECT--
pass
