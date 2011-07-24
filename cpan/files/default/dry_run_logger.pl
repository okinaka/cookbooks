#!/usr/bin/perl -n

BEGIN {
 $dest_dir = shift @ARGV;
 $flags = shift @ARGV if (scalar @ARGV) > 1;
}

my $line = $_;
chomp $line;


if ($line=~s/^Installing\s+(.*\.pm)$/$1/){
  $line=~s/^$dest_dir/\//;
  if (-e $line && -e "$dest_dir/$line"){
    my $files_differ = (system ("(diff -qau $line $dest_dir/$line) >/dev/null || exit 2") == 0) ? 0 : 1;
    unless ($flags=~/v/){
      if ($files_differ){
        print "WOULD SKIP $line\n"
      }else{
        print "WOULD INSTALL $line\n"
      };
    }elsif($files_differ){
        print "WOULD UPDATE $line\n";
        print `diff -au $line $dest_dir/$line`;
    }
  }else{
    print "WOULD INSTALL-NEW $line\n"
  }
}
