use strict;
use warnings;
use Test::More tests => 2;
use Test::Mojo;
use FindBin;
$ENV{TEST_PDF_MERGE} = 1;
require "$FindBin::Bin/../pdf-merge";

my $t = Test::Mojo->new;
$t->get_ok('/pdf')->status_is(200);
