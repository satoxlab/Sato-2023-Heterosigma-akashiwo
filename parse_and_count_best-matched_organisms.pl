#!/usr/bin/perl

use strict;
use warnings;

my ($input_file, $input_fasta, $output_file) = @ARGV;
my %COUNTS_OF = ();
my $gene_id   = q{};
open my $in, '<', $input_file or die "$!";

while (<$in>){
    chomp;
    my @data = split/\t/;
    
    if ($data[0] ne $gene_id){
        $COUNTS_OF{$data[12]} ++;
        $gene_id = $data[0];
    }
    else {
        next;
    }
}

close $in;

open my $in1,  '<', $input_fasta or die "$!";
my %gene_ids = ();

while (<$in1>){
    chomp;

    if (m/^>/){
	my @fasta_header = split/ /, $';
        $fasta_header[0] =~ s/_i\d+\.p\d+$//;
	$gene_ids{$fasta_header[0]} = 1;
    }
}

close $in1;

my $TOTAL = scalar(keys %gene_ids);
open my $out, '>', $output_file or die "$!";

foreach my $organism (keys %COUNTS_OF){
    print $out join ("\t", $organism, $COUNTS_OF{$organism}, ($COUNTS_OF{$organism}/$TOTAL)) . "\n";
}

print $out join ("\t", "all", $TOTAL, $TOTAL/$TOTAL) . "\n";
close $out;

__END__
