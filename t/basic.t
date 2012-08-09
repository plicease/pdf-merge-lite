use strict;
use warnings;
use File::HomeDir::Test;
use File::HomeDir;
use Test::More tests => 36;
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
  ->status_is(200)
  ->content_type_is('application/x-download;name=test.pdf');

is PDF::API2->openScalar( $t->tx->res->body )->pages, 1, "test.pdf pages = 1";

$t->post_ok('/pdf/merge')
  ->status_is(302)
  ->header_like('Location', qr{http://localhost:\d+/pdf}, 'redirect to /pdf');

$t->get_ok('/pdf')
  ->status_is(200);

is $t->tx->res->dom->at('span#pdf_merge_error')->text, 'No PDFs specified for merge', 'error = No PDFs specified for merge';

$t->post_form_ok('/pdf/merge', { pdf_0 => 1, pdf_0_name => 'test' } )
  ->status_is(302)
  ->header_like('Location', qr{http://localhost:\d+/pdf/merge/test}, 'redirect to /pdf/test');

copy(
  File::Spec->catfile($FindBin::Bin, 'test2.pdf'),
  File::Spec->catfile(File::HomeDir->my_home, 'PDF', 'test2.pdf'),
) or die "Copy failed: $!";

$t->get_ok('/pdf/test2.pdf')
  ->status_is(200)
  ->content_type_is('application/x-download;name=test2.pdf');

is PDF::API2->openScalar( $t->tx->res->body )->pages, 4, "test2.pdf pages = 4";

$t->post_form_ok('/pdf/merge', { pdf_0 => 1, pdf_0_name => 'test', pdf_1 => 1, pdf_1_name => 'test2' } )
  ->status_is(302)
  ->header_like('Location', qr{http://localhost:\d+/pdf/merge/test/test2}, 'redirect to /pdf/test/test2');

$t->get_ok('/pdf/merge/test/test2')
  ->status_is(200)
  ->content_type_like(qr{application/x-download;name=pdf_merge_\d{12}_....\.pdf});

is PDF::API2->openScalar( $t->tx->res->body )->pages, 5, "test/test2 pages = 5";
