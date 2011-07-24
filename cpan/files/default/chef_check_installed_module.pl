use Getopt::Std;
use Data::Dumper;
use CPAN::Version;
my %opts;
getopts('tedm:v:', \%opts);
use strict;
warn Dumper(\%opts);

# $opts{v} ||= 0;

# PERL5LIB=#{perl5lib} perl -MCPAN::Version -e 'require #{@module.name}; CPAN::Version->vcmp($#{@module.name}::VERSION, #{@module.version}) == 0 or die

my $perl5_lib;
my $cmd;

if ($opts{'d'}){
  my @inc;
  for my $cd ('/tmp/chef/cpan/dry-run/','/usr/local/lib/perl5') {
    for my $i (@INC) { 
      push @inc, "$cd/$i" 
    }
  }
   $perl5_lib = join ':', '/usr/local/rle/lib/perl5/', @inc;
}else{
  $perl5_lib = '/usr/local/rle/lib/perl5/';
}

$perl5_lib='./lib/:'.$perl5_lib if $opts{t};

if ($opts{e}){
  $cmd = "HOME=/tmp/chef/cpan/ PERL5LIB='$perl5_lib' perl -MCPAN::Version -e 'require ".$opts{m}.'; CPAN::Version->vcmp($'.$opts{m}."::VERSION, $opts{v}) == 0 or die'"
}else{
  $cmd = "HOME=/tmp/chef/cpan/ PERL5LIB='$perl5_lib' perl -e 'use $opts{m} $opts{v} ()'";
}

system($cmd) == 0 or die 'unsuccessfull retrun from '.$cmd;

