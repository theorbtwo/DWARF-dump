#!/usr/bin/perl
use warnings;
use strict;
use 5.10.0;
use DWARF;
use FCGI;
$|=1;

my $request = FCGI::Request();

my %parses;

while ($request->Accept() >= 0) {
  my $infilename = $ENV{REQUEST_URI};
  $infilename =~ s!^/dwarfdump/!!;
  ($infilename, my $args) = split /\?/, $infilename;
  $args ||= '';
  $args = { map {split /=/, $_, 2} split /\;/, $args };
  $args->{tag_offset} ||= 0;

  if (!$parses{$infilename}) {
    my $dump = `dwarfdump -d -i "$infilename"`;
    
    $parses{$infilename} = DWARF::parse_dwarfdump($dump);
  }
  
  my $tag = $parses{$infilename}{$args->{tag_offset}};
  
  print "Content-type: application/xhtml+xml\n\n";
  print $tag->as_xhtml;
}
