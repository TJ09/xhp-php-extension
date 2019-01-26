--TEST--
Closing PHP tag inside control structures 01
--FILE--
<?php //xhp
if (true) {
?>
pass
<?php } ?>
--EXPECT--
pass
