package Queue::Fork;

require 5.005_62;
use strict;
use warnings;

require Exporter;

use Carp;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Queue::Fork ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw( exit wait fork ) ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw();
our $VERSION = '0.01';


my $queue_size=4;
my $queue_now=0;
my %process;
my $debug=1;

sub size {
  my $size=shift;
  my $old_size=$queue_size;
  if(defined $size) {
    croak "invalid value for Queue::Fork size ($size), min value is 1"
      unless $size >= 1;
    $queue_size=$size;
    carp "Fork queue size set to $queue_size, it was $old_size\n" if $debug;
  }
  return $old_size;
}

sub debug {
  my $d=shift;
  my $old_debug=$debug;
  if(defined $d) {
    if ($d) {
      $debug=1;
      carp "Debug mode is now on for Queue::Fork module\n";
    }
    else {
      $debug=0;
      carp "Debug mode is now off for Queue::Fork module\n" if $old_debug;
    }
  }
  return $old_debug;
}

sub wait {
  carp "Waiting for child processes to exit\n" if $debug;
  my $w=CORE::wait;
  if ($w != -1) {
    if(exists $process{$w}) {
      delete $process{$w};
      $queue_now--;
      carp "Process $w has exited, $queue_now processes running now\n" if $debug;
    }
    else {
      carp "Unknow process $w has exited, ignoring it\n" if $debug;
    }
  }
  else {
    carp "No child processes left, continuing\n" if $debug;
  }
  return $w;
}

sub exit {
  my $e=shift;
  carp "Process $$ exiting with value $e\n" if $debug;
  return CORE::exit($e);
}

sub fork {
  while($queue_now>=$queue_size) {
    carp "Waiting that some process finishes before continuing\n" if $debug;
    unless (wait != -1) {
      carp "carping: queue seems to be corrupted\n";
      last;
    }
  }
  my $f=CORE::fork;
  if (defined($f)) {
    if($f == 0) {
      carp "Process $$ now running\n" if $debug;
      # reset queue internal vars in child proccess;
      $queue_size=1;
      $queue_now=0;
      %process=();
    }
    else {
      $process{$f}=1;
      $queue_now++;
      carp "Child forked (pid=$f), $queue_now processes running now\n" if $debug;
    }
  }
  else {
    carp "Fork failed: $!\n" if $debug;
  }
  return $f;
}


1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Queue::Fork - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Queue::Fork;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Queue::Fork, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.


=head1 AUTHOR

A. U. Thor, a.u.thor@a.galaxy.far.far.away

=head1 SEE ALSO

perl(1).

=cut
