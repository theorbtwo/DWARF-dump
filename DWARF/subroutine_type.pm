package DWARF::subroutine_type;
use parent 'DWARF';
use warnings;
use strict;


sub shortname {
  my ($self) = @_;
  if ($self->{name}) {
    return $self->{name}
  }
  my $ret = $self->{type} ? $self->{type}->shortname() : 'void';
  my $arglist = join(', ', map {$_->shortname} @{$self->{_children}});
  "$ret foo($arglist)";
}


sub as_xhtml {
  my ($self) = @_;
  $self->normal_as_xhtml('subroutine type');
}

1;
