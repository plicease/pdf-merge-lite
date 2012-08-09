use strict;
use warnings;
use File::HomeDir::Test;
use File::HomeDir;
use Test::More tests => 20;
use Test::Mojo;
use FindBin ();
use File::Copy qw( copy );
use File::Spec;

mkdir( File::Spec->catdir(File::HomeDir->my_home, 'PDF') );
copy(
  File::Spec->catfile($FindBin::Bin, 'test.pdf'),
  File::Spec->catfile(File::HomeDir->my_home, 'PDF', 'test.pdf'),
) or die "Copy failed: $!";

$ENV{TEST_PDF_MERGE} = 1;
require(File::Spec->catfile( $FindBin::Bin, File::Spec->updir, 'pdf-merge'));

my $t = Test::Mojo->new;

$t->get_ok('/')
  ->status_is(302)
  ->header_like('Location', qr/http:\/\/localhost:\d+\/pdf/, 'redirect to /pdf');

$t->get_ok('/pdf')
  ->status_is(200);

is $t->tx->res->dom->at('html head title')->text, 'PDF', 'title = PDF';
is $t->tx->res->dom->at('html body form')->attrs('method'), 'post', 'method = post';
is $t->tx->res->dom->at('html body form')->attrs('action'), '/pdf/merge', 'action = /pdf/merge';
is $t->tx->res->dom->at('td a')->attrs('href'), '/pdf/test.pdf', 'href = /pdf/test.pdf';
is $t->tx->res->dom->at('td a')->text, 'test', 'text = test';

$t->get_ok('/pdf/bogus.pdf')
  ->status_is(404);

$t->get_ok('/pdf/test.pdf')
  ->status_is(200);

$t->post_ok('/pdf/merge')
  ->status_is(302)
  ->header_like('Location', qr/http:\/\/localhost:\d+\/pdf/, 'redirect to /pdf');

$t->get_ok('/pdf')
  ->status_is(200);

is $t->tx->res->dom->at('span#pdf_merge_error')->text, 'No PDFs specified for merge', 'error = No PDFs specified for merge';

# FIXME test arguments passed into /pdf/merge
#$t->post_ok('/pdf/merge', 'UTF-8' => { pdf_0 => 1, pdf_0_name => 'test' })
#  ->status_is(302);
#diag $t->tx->req->to_string;
#diag $t->tx->res->to_string;

# FIXME test GET /pdf/merge/list/of/pdfs/and/stuff
