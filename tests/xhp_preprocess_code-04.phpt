--TEST--
xhp_preprocess_code 04
--FILE--
<?php
$xhp = <<<XHP
<?php
class thing {
}
XHP;
print_r(xhp_preprocess_code($xhp));
--EXPECT--
Array
(
)
