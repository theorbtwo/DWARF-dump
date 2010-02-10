package DWARF::variable;
use parent 'DWARF';
use warnings;
use strict;


sub shortname {
  my ($self) = @_;
  "var:".$self->{name};
}


sub as_xhtml {
  shift->normal_as_xhtml('variable');
}

1;

