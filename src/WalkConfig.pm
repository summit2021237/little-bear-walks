package WalkConfig;

use strict;
use warnings;

use JSON;

sub new {
	return decode_json($_[1]);
}

1;
