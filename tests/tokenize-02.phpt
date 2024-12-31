--TEST--
xhp_token_name return the token name
--FILE--
<?php
echo xhp_token_name(323);
--EXPECT--
T_EVAL
