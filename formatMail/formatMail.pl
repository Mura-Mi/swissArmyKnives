#!/usr/bin/perl
use encoding 'utf8'; 

# please set allowed line length.
$defaultLineMax = 35;

# input filehandle
open TEXT, "<", $ARGV[0];

# output filehandle
$outputFileName = "fmted_" . $ARGV[0];
open FMTED, ">", $outputFileName;
binmode FMTED, ":utf8";

# apply the process for each input line.
while(<TEXT>) {
  utf8::encode($_);
  s/\n//g;
  $prefix = &getPrefix($_);

  s/(。)([^( \(|（)])/\1\n\2/g;
  s/^$prefix//;
  s/(\(.*\))$/\n\1/;

  if($_ eq ""){
    print FMTED "\n";
    next;
  }

  @firstLines = split /\n/, $_;
  @secondLines = qw//;

  $lineMax = $defaultLineMax - 2 * width($prefix);

  foreach $line (@firstLines) {
    while(1) {
      if($lineMax >= length($line)) {
        push @secondLines, $line;
        last;
      } elsif(substr($line, $lineMax) =~ "^[、|。]") {
        # avoid cases that next line start with period.
        push @secondLines, substr($line, 0,  $lineMax - 1);
        $line = substr($line, $lineMax - 1);
      } else {
        push @secondLines, substr($line, 0,  $lineMax);
        $line = substr($line, $lineMax);
      }
    }
  }

  @thirdLines = qw//;

  $lineMax += width($prefix);
  $previous = "";
  foreach $line (@secondLines) {
    if (length($previous . $line) < $lineMax) {
      $previous = $previous . $line;
    } else {
      push @thirdLines, $prefix . $previous;
      $prefix =~ s/(・|→)/　/g;
      $previous = $line;
    }
  }
  if($previous ne pop @secondLines) {
    $prefix =~ s/(・|→)/　/g;
  }
  push @thirdLines, $prefix . $previous;

  foreach $printLine (@thirdLines) {
    print FMTED $printLine;
    print FMTED "\n";
  }
}

close TEXT;
close FMTED;

# get the prefix for indent.
sub getPrefix {
  $i = 0;
  while(1) {
    if ($i == length($_[0])) {
      last;
    }

    $str = substr($_[0], $i, 1);
    if($str =~ m/ |　|\t|・|→/) {
      $i++;
    } else {
      last;
    }
  }
  substr($_[0], 0, $i); 
}

# return width of first argument, 
#   regarding multi-byte character and tab.
sub width {
  $i = 0;
  $width = 0;
  $line = $_[0];

  while(1){
    if ($i == length($_[0])) {
      last;
    }

    $char = substr($line, $i, 1); 

    if($char eq " ") {
      $width++;
    } elsif($char eq "\t") {
      $width += 4;
    } elsif(m/\w/) {
      $width++;
    } else {
      $width += 2;
    }
    $i++;
  }
  $width;
}
