<?php

$orig_parser = $parser = file_get_contents('xhp/parser.y');

if (version_compare(PHP_VERSION, '8.5', '<')) {
	// PHP 8.5 tokens
	$parser = preg_replace('/%token T_VOID_CAST \d+/', '%token T_VOID_CAST 6000', $parser);
	$parser = preg_replace('/%token T_PIPE \d+/', '%token T_PIPE 6001', $parser);
}

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

if ($orig_parser !== $parser) {
	file_put_contents('xhp/parser.y', $parser);
}
