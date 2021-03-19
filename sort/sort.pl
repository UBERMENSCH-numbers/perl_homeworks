use strict;
use feature 'fc';

sub comp_q ($$) {
	my ($a,$b) = @_;
	my ($a_,$b_) = @_;
	
	$a =~ tr/'" \t%//d;
	$b =~ tr/'" \t%//d;
	$a_ =~ tr/\n//d;
	$b_ =~ tr/\n//d;

	# print @_[0] cmp @_[1], "@_[0] cmp @_[1]\n";
	return (fc($a) cmp fc($b)) || ($b cmp $a) || $a_ cmp $b_ || (@_[0] cmp @_[1]);
}

my @filenames = grep { !/-/ } @ARGV;
my @keys = map { split (//, substr $_, 1, length $_) } grep { /-/ } @ARGV;
my %keys_hash = map { $_ => 1 } @keys;

# if(%keys_hash{'M'} and %keys_hash{'n'}) { die "options '-Mn' are incompatible" };

# print "filenames : @filenames $#filenames \n";
# print "keys : @keys $#keys \n";

my @input;
if ($filenames[0]) {
    open(fh, '<', $filenames[0]) or die $!;
    push @input, <fh>;
} else {
    @input = <STDIN>;
}

my @data = sort {
				comp_q($a, $b)
						||
				$b cmp $a} @input;


# my %uniq;
# if ($keys_hash{'u'}) { @input = grep { !$uniq{$_}++ } @input };

# if ($keys_hash{'n'}) { @input = sort { $a <=> $b} @input };

# if ($keys_hash{'M'}) {
# 	%mon = (jan => 1, feb => 2, mar => 3, apr => 4, may => 5, jun => 6, jul => 7, aug => 8, sep => 9, oct => 10, nov => 11, dec => 12);
# 	%months = (january => 1, february => 2, march => 3, april => 4, may => 5, june => 6, july => 7, august => 8, september => 9, october => 10, november => 11, december => 12);
# 	@input = sort { ($mon{lc($a)} or $months{lc($a)}) <=> ($mon{lc($b)} or $months{lc($b)}) } @input; 
# }

# if ($keys_hash{'r'}) { @input = reverse @input };
print @data;

