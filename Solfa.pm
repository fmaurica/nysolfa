#!/usr/bin/perl

package Solfa;

use Exporter qw(import);
our @EXPORT_OK = qw(sf2ly);

use constant FIDIR => ".";
use constant LYTPLFINAME => ".tmpl.ly";

$ENV{PATH}='C:\Program Files\Intel\iCLS Client\;%SystemRoot%\system32;%SystemRoot%;%SystemRoot%\System32\Wbem;%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\;C:\Program Files\Intel\OpenCL SDK\2.0\bin\x86;C:\Program Files\Intel\Intel(R) Management Engine Components\DAL;C:\Program Files\Intel\Intel(R) Management Engine Components\IPT;C:\Program Files\Intel\WiFi\bin\;C:\Program Files\Common Files\Intel\WirelessCommon\;C:\Program Files\QuickTime\QTSystem\;C:\strawberry\c\bin;C:\strawberry\perl\site\bin;C:\strawberry\perl\bin;C:\Program Files\LilyPond\usr\bin';

sub sf2ly {
  my $sffipath = $_[0];
  my $outprefix = substr($sffipath,0,-3); #rm .sf suffix
  my $lyfipath = "$outprefix.ly";

  my %scoremeta = ('piece','composer','arranger','poet');
  open(SFFI,$sffipath);
  my $sflines;
  while(<SFFI>){ $sflines .= $_; }
  close(SFFI);
  if($sflines =~ /Hira:(.*)\n/){ $scoremeta{'piece'} = trim($1); }
  if($sflines =~ /Namorona ny feony:(.*)\n/){ $scoremeta{'composer'} = trim($1); }
  if($sflines =~ /Nandika ny feony:(.*)\n/){ $scoremeta{'arranger'} = trim($1); }
  if($sflines =~ /Tonony:(.*)\n/){ $scoremeta{'poet'} = trim($1); }
  my @staffs = $sflines =~ /\n{3,}([\s\S]+)/g;
  print length(@staffs[0])."\n";
  print length(@staffs[1])."\n";
  print length(@staffs[2])."\n";
  print "@staffs[0]\n@staffs[1]\n@staffs[2]\n";
  
  open(LYTPLFI,FIDIR."/".LYTPLFINAME);
  my $lytpllines;
  while(<LYTPLFI>){ $lytpllines .= $_; }
  close(LYTPLFI);
  $lytpllines =~ s/\[%\s*piece\s*%\]/$scoremeta{'piece'}/g;
  $lytpllines =~ s/\[%\s*composer\s*%\]/$scoremeta{'composer'}/g;
  $lytpllines =~ s/\[%\s*arranger\s*%\]/$scoremeta{'arranger'}/g;
  $lytpllines =~ s/\[%\s*poet\s*%\]/$scoremeta{'poet'}/g;

  $lytpllines =~ s/\[%\s*voiceOneUp\s*%\]/c/g;
  $lytpllines =~ s/\[%\s*voiceOneUp\s*%\]/$score{'voiceOneUp'}/g;
  $lytpllines =~ s/\[%\s*voiceOne\s*%\]/$score{'voiceOne'}/g;
  $lytpllines =~ s/\[%\s*voiceTwo\s*%\]/$score{'voiceTwo'}/g;
  $lytpllines =~ s/\[%\s*voiceThree\s*%\]/$score{'voiceThree'}/g;
  $lytpllines =~ s/\[%\s*voiceFour\s*%\]/$score{'voiceFour'}/g;

  open(LYFI,">$lyfipath");
  print LYFI $lytpllines;
  close(LYFI);

#  system("lilypond --loglevel=ERROR --output=$outprefix $lyfipath");
#  unlink($outprefix.".sf",$outprefix.".ly");
}
sub trim {
   return $_[0] =~ s/^\s+|\s+$//rg;
}

&sf2ly("C:\\Users\\Public\\solfa\\fihirana-ffpm_441.sf");
1;
