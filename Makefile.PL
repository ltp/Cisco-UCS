use strict;
use warnings;

use English;
use inc::Module::Install;

name         q{Cisco-UCS};
abstract     q{A Perl interface to the Cisco UCS XML API};
author       q{Luke Poskitt <ltp@cpan.org>};
license      q{perl};
all_from     q{lib/Cisco/UCS.pm};
version_from q{lib/Cisco/UCS.pm};

test_requires q{Test::More};

requires q{LWP};
requires q{XML::Simple};

tests_recursive;

WriteAll;
