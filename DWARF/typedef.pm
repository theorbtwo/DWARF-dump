package DWARF::typedef;
use parent 'DWARF';
use warnings;
use strict;


sub shortname {
  $_[0]->{name};
}


sub as_xhtml {
  shift->normal_as_xhtml('typedef');
}

sub byte_size {
  shift->{type}->byte_size;
}

1;
