#!/usr/bin/perl -w

###
# Pod Documentation
###

=head1 NAME

rename_plate_photos.pl

=head1 SYNOPSIS

Usage: rename_plate_photos.pl "[command]"



=head1 DESCRIPTION

=over

=item B<-i,--input> <path to folder> 

Path to input folder.

=item B<-2,--output> <path to folder>

Path to output folder.

=item B<-1,--prefix> <string> 

Prefix to add to all filenames.

=item B<-2,--suffix> <string>

Suffix to add to all files.

=back

=head1 AUTHOR

Jeffrey Barrick

=head1 COPYRIGHT

Copyright 2022.  All rights reserved.

=cut

###
# End Pod Documentation
###

use strict;

use FindBin;
use lib $FindBin::Bin;
use Data::Dumper;
use File::Path qw(make_path);

#Get options
use Getopt::Long;
use Pod::Usage;
my ($help, $man);
my ($input, $output, $prefix, $suffix);
my @samples = ();
my @plates = ();

#pod2usage(1) if (scalar @ARGV == 0);
GetOptions(
	'help|?' => \$help, 'man' => \$man,
	'input|i=s' => \$input,
	'output|o=s' => \$output,
	'prefix|1=s' => \$prefix,
	'suffix|2=s' => \$suffix,
) or pod2usage(2);
pod2usage(1) if $help;
pod2usage(-exitstatus => 0, -verbose => 2) if $man;

$prefix = "" if (!defined $prefix);
$suffix = "" if (!defined $suffix);
$input = "." if (!defined $input);
$output = "../output" if (!defined $output);


if ( scalar(@samples) == 0 ) {
	print "Here\n";
	@samples = (
		"REL606",
		"Ara-1",
		"Ara-2",
		"Ara-3",
		"Ara-4",
		"Ara-5",
		"Ara-6",
		"REL607",
		"Ara+1",
		"Ara+2",
		"Ara+3",
		"Ara+4",
		"Ara+5",
		"Ara+6"
	);

}

if ( scalar (@plates) == 0) {

	@plates = (
		"TA",
		"MG",
		"MA"
	);

}

my @output_file_name_stubs = ();
foreach my $sample (@samples) {
	foreach my $plate (@plates) {
	 push @output_file_name_stubs, $sample . ", " . $plate;
	}
}

my $current = `pwd`;
chomp $current;
print "Current Path: " . $current. "\n";
print "Input Path: " . $input . "\n";
print "Output Path: " . $output . "\n";
print "Prefix: " . $prefix . "\n";
print "Suffix: " . $suffix . "\n";
print "Samples: " . join(",", @samples) . "\n";
print "Plates: " . join(",", @plates) . "\n";



opendir(DIR, $input);
my @input_file_names = readdir DIR;
@input_file_names = grep !/^\./, @input_file_names; #Skip underscore prefixed
@input_file_names = grep !/^\./, @input_file_names; #Skip period prefixed
@input_file_names = grep !/^_/, @input_file_names; #Skip period prefixed
@input_file_names = grep {!(-d $_)} @input_file_names;
@input_file_names = sort @input_file_names;

print "Input File Names:" . join(",", @input_file_names) . "\n";

my @output_file_names = ();
my $i=0;
foreach my $input_file_name (@input_file_names) {
	push @output_file_names, $prefix . $output_file_name_stubs[$i] . $suffix . $input_file_name;
	$i++;
}

print "Output File Names:" . join(",", @output_file_names) . "\n";

exit "Unequal number of input and output file names." if (scalar @output_file_names != scalar @input_file_names);

$i=0;
make_path($output);
foreach my $input_file_name (@input_file_names) {
	my $command = "cp \"$input/$input_file_name\" \"$output/$output_file_names[$i]\"";
	print $command . "\n";
	system($command);
	$i++;
}