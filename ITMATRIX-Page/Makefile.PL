use 5.008009;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'ITMATRIX::Page',
    VERSION_FROM      => 'lib/ITMATRIX/Page.pm', # finds $VERSION
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/ITMATRIX/Page.pm', # retrieve abstract from module
       AUTHOR         => 'User & <shop2you@itmatrix.ru>') : ()),
);
