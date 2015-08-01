use strict;
use warnings FATAL => 'all';
use utf8;

use Test::MockObject;
use Test::Mock::Guard;

use t::Util;
use Devel::Cover::Report::Codecov;

sub get_file_coverage {
    Devel::Cover::Report::Codecov::get_file_coverage(@_);
}

subtest basic => sub {
    my $guard = mock_guard(
        'Devel::Cover::Report::Codecov',
        {
            get_file_lines    => sub {
                my $file = shift;
                is $file, 'lib/Test/File.pm';
                return 3;
            },
            get_line_coverage => sub {
                my (undef, $n) = @_;
                cmp_ok $n, '>=', 1;
                cmp_ok $n, '<=', 3;
                return [ undef, 0, undef, 5 ]->[$n];
            },
        });

    my $db    = Test::MockObject->new;
    my $cover = Test::MockObject->new;
    my $file  = Test::MockObject->new;

    $db->mock(cover => sub { $cover });
    $cover->mock(file => sub { $file });
    $file->mock(statement => sub { 'statement' });

    cmp_deeply
        { get_file_coverage('lib/Test/File.pm', $db) },
        { 'lib/Test/File.pm' => [ undef, 0, undef, 5 ] };

    is $guard->call_count('Devel::Cover::Report::Codecov', 'get_file_lines'), 1;
    is $guard->call_count('Devel::Cover::Report::Codecov', 'get_line_coverage'), 3;

    ok $db->called('cover');
    ok $cover->called('file');
    ok $file->called('statement');
};

done_testing;
