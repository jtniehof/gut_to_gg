#!/usr/bin/perl
#Convert GutWrench plugins to guiguts .rc format
#run with no parameters for usage info
#0.1 19 Mar 2006 JTN

sub error_out;
sub dump_hash;

$ver='0.1';

(@ARGV < 4 and @ARGV > 1) or error_out("Must have two or three arguments\n");
$two_files = (@ARGV == 3);

#Load up hashes with patterns and comments
open(INPUT,"$ARGV[0]") or error_out("Unable to open input file $ARGV[0]\n");
while ($line = <INPUT>) { 
    next if ($line =~ /^\\/);
#chomp would be nice, but if we're reading in files with DOS
#newlines, Bad Stuff happens
    $line =~ s/\n|\cm//g;
    if ($two_files and (length($line) < 5)) {
	$w_scannoslist{$line}=''; }
    else {
	$s_scannoslist{$line}=''; }
}

close INPUT;

#Write each hash out to the appropriate file
open(OUT,">$ARGV[1]") or error_out("Unable to open string output file $ARGV[1]\n");
print OUT "\#Generated from wrench2gui $ver
\#String matches
\#Gutwrench provides no suggested replacement!\n"
    or error_out("Error writing string output\n");
dump_hash(\*OUT,'%scannoslist',%s_scannoslist);
close OUT;

if($two_files) {
    open(OUT,">$ARGV[2]") or error_out("Unable to open word output file $ARGV[2]\n");
    print OUT "#Generated from wrench2gui $ver
#Word matches
#Gutwrench provides no suggested replacement!\n"
	or error_out("Error writing word output\n");
    dump_hash(\*OUT,'%scannoslist',%w_scannoslist);
    close OUT;
}

sub error_out {
    print <<EOF;
wrench2gui: convert GutWrench plugins to guiguts .rc file (v. 0.1)
Usage: wrench2gui input.txt out_string.rc [out_word.rc]
Where:
   input.txt     (in)  is a GutWrench plugin file
   out_string.rc (out) String (subword) based rules
                       Run with neither "Whole Word" nor "Regex" selected
   out_word.rc   (out) Word-based rules
                       Run with "Whole Word" selected in GuiGuts
		       (Optional. If not specified, all rules assumed string).

To use the output, select "Stealth Scannos" from the Search menu and
browse to the rc file. See the guiguts manual for more details.

GutWrench has two kinds of rules: string, and word. These need
to be used with different options in guiguts, so different files are
produced.

GutWrench's "impossible" and "improbable" files consist entirely of string
matches, so they should be processed with a single output file. When
handling the scanno files, GutWrench assumes complete word if the pattern
is four letters or less; string match if five letters or more. If you
specify two output files on the command line, this script will apply
the same logic to distribute the rules.

The creative will weave together multiple input files to a single output.
Maybe eventually this script will be smart enough to do that.

ERROR:
EOF
    die @_;
}

#Write out the contents of a hash to an open file
#parameters: file handle, name, hash
sub dump_hash {
    my ($fh,$name,%hash,$key,$value,$line);
    ($fh,$name,%hash)=@_;
    print $fh $name,' = (',"\n" or error_out("Error writing hash $name\n");
    while (($key,$value) = each %hash) {
	$key =~ s/(\\|\')/\\$1/g;
	$value =~ s/(\\|\')/\\$1/g;
	$line = join '','\'',$key,'\' => \'',$value,"\',\n";
	print $fh $line or error_out("Error writing hash $name\n");
    }
    print $fh "\);\n\n" or error_out("Error writing hash $name\n");
}
