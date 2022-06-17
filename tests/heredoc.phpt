--TEST--
Heredoc Fastpath
--FILE--
<?php
$foo = <<<EOF
?>
EOF;

$foo = <<<'BAR'
?>
BAR;
$foo = b<<<'BAR'
?>
BAR;
if (0) $foo = <a />;

echo "pass";
--EXPECT--
pass
