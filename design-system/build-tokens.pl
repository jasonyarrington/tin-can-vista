#!/usr/bin/env perl
# Generate tokens.css from tokens.json. Usage: perl build-tokens.pl
use strict;
use warnings;
use JSON::PP;
use File::Basename qw(dirname);

my $dir = dirname(__FILE__);
open my $in, '<:raw', "$dir/tokens.json" or die "tokens.json: $!";
my $tokens = JSON::PP->new->decode(do { local $/; <$in> });
close $in;

my @themes = map { $_->{id} } @{ $tokens->{color}{themes} };
my ($first, @rest) = @themes;

sub color_vars {
    my ($theme) = @_;
    return "  color-scheme: $theme;\n" . join '', map {
        my $v = $_->{value};
        $v = $v->{$theme} // $v->{$first} if ref $v;
        "  --$_->{name}: $v;\n";
    } @{ $tokens->{color}{tokens} };
}

my $out = "/* $tokens->{name} - generated from tokens.json by build-tokens.pl. Do not edit. */\n";
$out .= "\@import url('https://fonts.googleapis.com/css2?family=Archivo:ital,wght\@0,400;0,500;0,600;1,400&family=Big+Shoulders+Stencil+Display:wght\@700;800&display=swap');\n\n";

# Light is the default; dark follows the OS unless data-theme overrides it.
$out .= ":root, [data-theme=\"$first\"] {\n" . color_vars($first) . "}\n\n";
for my $t (@rest) {
    $out .= "[data-theme=\"$t\"] {\n" . color_vars($t) . "}\n\n";
}
if (@rest) {
    my $dark = $rest[0];
    $out .= "\@media (prefers-color-scheme: $dark) {\n  :root:not([data-theme=\"$first\"]) {\n"
          . join('', map { "  $_" } split /^/, color_vars($dark))
          . "  }\n}\n\n";
}

$out .= ":root {\n";
for my $fam (qw(spacing radius)) {
    $out .= "  --$_->{name}: $_->{value};\n" for @{ $tokens->{$fam}{tokens} };
}
$out .= "  --font-$_: $tokens->{type}{families}{$_};\n" for sort keys %{ $tokens->{type}{families} };
$out .= "}\n\n";

for my $group (@{ $tokens->{type}{groups} }) {
    for my $s (@{ $group->{styles} }) {
        my $fam = $s->{family} // $group->{family};
        $out .= ".$s->{name} {\n  font-family: var(--font-$fam);\n  font-size: $s->{fontSize};\n  line-height: $s->{lineHeight};\n  font-weight: $s->{fontWeight};\n";
        $out .= "  letter-spacing: $s->{letterSpacing};\n" if defined $s->{letterSpacing};
        $out .= "  font-style: $s->{fontStyle};\n" if defined $s->{fontStyle};
        $out .= "}\n";
    }
}

open my $fh, '>:raw', "$dir/tokens.css" or die "tokens.css: $!";
print $fh $out;
close $fh;
print "Wrote $dir/tokens.css\n";
