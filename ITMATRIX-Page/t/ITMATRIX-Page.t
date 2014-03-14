use Test::More;
BEGIN { use_ok('ITMATRIX::Page') };
BEGIN { use_ok('ITMATRIX::Page::Index') };
BEGIN { use_ok('ITMATRIX::Page::Templater') };
BEGIN { use_ok('ITMATRIX::Page::Include') };
BEGIN { use_ok('ITMATRIX::Page::Main_page') };
BEGIN { use_ok('ITMATRIX::Page::Include::content') };


my $path ='/home/shop2you/data/www/cms.shop2you.ru/';
require $path.'cgi-bin/io_lib/io_app.pl';
my $app = 'io_app'->new();

my $obj = ITMATRIX::Page->new();
my $tmpl = ITMATRIX::Page::Templater->new( page_object => $obj );
my ($path, $name ) = $tmpl->_get_path_and_name();
is($path, '/home/shop2you/data/www/cms.shop2you.ru/generate/', 'path ok');
is($name, 'page.html', 'name ok');

$obj = ITMATRIX::Page::Main_page->new();
$tmpl = ITMATRIX::Page::Templater->new( page_object => $obj );
($path, $name ) = $tmpl->_get_path_and_name();
is($path, '/home/shop2you/data/www/cms.shop2you.ru/generate/', 'path ok');
is($name, 'page.html', 'name ok');


$obj = ITMATRIX::Page::Include->new(name => 'footer');
$tmpl = ITMATRIX::Page::Templater->new( page_object => $obj );
($path, $name ) = $tmpl->_get_path_and_name();
is($path, '/home/shop2you/data/www/cms.shop2you.ru/generate/include/', 'path ok');
is($name, 'footer.html', 'name ok');

# $obj = ITMATRIX::Page::Include::content->new(name => 'content');
# $tmpl = ITMATRIX::Page::Templater->new( page_object => $obj );
# ($path, $name ) = $tmpl->_get_path_and_name();
# is($path, '/home/shop2you/data/www/cms.shop2you.ru/generate/include/content/', 'path ok');
# is($name, 'content.html', 'name ok');


my $class = 'ITMATRIX::Page::Include::content';
eval { require $class };
my $obj = $class->new();
is(ref $obj, 'ITMATRIX::Page::Include::content', 'require OK');
done_testing();
