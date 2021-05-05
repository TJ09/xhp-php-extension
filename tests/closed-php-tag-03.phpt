--TEST--
Closing PHP tag inside control structures 03
--INI--
short_open_tag=1
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
