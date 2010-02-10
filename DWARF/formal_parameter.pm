package DWARF::formal_parameter;
use parent 'DWARF';
use warnings;
use strict;


sub shortname {
  my ($self) = @_;
  if ($self->{name}) {
    return $self->{name};
  } elsif ($self->{type}) {
    return $self->{type}->shortname." formal param";
  }
}


sub as_xhtml {
  shift->normal_as_xhtml('formal parameter');
}

1;
