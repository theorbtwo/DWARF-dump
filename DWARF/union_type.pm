package DWARF::union_type;
use parent 'DWARF';
use warnings;
use strict;


sub shortname {
  my ($self) = @_;
  $self->{name}
    ? ("union ".$self->{name})
    : "anon union";
}


sub as_xhtml {
  my ($self) = @_;
  my $simple_table =$self->simple_table;
  my $shortname = $self->shortname;

  my $members_table = "<table>\n";
  for my $member (@{$self->{_children}}) {
    my $member_type = $member->{type}->shortname;
    $members_table .= "<tr border='1'>\n";
    $members_table .= " <td><a href='".$member->{type}->uri."'>$member_type</a></td>\n";
    $members_table .= " <td>$member->{name}</td>\n";
    $members_table .= " <td>@ <a href='".$member->uri."'>0</a></td>\n";
    $members_table .= "</tr>\n";
  }
  $members_table .= "</table>\n";

  <<"__END__";
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
 <head>
  <title>$shortname</title>
 </head>
 <body>
  <h1>union $shortname</h1>
  $simple_table<hr />
  $members_table
 </body>
</html>
__END__
}

sub byte_size {
  $_[0]->{byte_size};
}

1;
