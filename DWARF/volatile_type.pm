package DWARF::volatile_type;
use parent 'DWARF';
use warnings;
use strict;


sub shortname {
  "volatile ".$_[0]->{type}->shortname;
}

sub as_xhtml {
  shift->normal_as_xhtml('volatile');
}

1;
