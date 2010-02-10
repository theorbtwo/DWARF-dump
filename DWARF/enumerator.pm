package DWARF::enumerator;
use parent 'DWARF';
use warnings;
use strict;


sub shortname {
  my ($self) = @_;
  $self->{name};
}


sub as_xhtml {
  my ($self) = @_;
  my $shortname = $self->shortname;
  my $simple_table =$self->simple_table;

  <<"__END__";
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
 <head>
  <title>$shortname</title>
 </head>
 <body>
  <h1>enumerator $shortname</h1>
  $simple_table<hr />
 </body>
</html>
__END__
}

1;
