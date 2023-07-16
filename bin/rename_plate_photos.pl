#!/usr/bin/perl -w

###
# Pod Documentation
###

=head1 NAME

rename_plate_photos.pl

=head1 SYNOPSIS

Usage: rename_plate_photos.pl -i raw -o renamed -p "075500gen_#s_#p_24h_bottom_#i"

=head1 DESCRIPTION

=over

=item B<-i,--input> <path to folder>

Path to input folder.

=item B<-o,--output> <path to folder>

Path to output folder. Created if it doesn't exist.

=item B<-f,--format> <format_string>

Format string to create output file names. 

#p will be replaced with the plate type
#s will be replaced with the sample name
#i will be replaced with the input file name with the input file name

Default: "#s-#p-#i"

=item B<-2,--suffix> <string>

Suffix to add to all files.

=item B<-s,--samples> <string>

Names of samples or keyword for preset.
Valid presets:  LTEE-INTERSPERSED, LTEE-INTERSPERSED+ANCESTORS, LTEE-ORDERED, LTEE-ORDERED+ANCESTORS.

Interspersed: A–1, A+1, A–2, A+2, A–3, A+3, A–4, A+4, A–5, A+5, A–6, A+6 
Ordered:      A–1, A–2, A–3, A–4, A–5, A–6, A+1, A+2, A+3, A+4, A+5, A+6

Int+Anc: REL606, REL607, A–1, A+1, A–2, A+2, A–3, A+3, A–4, A+4, A–5, A+5, A–6, A+6 
Ord+Anc: REL606, A–1, A–2, A–3, A–4, A–5, A–6, REL607, A+1, A+2, A+3, A+4, A+5, A+6


=item B<-p,--plates]> <string>

List of types of plates. Default = [MG, MA, TA]

=back

=head1 AUTHOR

Jeffrey Barrick

=head1 COPYRIGHT

Copyright 2023.  All rights reserved.

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
my ($input, $output, $format);
my @samples = ();
my @plates = ();

#pod2usage(1) if (scalar @ARGV == 0);
GetOptions(
	'help|h' => \$help, 'man' => \$man,
	'input|i=s' => \$input,
	'output|o=s' => \$output,
	'format|f=s' => \$prefix,
	'samples|s=s' => \@samples,
	'plates|p=s' => \@plates

) or pod2usage(2);
pod2usage(1) if $help;
pod2usage(-exitstatus => 0, -verbose => 2) if $man;

if (scalar (@samples) == 0) {
	print("ERROR:-s|--sample option required\n\n");
	pod2usage(-verbose => 1);
}


$prefix = "#p_#s_#i" if (!defined $format);
$suffix = "" if (!defined $suffix);
$input = "." if (!defined $input);
$output = "../output" if (!defined $output);

if (scalar @samples == 1) {

	my $preset_sample_set_name = "\U$samples[0]";

	if ($preset_sample_set_name eq "LTEE-INTERSPERSED") {
		@samples = (
			"Ara-1",
			"Ara+1",
			"Ara-2",
			"Ara+2",
			"Ara-3",
			"Ara+3",
			"Ara-4",
			"Ara+4",
			"Ara-5",
			"Ara+5",
			"Ara-6",
			"Ara+6",
		);
	} if ($preset_sample_set_name eq "LTEE-INTERSPERSED+ANCESTORS") {
		@samples = (
			"Ara-1",
			"Ara+1",
			"Ara-2",
			"Ara+2",
			"Ara-3",
			"Ara+3",
			"Ara-4",
			"Ara+4",
			"Ara-5",
			"Ara+5",
			"Ara-6",
			"Ara+6",
		);
	} elsif ($preset_sample_set_name eq "LTEE-ORDERED") {
		@samples = (
			"Ara-1",
			"Ara-2",
			"Ara-3",
			"Ara-4",
			"Ara-5",
			"Ara-6",
			"Ara+1",
			"Ara+2",
			"Ara+3",
			"Ara+4",
			"Ara+5",
			"Ara+6"
		);
	}
	elsif ($preset_sample_set_name eq "LTEE-ORDERED+ANCESTORS") {
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
}

if ( scalar (@plates) == 0) {

	@plates = (
		"MG",
		"MA",
		"TA"
	);

}

# All plates for one sample, then next sample...
my @output_file_name_stubs = ();
foreach my $sample (@samples) {
	print("$sample\n");
	foreach my $plate (@plates) {
		my $this_file_name_stub = $format;
		$this_file_name_stub =~ s/\#s/$sample/ge;
		$this_file_name_stub =~ s/\#p/$population/ge;
		push $this_file_name_stub;
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


exit "Unequal number of input and output file names." if (scalar @output_file_name_stubs != scalar @input_file_names);


my @output_file_names = ();
my $i=0;
foreach my $input_file_name (@input_file_names) {
	my $this_output_file_name = $output_file_name_stubs[$i]
	$this_output_file_name =~ s/\#i/$input_file_name/ge;
	push @output_file_names, $prefix . $output_file_name_stubs[$i] . $suffix . $input_file_name;
	$i++;
}

print "Output File Names:" . join(",", @output_file_names) . "\n";

$i=0;
make_path($output);
foreach my $input_file_name (@input_file_names) {
	my $command = "cp \"$input/$input_file_name\" \"$output/$output_file_names[$i]\"";
	print $command . "\n";
	system($command);
	$i++;
}
