--TEST--
xhp_preprocess_code 02
--FILE--
<?php
$xhp = <<<XHP
<?php
class :thing
}
XHP;
print_r(xhp_preprocess_code($xhp));
--EXPECT--
Array
(
    [error] => syntax error, unexpected '}', expecting '{'
    [error_line] => 3
)
