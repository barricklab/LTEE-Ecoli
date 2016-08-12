#!/usr/bin/env perl


use strict;
use warnings;
use Data::Dumper;

sub load_gd_file
{
	my ($file_name) = @_;

	print $file_name . "\n";
	my $gd_file;

	open GDFILE, "<$file_name" or die "Can't open $file_name.";
	my @lines = <GDFILE>;
	@lines = grep !/^\s*$/, @lines;

	LINE: foreach my $line (@lines)
	{
		chomp $line;
		# Comment or header line
		if ($line =~ m/^\s*#/) 
		{
			if ($line =~ m/\s*#=(\S+)\s+(\S+)/)
			{
				$gd_file->{header}->{$1} = $2;
			}
		}
		#normal line - not blank
		else
		{
			my @split_line = split /\t/, $line;
			my $mut;
			
			$mut->{snp_type} = "not_snp";
			
			#line specs
			#(INV,make_vector<string> (SEQ_ID)(POSITION)(SIZE))
			#(AMP,make_vector<string> (SEQ_ID)(POSITION)(SIZE)(NEW_COPY_NUMBER))
			#(CON,make_vector<string> (SEQ_ID)(POSITION)(SIZE)(REGION))
			
			$mut->{type} = shift @split_line;
						
			#skip if not a mutation
			if (length($mut->{type}) != 3) 
			{
				next LINE;
			}
			
			$mut->{id} = shift @split_line;
			$mut->{parent_ids} = shift @split_line;
			$mut->{seq_id} = shift @split_line;	
			$mut->{position} = shift @split_line;			
						
			if ($mut->{type} eq "SNP")
			{
				$mut->{new_seq} = shift @split_line;
			}
			elsif ($mut->{type} eq "SUB")
		
			{
				$mut->{size} = shift @split_line;
				$mut->{new_seq} = shift @split_line;
			}
			elsif ($mut->{type} eq "DEL")

			{
				$mut->{size} = shift @split_line;
			}
			elsif ($mut->{type} eq "INS")
			{
				$mut->{new_seq} = shift @split_line;
			}
			elsif ($mut->{type} eq "MOB")
			{
				$mut->{repeat_name} = shift @split_line;
				$mut->{strand} = shift @split_line;
				$mut->{duplication_size} = shift @split_line;
			}
			elsif ($mut->{type} eq "INV")
			{
				$mut->{size} = shift @split_line;
			}
			elsif ($mut->{type} eq "AMP")
			{
				$mut->{size} = shift @split_line;
				$mut->{new_copy_number} = shift @split_line;
			}
			elsif ($mut->{type} eq "CON")
			{
				$mut->{size} = shift @split_line;
				$mut->{region} = shift @split_line;
			}		
			
			# extra fields
			foreach my $split_line_piece (@split_line) {
				die if (!($split_line_piece=~ m/^(.+?)=(.+)$/));
				
				$mut->{$1} = $2;
			}
			
			# sanitize the javascript for multiple gene output 
			if (defined $mut->{html_gene_product}) {
   			 $mut->{html_gene_product} =~ s/^<i title=\"/<i>/;
			 $mut->{html_gene_product} =~ s/\">.*$/<\/i>/;
			}			
			
			push @{$gd_file->{mutations}}, $mut;
		}
	}
	
	if (!defined $gd_file->{header}->{STRAIN})
	{
		my $strain = $gd_file->{header}->{TITLE};
		$strain =~ s/^.+_.+_//;
		if ($strain =~ m/^\d/)
		{
			$strain = "REL" . $strain;
		}
		$gd_file->{header}->{STRAIN} = $strain;
	}
	
	return $gd_file;
}

#input files
my $input_path = "LTEE-clone-curated-annotated";
opendir(DIR, $input_path);
my @d = readdir DIR;
@d = grep /\.gd$/, @d;

#output  file
open OUT, ">shiny/LTEE-clone-curated.tsv";

my @header_list =  ('treatment', 
					'population', 
					'time',
					'strain', 
					'clone', 
					'mutator_status', 
					'type', 
					'start_position',
					'end_position', 
					'gene_position', 
					'html_position', 
					'html_mutation', 
					'html_mutation_annotation',
					'gene_list', 
					'gene_name', 
					'html_gene_name', 
					'gene_product', 
					'html_gene_product',
					'locus_tag',
					'mutation_category',
					'snp_type'
					);

@header_list = map { "\"$_\"" } @header_list;

print OUT +join("\t", @header_list) . "\n";

foreach my $f (@d) 
{
	print "Processing $f\n";
	my $gd_file = load_gd_file( $input_path . "/" . $f);
	
	if ($gd_file->{header}->{TIME} == 0) 
	{
		next;
	}
	
	for my $mut (@{$gd_file->{mutations}})
	{
		my @this_list = (
				$gd_file->{header}->{TREATMENT}, 
				$gd_file->{header}->{POPULATION},
				$gd_file->{header}->{TIME},
				$gd_file->{header}->{STRAIN},
				$gd_file->{header}->{CLONE},
				$gd_file->{header}->{MUTATOR_STATUS},
				$mut->{type},
				$mut->{start_position},
				$mut->{end_position},
				$mut->{gene_position},
				$mut->{html_position},
				$mut->{html_mutation},
				$mut->{html_mutation_annotation},
				$mut->{gene_list},
				$mut->{gene_name},
				$mut->{html_gene_name},
				$mut->{gene_product},
				$mut->{html_gene_product},
				$mut->{locus_tag},
				$mut->{mutation_category},
				$mut->{snp_type}
		);
		
		@this_list = map { "\"$_\"" } @this_list;
		print OUT +join("\t",  @this_list) . "\n"
		
	}
	print +(scalar @{$gd_file->{mutations}}) . " mutations\n";
}
