--TEST--
Closing PHP tag inside control structures 03
--FILE--
<?php

if (true) {
	if (true) {
?>
pass
<?
	}
}
--EXPECT--
pass
