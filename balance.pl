#/usr/bin/perl -w

use strict;
use warnings;

# Input files are assumed to be in the UTF-8 strict character encoding.
use utf8;
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");

use Getopt::Long;
use Data::Dumper;

# Globals
#
use vars qw/ %opt /;

#
# Command line options processing
#
my ($help) = '';

sub usage()
{
    print "
    
Equilibre et nettoye les styles de caractère à la Bible Online 
Balance and clean character styles for the Bible Online


Utilisation: $0 [-hvd] livre [livres ...]

 -h        : s'affiche cette message

exemple: $0 -h;
exemple: $0 - fichier1 fichier2";
        exit;
}

################################################################################
# Main Program
################################################################################
GetOptions (
                'help' => \$help,
           );

usage() if $help;

{
    local $/ = '';

    # Input and Output is encoded in the UTF-8 strict character encoding.
    my $input = shift;
    if (defined($input) && -e $input) {
        open(INPUT, "<:encoding(UTF-8)", $input);
    } else {
        *INPUT = *STDIN;
    }
}

my $tr = qr/\s*(?:\\\\|\\\@)\s*/;


while (<INPUT>) {
    # my $d = &isbalanced($_);
    my @p = split /($tr)/;

    my %state;
    foreach my $part (@p) {
        if ($part =~ m/($tr)/) {
            my $key = $part; 
            $key =~ s/\s*//g; 
            my $unesckey = $key;
            $key =~ s/./\\$&/g;
            if (defined($state{$key})) {
                $part =~ s/([\s ]+)$key/$unesckey$1/g;
                $state{$key} = undef;
            } else {
                $part =~ s/$key([\s ]+)/$1$unesckey/g;
                $state{$key} = 1;
            } 
        }
        print $part; 
    } 
}

# while ($subject =~ m/\d{1,3}/sxg) {
#     # matched text = $&
# }


# sub isbalanced {
#     my $count = split(/$tr/, shift);
#     return ($count > 1 && $count % 2 == 1);
# }

close(INPUT);
