package DWARF::structure_type;
use parent 'DWARF';
use warnings;
use strict;


sub shortname {
  my ($self) = @_;
  if ($self->{name}) {
    return "struct " . $self->{name};
  } elsif ($self->{_children}[0]{name}) {
    return "struct {$self->{_children}[0]{name}, ...}";
  } else {
    return "anon struct";
  }
}


sub as_xhtml {
  my ($self) = @_;
  my $simple_table = $self->simple_table;
  my $shortname = $self->shortname;

  my $svg = '';

  my $members_table = "<table>\n";
  for my $member (@{$self->{_children}}) {
    my $member_type = $member->{type}->shortname;
    $members_table .= "<tr>\n";
    $members_table .= " <td><a href='".$member->{type}->uri."'>$member_type</a></td>\n";
    $members_table .= " <td>$member->{name}</td>\n";

    my $pos;
    my $pos_text;
    if ($member->{data_member_location} =~ m/^DW_OP_plus_uconst (\d+)$/) {
      $pos = $1;
    } else {
      die "Dynamicly placed struct member?";
    }

    if ($member->{bit_size}) {
      # Happy fun bitfield time!
      my $of_bit_length = $member->{byte_size}*8;
      my $start_bit = $member->{bit_offset};
      my $bit_width = $member->{bit_size};
      $pos_text = "$pos, starting at bit $start_bit of $of_bit_length, for $bit_width bits";
    } else {
      $pos_text = $pos;
    }
    $members_table .= " <td>@ <a href='".$member->uri."'>$pos_text</a></td>\n";
    $members_table .= "</tr>\n";

    my ($bit_offset, $bit_size) = (0, 0);
    if (exists $member->{bit_offset}) {
      $bit_offset = $pos * 8 + $member->{bit_offset};
      $bit_size = $member->{bit_size};
    } else {
      $bit_offset = $pos * 8;
      $bit_size   = $member->byte_size * 8;
    }

    # X positioning: Each 5 pixels is 1 bit.     Left on the screen = lower x = later in memory.
    # Y positioning: Each 40 pixels is 32 bits.  Higher on the screen = lower y = earlier in memory.

    my $x = 5  * ($bit_offset % 32);
    my $y = 40 * int($bit_offset / 32);

    my ($width, $height);
    if ($bit_size >= 32) {
      $width  = 32*5;
      $height = $bit_size/32 * 40;
    } else {
      $width  = $bit_size * 5;
      $height = 40;
    }

    # But the x axis is reversed.
    my $old_right = $x + $width;
    $x = 32*5-$old_right;
    

    my $text = $member->shortname;

    my $inner_x = $x + 2;
    my $inner_y = $y + 2;
    my $inner_width = $width - 4;
    my $inner_height = $height - 4;

    
    # FIXME: The idea here was to make the things that are taller then they are wide be labeled top-to-bottom.  That turns out to be *hard*.
    # Morever, the benifit is minimal -- it won't be *much* more readable.
    #my $writing_mode='';
    #if ($inner_width < $inner_height) {
    #  $writing_mode = 'tb';
    #} else {
    #  $writing_mode = 'lr';
    #}

#<svg style='stroke: black; stroke-width: 2px;' x='$x px' y='$y px' width='$width px' height='$height px'>
# <text fill='black' stroke='none' x='0' y='0' font-size='$height px'>$text</text>
#</svg>

    $svg .= <<END;
<rect x='$x px' y='$y px' width='$width px' height='$height px' style='stroke: black; stroke-width: 2px; fill: none' /><!-- +$bit_offset len $bit_size -->
<svg x='$inner_x px' y='$inner_y px' width='$inner_width px' height='$inner_height px' viewBox="0 0 100 100" preserveAspectRatio="xMinYMax meet">
 <text x='0' y='80' font-size="95 px" >$text</text>
</svg>
END
    
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
  <h1>struct $shortname</h1>
  $simple_table<hr />
  $members_table<hr />
  <div>
   <svg xmlns="http://www.w3.org/2000/svg" version="1.1">
    $svg
   </svg>
  </div>
 </body>
</html>
__END__
  
  
}

sub byte_size {
  shift->{byte_size};
}

1;
