package DWARF::array_type;
use parent 'DWARF';
use warnings;
use strict;


sub shortname {
  my ($self) = @_;

  # print "In array_type shortname: ";
  # Dump $self;

  # FIXME: Is this always right?
  # I think so, if we limit ourselves to C... but what if we don't?
  my $max_index;

  eval {
    if ($self->{_children}[0]{upper_bound}) {
      $max_index = $self->{_children}[0]{upper_bound};
    } else {
      $max_index = '???';
    }
  };
  if ($@) {
    Dump $self;
    die $@;
  }
  #$self->{_children} = 'HIDDEN';
  #$self->{_stack} = 'HIDDEN';
  #Dump $_[0];
  return "(".$self->{type}->shortname.")[$max_index]";
}


sub as_xhtml {
  my ($self) = @_;
  my $simple_table = $self->simple_table;
  my $shortname = $self->shortname;

  <<"__END__";
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
 <head>
  <title>$shortname</title>
 </head>
 <body>
  <h1>array type $shortname</h1>
  $simple_table<hr />
 </body>
</html>
__END__
}

sub byte_size {
  my ($self) = @_;
  
  my $lower_bound = $self->{_children}[0]{lower_bound} || 0;
  my $upper_bound = $self->{_children}[0]{upper_bound};

  return $self->{type}->byte_size * ($upper_bound - $lower_bound + 1);
}

1;
