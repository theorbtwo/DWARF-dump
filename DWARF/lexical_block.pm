package DWARF::lexical_block;
use parent 'DWARF';
use warnings;
use strict;


sub shortname {
  my ($self) = @_;
  if ($self->{name}) {
    return $self->{name};
  }
  "anon lexical block";
}


sub as_xhtml {
  shift->normal_as_xhtml('lexical block');
}

1;
