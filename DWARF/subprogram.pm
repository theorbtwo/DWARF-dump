package DWARF::subprogram;
use parent 'DWARF';
use warnings;
use strict;


sub shortname {
  my ($self) = @_;
  $self->{name} || "subprogram";
}


sub as_xhtml {
  my ($self) = @_;
  $self->normal_as_xhtml('subprogram');
}

1;
