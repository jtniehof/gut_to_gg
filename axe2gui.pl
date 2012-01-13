#!/usr/bin/perl
#Convert GutAxe plugins to guiguts .rc format
#run with no parameters for usage info
#0.2 21 Mar 2006 JTN

sub error_out;
sub dump_hash;

$ver='0.2';

@ARGV == 4 or error_out("Must have four arguments\n");

#Load up hashes with patterns and comments
open(INPUT,"$ARGV[0]") or error_out("Unable to open input file $ARGV[0]\n");
while ($line = <INPUT>) { 
    next unless ($line =~ /^(r|s|w)/);
#chomp would be nice, but if we're reading in files with DOS
#newlines, Bad Stuff happens
    $line =~ s/\n|\cm//g;
    $delim=substr($line,1,1);
    if ($delim =~ /[^\w]/) { $delim = "\\" . $delim };
    ($type,$pattern,$replace,$comment) = split(/$delim/,$line,4);
    for($type) {
	if (/r/) { $r_scannoslist{$pattern}=$replace;
		   $r_reghints{$pattern}=$comment;
		   last;}
	if (/s/) { $s_scannoslist{$pattern}=$replace;
		   $s_reghints{$pattern}=$comment;
		   last;}
	if (/w/) { $w_scannoslist{$pattern}=$replace;
		   $w_reghints{$pattern}=$comment;
		   last;}
    }
}
close INPUT;

#Write each hash out to the appropriate file
open(OUT,">$ARGV[1]") or error_out("Unable to open regex output file $ARGV[1]\n");
print OUT "#Generated from axe2gui $ver\n#Regex matches\n"
    or error_out("Error writing regex output\n");
dump_hash(\*OUT,'%scannoslist',%r_scannoslist);
dump_hash(\*OUT,'%reghints',%r_reghints);
close OUT;

open(OUT,">$ARGV[2]") or error_out("Unable to open string output file $ARGV[2]\n");
print OUT "#Generated from axe2gui $ver\n#String matches\n"
    or error_out("Error writing string output\n");
dump_hash(\*OUT,'%scannoslist',%s_scannoslist);
dump_hash(\*OUT,'%reghints',%s_reghints);
close OUT;

open(OUT,">$ARGV[3]") or error_out("Unable to open word output file $ARGV[3]\n");
print OUT "#Generated from axe2gui $ver\n#Word matches\n"
    or error_out("Error writing word output\n");
dump_hash(\*OUT,'%scannoslist',%w_scannoslist);
dump_hash(\*OUT,'%reghints',%w_reghints);
close OUT;

sub error_out {
    print <<EOF;
axe2gui: convert GutAxe plugins to guiguts .rc file (v. 0.1)
Usage: axe2gui input.txt out_regex.rc out_string.rc out_word.rc
Where:
   input.txt     (in)  is a GutAxe plugin file
   out_regex.rc  (out) Regex-based rules
                       Run with "Regex" selected in GuiGuts
   out_string.rc (out) String (subword) based rules
                       Run with neither "Whole Word" nor "Regex" selected
   out_word.rc   (out) Word-based rules
                       Run with "Whole Word" selected in GuiGuts

To use the output, select "Stealth Scannos" from the Search menu and
browse to the rc file. See the guiguts manual for more details.

GutAxe has three kinds of rules: regex, string, and word. These need
to be used with different options in guiguts, so different files are
produced.

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
