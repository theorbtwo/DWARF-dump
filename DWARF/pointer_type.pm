package DWARF::pointer_type;
use parent 'DWARF';
use warnings;
use strict;


sub shortname {
  my ($self) = @_;
  if ($self->{name}) {
    return $self->{name};
  } elsif ($self->{type}) {
    return $self->{type}->shortname."*";
  } else {
    # This doesn't seem to be how the spec intends for void * to work,
    # but is, nonetheless, how gcc generates it.
    "void*";
  }
}


sub as_xhtml {
  my ($self) = @_;
  my $simple_table = $self->simple_table;
  my $shortname = $self->shortname;
  my $base_link = $self->{type} ? "<a href='".$self->{type}->uri."'>".$self->{type}->shortname."</a>" : '???';

  <<"__END__";
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
 <head>
  <title>$shortname</title>
 </head>
 <body>
  <h1>pointer type $shortname</h1>
  $simple_table<hr />
  <div>$base_link</div>
 </body>
</html>
__END__
  
}

sub byte_size {
  $_[0]->{byte_size};
}

1;

