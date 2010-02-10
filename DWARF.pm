package DWARF;
use warnings;
use strict;
use 5.10.0;
use Tie::File;
use Fcntl 'O_RDONLY';

# Pass in the result of dwarfdump -d -i.
sub parse_dwarfdump {
  my ($dwarfdump) = @_;
  
  my %tags;
  my %fixups;

  my @stack;

  my $current_section;
  
  my $n;

  for my $line (split /\n/, $dwarfdump) {
    $n++;

    if (($n % 100) == 0) {
      # print ".";
    }

    given ($line) {
      when (/^$/) {
        # Ignorable whitespace.
      }

      when (['.debug_info']) {
        $current_section = $line;
      }
      
      # The normal case: We have a DWARF tag.
      when (/^<(\d+)><(\d+)(\+\d+)?><DW_TAG_(.*?)>(.*)$/) {
        my ($tag_depth, $tag_offset, $unk3, $tag, $attlist_raw) = ($1, $2, $3, $4, $5);
        # print "Unknown 1: $unk1, unknown 2: $unk2\n";
        #print "Tag: $tag\n";
        #print " $tag_depth $tag_offset\n"; # $unk3\n";

        $tags{$tag_offset} = {};
        my $tag_info = $tags{$tag_offset};

        $tag_info->{_offset} = $tag_offset;
        $tag_info->{_depth}  = $tag_depth;

        $stack[$tag_depth] = $tag_info;

        #print "tag info, current tag, early\n";
        #Dump $tag_info;
        #print "parent tag, early\n";
        #Dump $stack[$tag_depth-1];

        if ($tag_depth > 0) {
          push @{$stack[$tag_depth-1]{_children}}, $tag_info;
        }
        #print "parent tag, after inserting ourself into the children\n";
        #Dump $stack[$tag_depth-1];

        # The topmost part of the stack will always be ourselves, including it is
        # just confusing.
        # $tag_info->{_stack} = [splice @stack, 0, @stack-1];
        # $tag_info->{_stack} = [@stack];

        
        eval "use DWARF::$tag";
        if ($@) {
          die "Couldn't load DWARF::$tag: $@";
        }

        bless $tag_info, "DWARF::$tag";
        
        my $attribs;
        $attlist_raw =~ s/^ //;
        while ($attlist_raw) {
          $attlist_raw =~ s/^DW_AT_(.*?)<(.*?)>( |$)//;
          my ($name, $val) = ($1, $2);
          if ($val =~ m/^<(\d+)>$/) {
            if (exists $tags{$1}) {
              $val = $tags{$1};
            } else {
              $val = "forward reference to tag $1";
              push @{$fixups{$1}}, sub {
                $tag_info->{$name} = shift;
              };
            }
          }
          
          $tag_info->{$name} = $val;
        }
        # Dump $tag_info;

        for my $fixup (@{$fixups{$tag_offset}}) {
          $fixup->($tag_info);
        }
        delete $fixups{$tag_offset};
      }

      default {
        die "Don't know how to parse line in dwarfdump ouput: '$line'";
      }
    }
  }
  
  return \%tags;
}

sub simple_table {
  my ($self, $skip_attrs) = @_;
  # $skip_attrs ||= ['+'];

  #if ($skip_attrs->[0] eq '+') {
  #  splice(@$skip_attrs, 0, 1, ('_stack', '_children', '_depth', '_offset'));
  #}
  
  my $deref;
  $deref = sub {
    $_ = shift;
    
    if (not defined $_) {
      return 'undef';
    } elsif (!ref $_) {
      s/&/&amp;/g;
      s/</&lt;/g;
      return $_;
    } elsif (ref $_ eq 'ARRAY') {
      return '[' . join(', ', map {$deref->($_)} @$_) . ']';
    } elsif ($_->isa('DWARF')) {
      return "<a href='".$_->uri."'>".$_->shortname."</a>";
    } else {
      die "simple_table deref for $_";
    }
  };

  my $ret = "<table>\n";
  for my $key (sort keys %$self) {
    next if $key ~~ $skip_attrs;
    my $val = $deref->($self->{$key});
    $ret .= " <tr><td>$key</td><td>$val</td></tr>\n";
  }
  $ret .= "</table>\n";

  return $ret;
}

sub as_xhtml {
  $_[0]->normal_as_xhtml;
}

sub normal_as_xhtml {
  my ($self, $descriptorbit) = @_;

  my $name = $self->shortname;
  my $simple_table = simple_table($self);

  my $source = '';
  if ($self->{decl_file}) {
    my $filename = $self->{decl_file};
    $filename =~ s/^\d+ //;
    if (-e $filename) {
      tie my @in_array, 'Tie::File', $filename, mode => O_RDONLY or die "Can't open (or can't tie) source file $filename: $!";
      for my $line_no ($self->{decl_line}-5 .. $self->{decl_line}+5) {
        my $line = $in_array[$line_no];
        $line =~ s/&/&amp;/g;
        $line =~ s/</&lt;</g;
        $line =~ s/\t/        /g;
        $line =~ s/  / &nbsp;/g;
        $source .= sprintf "%d: %s<br />\n", $line_no, $line;
      }
    }
  }

  <<"__END__";
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
 <head>
  <title>$name</title>
 </head>
 <body>
  <h1>$descriptorbit $name</h1>
  $simple_table<hr />
  $source<hr />
 </body>
</html>
__END__
}

sub uri {
  "?tag_offset=".$_[0]->{_offset};
}

1;
