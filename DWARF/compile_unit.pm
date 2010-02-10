package DWARF::compile_unit;
use parent 'DWARF';
use warnings;
use strict;


sub shortname {
  $_[0]->{name};
}


sub as_xhtml {
  my ($self) = @_;
  my $simple_table = $self->simple_table;

  my $types_table = "<table>\n";
  my $n = 0;
  for my $child (@{$self->{_children}}) {


    if ($n % 5 == 0) {
      if ($n != 0) {
        $types_table .= " </tr>\n";
      }
      $types_table .= " <tr>\n";
    }

    $types_table .= "  <td>\n";
    my $shortname = $child->shortname;
    if (not defined $shortname) {
      warn "Undefined name for child $child";
    }
    my $uri = $child->uri;
    $types_table .= "   <a href='$uri'>$shortname</a>\n";
    $types_table .= "  </td>\n";

    $n++;
  }
  if (not($types_table =~ m!</tr>\s*$!)) {
    $types_table .= " </tr>\n";
  }
  $types_table .= "</table>";

  <<"__END__";
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
 <head>
  <title>$self->{name}</title>
 </head>
 <body>
  <h1>compile unit $self->{name}</h1>
  $simple_table<hr />
  $types_table
 </body>
</html>
__END__
}

1;

