package Date::Leapsecond;

use 5.006;
use strict;
use warnings;
use Time::Local;
use vars qw(@UTC_EPOCH @LEAP_SECONDS);
require Exporter;
our @ISA = qw(Exporter);
our %EXPORT_TAGS = ( 'all' => [ qw() ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw();
our $VERSION = '0.02';

sub make_utx {
    my ($beg, $end, $tab, $op) = @_;
    my $step = int(($end - $beg) / 2);
    my $tmp;
    if ($step <= 0) {
        $tmp = "${tab}return \$val $op $LEAP_SECONDS[$beg];\n";  
        return $tmp;
    }
    $tmp  = "${tab}if (\$val < " . $UTC_EPOCH[$beg + $step] . ") {\n";
    $tmp .= make_utx ($beg, $beg + $step, $tab . "    ", $op);
    $tmp .= "${tab}}\n";
    $tmp .= "${tab}else {\n";
    $tmp .= make_utx ($beg + $step, $end, $tab . "    ", $op);
    $tmp .= "${tab}}\n";
    return $tmp;
}

sub init {
    my $value = 32 - 23;
    while (@_) {
        my ($year,$mon,$mday) = (shift,shift,shift);
        # print "$year,$mon,$mday\n";
        my $utc_epoch = timegm(0,0,0,$mday,$mon =~ /Jan/i ? 0 : 6,$year - 1900);
        $value++;
        push @LEAP_SECONDS, $value;
        push @UTC_EPOCH, $utc_epoch;
        # print "$year,$mon,$mday = $utc_epoch +$value\n";
    }

    my $tmp;

    # write binary tree decision table

    $tmp  = "sub ut1 {\n";
    $tmp .= "    my \$val = shift;\n";
    $tmp .= "    if (\$val >= " . $UTC_EPOCH[-1] . ") {\n";
    $tmp .= "        return \$val + $LEAP_SECONDS[-1];\n";   
    $tmp .= "    }\n";
    $tmp .= make_utx (0, $#UTC_EPOCH, "    ", "+");
    $tmp .= "}\n";
    # print $tmp;
    eval $tmp;

    $tmp  = "sub utc {\n";
    $tmp .= "    my \$val = shift;\n";
    $tmp .= "    if (\$val >= " . $UTC_EPOCH[-1] . ") {\n";
    $tmp .= "        return \$val - $LEAP_SECONDS[-1];\n";   
    $tmp .= "    }\n";
    $tmp .= make_utx (0, $#UTC_EPOCH, "    ", "-");
    $tmp .= "}\n";
    # print $tmp;
    eval $tmp;
}

BEGIN {
    # this table: ftp://62.161.69.5/pub/tai/publication/leaptab.txt
    # known accurate until (at least): 2002-12-31
    init ( qw(
1972  Jan. 1 
1972  Jul. 1 
1973  Jan. 1 
1974  Jan. 1 
1975  Jan. 1 
1976  Jan. 1 
1977  Jan. 1 
1978  Jan. 1 
1979  Jan. 1 
1980  Jan. 1 
1981  Jul. 1 
1982  Jul. 1 
1983  Jul. 1 
1985  Jul. 1 
1988  Jan. 1 
1990  Jan. 1 
1991  Jan. 1 
1992  Jul. 1 
1993  Jul. 1 
1994  Jul. 1 
1996  Jan. 1 
1997  Jul. 1 
1999  Jan. 1 
    ) );
}

1;
__END__

=head1 NAME

Date::Leapsecond - DEPRECATED: use "DateTime" distribution instead

=head1 SYNOPSIS

  use Date::Leapsecond;
  use Time::Local;  

  $epoch_2000 = timegm(0,0,0,1,0,2000 - 1900);
  $epoch_1990 = timegm(0,0,0,1,0,1990 - 1900);
  print "Seconds between years 1990 and 2000 are ";
  print Date::Leapsecond::ut1($epoch_2000) - 
        Date::Leapsecond::ut1($epoch_1990); 
  print " instead of ";
  print $epoch_2000 - 
        $epoch_1990; 

=head1 DESCRIPTION

Use UT1 timescale to calculate precise
time differences.

This library uses 1 second precision and is
known accurate for dates from 
1970-01-01 until 
2002-12-31.

=head1 ut1

Returns the value of UT1 epoch, for a given UTC epoch.

UTC epoch is got from Time::Local

=head1 utc

Returns the value of UTC epoch, for a given UT1 epoch.

=head1 AUTHOR

Flávio Soibelmann Glock, E<lt>fglock@pucrs.brE<gt>

=head1 SEE ALSO

E<lt>http://hpiers.obspm.fr/eop-pc/earthor/utc/leapsecond.htmlE<gt>

=cut
