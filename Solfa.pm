#!/usr/bin/perl

package Solfa;

use Exporter qw(import);
our @EXPORT_OK = qw(sf2ly);

use Data::Dumper qw(Dumper);

use constant FIDIR => ".";
use constant LYTPLFINAME => ".tmpl.ly";

use constant STEP => 2;

$ENV{PATH}='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games';

sub sf2ly {
  my $sffipath = $_[0];
  my $outprefix = substr($sffipath,0,-3); #rm .sf suffix
  my $lyfipath = "$outprefix.ly";

  my %scoremeta = ('piece','composer','arranger','poet');
  open(SFFI,$sffipath);
  my $sflines;
  while(<SFFI>){ $sflines .= $_; }
  close(SFFI);
  
  # getting meta info
  if($sflines =~ /Hira:(.*)\n/){ $scoremeta{'piece'} = trim($1); }
  if($sflines =~ /Namorona ny feony:(.*)\n/){ $scoremeta{'composer'} = trim($1); }
  if($sflines =~ /Nandika ny feony:(.*)\n/){ $scoremeta{'arranger'} = trim($1); }
  if($sflines =~ /Tonony:(.*)\n/){ $scoremeta{'poet'} = trim($1); }

  #
  my %noteTranslator = (
    "d" => "c",
    "r" => "d",
    "m" => "e",
    "f" => "f",
    "s" => "g",
    "l" => "a",
    "t" => "b",
    " " => "r",
  );
  
  # getting staffs
  my @score = ();
  my @staffs = split /#\r?\n/,$sflines;
  foreach my $i (1 .. $#staffs) {
	my @voices = split /\r?\n/,$staffs[$i];	

	for (my $voiceIdx = 1; $voiceIdx <= 5 ; $voiceIdx++){
      # for metas (key and time notably)
	  my $isFirstMeta = 1;
	
      # for the very voices
      my $index = 1;
      my $noteTmpMem = "n";
	  my $isNullStartingNoteTmp = 0;
	  my $noteDuration = 0;
	  while ($index <= length(@voices[$voiceIdx])) {
        # for metas 
        my $keyAndTime = substr (@voices[0], $index-1, 15); # 13 : Do Dia XX XX/XX
	    if ($keyAndTime =~ /Do dia (..?) (..?\/..?)/) {
		  my $time = $2;
		  my $key = $1;
		  $key = lc $key;
		  my $keyFirstChar = substr ($key, 0, 1);
		  my $keySecondChar = substr ($key, 1, 1);
		  if ($keySecondChar =~ /b/) { $keySecondChar = "es";}
		  elsif ($keySecondChar =~ /#/) { $keySecondChar = "is";}
		  $key = $keyFirstChar.$keySecondChar;
		  if ($isFirstMeta == 0) { print "}";}
		  # print "\\time $time \n\\key $key \\major\n\\transpose c $key\n{\n";
		  @score[$voiceIdx] .= "\\time $time \n\\key $key \\major\n\\transpose c $key,\n{\n"; 
		  $isFirstMeta = 0;
		}
	    
		# for the very voices
	    my $separatorTmp = substr (@voices[$voiceIdx], $index-1, 1);
	    my $noteTmp = substr (@voices[$voiceIdx], $index, 2);
		if ($separatorTmp !~ / / and $noteTmp =~ /[  ] /){
		  $isNullStartingNoteTmp = 1;
		}
		elsif ($separatorTmp !~ / / and $noteTmp !~ /[  ] /){
		  $isNullStartingNoteTmp = 0;
		}
	    if ($separatorTmp !~ / / and $noteTmp !~ /- /){
	      if ($noteTmpMem !~ /n/){ # for preventing writing at the first loop
		    my $noteValue = substr ($noteTmpMem, 0, 1);
			$noteValue = $noteTranslator{$noteValue};
		    my $noteHeight = substr ($noteTmpMem, 1, 1);
			my $nbHeight;
			if ($voiceIdx == 1 or $voiceIdx == 2 or $voiceIdx == 3) { $nbHeight = 2; }
			elsif ($voiceIdx == 4 or $voiceIdx == 5) { $nbHeight = 1; }
			if ($noteHeight =~ /,/) { $nbHeight--; }
			elsif ($noteHeight =~ /'/) { $nbHeight++; }
			my $heightValue;
			for (my $nbHeightIdx = 0 ; $nbHeightIdx < $nbHeight ; $nbHeightIdx++){
			  $heightValue .= "'";
			}
			if ($noteValue =~ /r/) {
			  $heightValue = "";
			}
			$noteDuration = 16/$noteDuration;
			if ($noteDuration == 16/6) {
			  $noteDuration = "4.";
			}
	        # print "$noteValue$heightValue$noteDuration   ";
			@score[$voiceIdx] .= "$noteValue$heightValue$noteDuration   ";
		  }
		  if ($separatorTmp =~ /!/ ) {
 		    # print "\n";
			@score[$voiceIdx] .= "\n";
		  }
		  elsif ($separatorTmp =~ /}/ ) {
		    # print "\\bar \"||\"\n";
			@score[$voiceIdx] .= "\\bar \"||\"\n";
		  }
		  $noteDuration = 1;	  
	    }
	    else {
	      $noteDuration++;
	    }
	    if ($noteTmp !~ /[- ] /){
	      $noteTmpMem = $noteTmp;
        }
		elsif ($noteTmp =~ /  / and $isNullStartingNoteTmp == 1){
		  $noteTmpMem = $noteTmp;
		}
	    $index += STEP + 2;
		}
	}
  }
  for (my $voiceIdx = 1; $voiceIdx <= 5 ; $voiceIdx++){
    # print "\\bar \"|.\"\n}"; # for closing transpose
	@score[$voiceIdx] .= "\\bar \"|.\"\n}";
  }  
#  print Dumper @score;
  
  open(LYTPLFI,FIDIR."/".LYTPLFINAME);
  my $lytpllines;
  while(<LYTPLFI>){ $lytpllines .= $_; }
  close(LYTPLFI);
  $lytpllines =~ s/\[%\s*piece\s*%\]/$scoremeta{'piece'}/g;
  $lytpllines =~ s/\[%\s*composer\s*%\]/$scoremeta{'composer'}/g;
  $lytpllines =~ s/\[%\s*arranger\s*%\]/$scoremeta{'arranger'}/g;
  $lytpllines =~ s/\[%\s*poet\s*%\]/$scoremeta{'poet'}/g;

  $lytpllines =~ s/\[%\s*voiceOneUp\s*%\]/@score[1]/g;
  $lytpllines =~ s/\[%\s*voiceOne\s*%\]/@score[2]/g;
  $lytpllines =~ s/\[%\s*voiceTwo\s*%\]/@score[3]/g;
  $lytpllines =~ s/\[%\s*voiceThree\s*%\]/@score[4]/g;
  $lytpllines =~ s/\[%\s*voiceFour\s*%\]/@score[5]/g;

  open(LYFI,">$lyfipath");
  print LYFI $lytpllines;
  close(LYFI);

  system("lilypond --loglevel=ERROR --output=$outprefix $lyfipath");
  unlink($outprefix.".sf",$outprefix.".ly");
}
sub trim {
   return $_[0] =~ s/^\s+|\s+$//rg;
}

#print "Content-type: text/html\n\n";
#&sf2ly("/var/tmp/nysolfa/fihirana-ffpm_441.sf");
1;
