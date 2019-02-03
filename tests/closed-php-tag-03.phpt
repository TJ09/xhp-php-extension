--TEST--
Closing PHP tag inside control structures 03
--FILE--
<?php //xhp

if (true) {
	if (true) {
?>
pass
<?
	}
}
--EXPECT--
pass
