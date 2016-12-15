package Math::ProvablePrime::Rand;

use strict;
use warnings;

#Return a random integer N such that $lower <= N <= $upper.
#cf. Python random.randint()
#TODO: test this
sub int {
    my ($lower, $upper) = @_;

    my $is_bigint = ref $upper;

    my $diff = $is_bigint ? $upper->copy()->bsub($lower) : ($upper - $lower);

    my $diff_bin = $is_bigint ? substr( $diff->as_bin(), 2 ) : sprintf('%b', $diff);

    my $bit_length = length $diff_bin;

    my $ct_of_chunks_of_32_bits = int( $bit_length / 32 );
    my $ct_of_leftover_bits = $bit_length % 32;

    my $diff_hex = $is_bigint ? substr( $diff->as_hex(), 2 ) : sprintf('%x', $diff);

    my $hex;
    do {
        #$rand = Math::BigInt->from_bin( $rng->string_from('01', length $diff_bin) );

        $hex = join( q<>, map { sprintf '%08x', _irand() } 1 .. $ct_of_chunks_of_32_bits );

        #Now the remaining bits
        if ($ct_of_leftover_bits) {
            substr( $hex, 0, 0) = sprintf '%x', int rand( (2 ** $ct_of_leftover_bits) );
        }

    } while (length($hex) == length($diff_hex)) && ($hex gt $diff_hex);

    #TODO: Allow this to return scalars.
    return $is_bigint ? Math::BigInt->from_hex($hex)->badd($lower) : ($lower + hex $hex);
}

#cf. Bytes::Random::Secure::Tiny … but NOT cryptographic-strength
sub _irand {
    return CORE::int(0.5 + rand) + CORE::int(rand 0xffffffff);
}

1;
