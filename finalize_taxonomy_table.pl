#!/usr/bin/perl

use strict;
use warnings;

my ($diamond_output, $taxonomy_summary, $output_file) = @ARGV;

open my $in1, '<', $diamond_output or die "$!";
my %was_found_gene = ();
my %was_found_isoform = ();

while (<$in1>){
    chomp;
    my @split = split/\t/;

    if ($was_found_isoform{$split[0]}){     
	next;
    }
    else {
        $was_found_isoform{$split[0]} = 1;
        
	$split[0] =~ m/TRINITY_DN\d+_c\d+_g\d+/;
	my $gene = $&;
        $split[1] =~ s/\.\d+$//;
        push @{ $was_found_gene{$gene} }, $split[1];
    }
}

my %taxonomy_of = ();
open my $in2, '<', $taxonomy_summary or die "$!";

while (<$in2>){
    chomp;
    my @taxonomy = split/\t/;
    $taxonomy_of{$taxonomy[0]} = $_;
}

close $in2;

open my $out, '>', $output_file or die "$!";

foreach my $gene (sort {$a cmp $b} keys %was_found_gene){
    my @hits = sort{ $a cmp $b } keys %{{ map {$_ => 1} @{ $was_found_gene{$gene} } }};
    foreach my $hit (@hits){
        print $out join ("\t", $gene, $taxonomy_of{$hit}) . "\n";
    }
}

close $out;

__END__
