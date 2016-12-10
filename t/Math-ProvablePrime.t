package t::Math::ProvablePrime;

use strict;
use warnings;

BEGIN {
    if ( $^V ge v5.10.1 ) {
        require autodie;
    }
}

use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More;
use Test::NoWarnings;
use Test::Deep;
use Test::Exception;

use lib "$FindBin::Bin/lib";

use parent qw(
    Test::Class
);

use Math::ProvablePrime ();

if ( !caller ) {
    my $test_obj = __PACKAGE__->new();
    plan tests => $test_obj->expected_tests(+1);
    $test_obj->runtests();
}

#----------------------------------------------------------------------

sub test_find : Tests(1) {
    my ($self) = @_;

    my $ossl_bin = `which openssl`;

    SKIP: {
        skip 'No OpenSSL!', 1 if !$ossl_bin || $?;

        chomp $ossl_bin;

        `$ossl_bin prime -hex ff`;
        if ($?) {
            skip "$ossl_bin can’t verify primes from the command line!";
        }

        my $CHECK_COUNT = 100;

        lives_ok(
            sub {
                for ( 1 .. $CHECK_COUNT ) {
                    note "Check $_";
                    my $num_bin = substr( Math::ProvablePrime::find(512)->as_hex(), 2 );
                    my $ossl_out = `$ossl_bin prime -hex $num_bin`;
                    die $ossl_out if $ossl_out !~ m<is prime>;

                    note "OK";
                }
            },
            "Generated and verified $CHECK_COUNT primes",
        );
    }

    return;
}
