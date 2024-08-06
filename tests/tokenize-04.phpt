--TEST--
xhp_token_get_all should not parse keywords in class names, functions, or after ::
--FILE--
<?php
$tokens = xhp_token_get_all(<<<'code'
<?php

foo::extends();

code
);

foreach($tokens as $tok) {
  if (is_array($tok) && xhp_token_name($tok[0]) !== 'T_WHITESPACE') {
	echo xhp_token_name($tok[0]).' '.$tok[1];
	echo PHP_EOL;
  }
}
--EXPECT--
T_OPEN_TAG <?php

T_STRING foo
T_PAAMAYIM_NEKUDOTAYIM ::
T_EXTENDS extends
