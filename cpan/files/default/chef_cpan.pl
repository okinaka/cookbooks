use Getopt::Std;
use strict;
my %opts;
getopts('tdfm:i:', \%opts);

my $installed_ok_file = "/tmp/chef/cpan/install/$opts{m}".'_install.ok';
#s/::/-/g for $installed_ok_file;

my $installed_failed_file = "/tmp/chef/cpan/install/$opts{m}".'_install.fail';
#s/::/-/g for $installed_failed_file;

sub usage {
  print "usage chef_cpan.pl [-tdf] [-i install-thing] -m module_name \nexamples: chef_cpan.pl -dv -m CGI \nexamples: chef_cpan.pl -m Module::Build -i KWILLIAMS/Module-Build-0.27_07.tar.gz\n"
}

$opts{i} ||= $opts{m};
$opts{m} or usage() and exit(2);
my $force = $opts{f} ? '-f' : '';
my $perl5_lib = '/usr/local/rle/lib/perl5';

if ($opts{'d'}){

  my @inc;
  for my $cd ('/tmp/chef/cpan/dry-run/','/usr/local/lib/perl5') {
    for my $i (@INC) { 
      push @inc, "$cd/$i" 
    }
  }
  $perl5_lib = join ':', $perl5_lib, @inc;
  my $cmd = $opts{t} 
    ? 
  "PERL5LIB=$perl5_lib ./Build install --destdir=/tmp/chef/cpan/dry-run/"
    :
  "HOME=/tmp/chef/cpan/ PERL5LIB=$perl5_lib cpan $force $opts{i} 2>&1 | perl -ne 'print; exit(/install\\s+--\\s+OK|is up to date/ ? 0 : 1) if eof()' ";
  if (system($cmd) == 0) { system("touch $installed_ok_file") } else { system("touch $installed_failed_file") } 

}else{
   my $cmd = $opts{t} 
     ? 
    "PERL5LIB=$perl5_lib ./Build install"
     :
    "HOME=/tmp/chef/cpan/ PERL5LIB=$perl5_lib cpan $force $opts{i} 2>&1 | perl -ne 'print; exit(/install\\s+--\\s+OK|is up to date/ ? 0 : 1) if eof()'";
  if (system($cmd) == 0) { system("touch $installed_ok_file") } else { system("touch $installed_failed_file") } 

}

