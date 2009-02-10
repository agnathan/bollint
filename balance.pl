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
    open(INPUT, "<:encoding(UTF-8)", shift) or die "Couldn't open for reading: $!\n";
}

my $tr = qr/\s*(?:\\\\|\\\@)\s*/;


while (<INPUT>) {
    unless (m/^\$\$\$/) { 
        s/:[  ]*/: /ig;
        #s/\\\\Quand \\\\Paul\@\\\\eut\@\\\\\\\\dit cela, il\\\\\@ \\\\s\@\\\\\@ \\\\'\@\\\\\@ \\\\éleva\@\\\\\\\\/&matching($&)/g;
        #s/\\Quand \\Paul\@\\eut\@\\\\dit cela, il\\\@ \\s\@\\\@ \\'\@\\\@ \\éleva\@\\\\//g;
        # s/\\\\\\@ \\\\s\\@\\\\\\@ \\\\'\\@\\\\\\@ \\\\(\w+)\\@\\\\\\\\/\\\\\\\@s'$1\\\@\\\\/g;
        # s/\\\\\\@ \\\\s\\@\\\\\\@ \\\\'\\@\\\\\\@ \\\\(\w+)\\@\\\\\\\\/@{[\&matching($&)]}/g;
        # $_ = &matching($_);
        s/\\\\\\@ \\\\(\w+)\\@\\\\\\\\/\\\\\\@ $1\\@\\\\/g;
        s/\[\s*\\\\\s*\…\s*\\\\\s*\]/.../g;
        s/\[\s*\…\s*\]/.../g;
        s/\[\s*\.\.\.\s*\]/.../g;
        s/\(\s*\.\.\.\s*\)/.../g;
        s/\(\\\\/\\\\(/g;
        s/\\\\\)/\)\\\\/g;
        s/[  ]*(?:…|\.\.\.)[  ]*/ ... /g;

        # BOL problem: quand un chiffre est suivi par un espace unsecable la lettre suivante est toujours en minuscules
        s/(\d) ([A-Z])/$1 $2/g;
        s/ō/o/g;
        s/Ō/O/g;
        s/ī/i/g;
        s/Ī/I/g;
        s/’/'/g;
        s/‑/-/g;
        s/−/-/g;
         s/\\\\\[/\[\\\\/g;
         s/\\\\\]/\]\\\\/g;
        s/”/"/g;
        s/“/"/g;
        s/,#/, #/g;
        s/[  ]*;[  ]+/ ; /g;
        s/[  ]*:[  ]+/ : /g;
        s/http : /http:/g;
        s/[  ]*,/,/g;
        s/«[  ]*/« /g;
        s/[  ]*»/ »/g;
        s/. " »/." »/g;
        s/« \.\.\.  /« ... /g;
        s/\.\.\.[  ]*\?/.../g;
        s/\.\.\.[  ]*\./.../g;
        s/\.\.\.[  ]*\!/.../g;
        s/\\\@(-|–|−)/\\\@ -/g;
        s/\\\\\\\\//g;
        # s/\\\\\\@\\\\/\\\\ \\@ \\\\/g
    }
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

close(INPUT);
