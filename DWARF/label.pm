package DWARF::label;
use parent 'DWARF';
use warnings;
use strict;


sub shortname {
  my ($self) = @_;
  $self->{name};
}


sub as_xhtml {
  my ($self) = @_;
  $self->normal_as_xhtml('label');
}

1;
