<?php

$parser = file_get_contents('xhp/parser.y');

foreach(get_defined_constants(true)['tokenizer'] as $token => $value) {
	if (!str_starts_with($token, 'T_')) {
		continue;
	}
	$parser = preg_replace(
		'/%token '.preg_quote($token).' \d+/',
		"%token {$token} ".constant($token),
		$parser,
	);
}

file_put_contents('xhp/parser.y', $parser);
