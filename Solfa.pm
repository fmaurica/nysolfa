#!/usr/bin/perl

package Solfa;

use Exporter qw(import);
our @EXPORT_OK = qw(sf2ly);

use Data::Dumper qw(Dumper);

use constant FIDIR => ".";
use constant LYTPLFINAME => "tmpl.ly";

use constant STEP => 2;

$ENV{PATH}='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games';

sub sf2ly {
	my $sffipath = $_[0];
	my $outprefix = substr($sffipath,0,-3); #rm .sf suffix
		my $lyfipath = "$outprefix.ly";

	my $generatemidi = $_[1];
	my $midiinstrument = $_[2];
	my $generatepdf = $_[3];

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
			"e" => "cis",
			"r" => "d",
			"u" => "dis",
			"m" => "e",
			"f" => "f",
			"g" => "fis",
			"s" => "g",
			"v" => "gis",
			"l" => "a",
			"n" => "ais",
			"t" => "b",
			" " => "r",
			);

# getting staffs
	my @score = ();
	my @staffs = split /#\r?\n/,$sflines;

# for metas (key and time notably)
	my @isFirstMeta = (1,1,1,1,1,1,1,1,1,1,1,1,1,1);
	my @isEmptyVoice = (0,0,0,0,0,0,0,0,0,0,0,0,0,0);

	foreach my $i (1 .. $#staffs) {
		my @voices = split /\r?\n/,$staffs[$i];	

		for (my $voiceIdx = 9; $voiceIdx <= 13 ; $voiceIdx++){

			if ($i == 1 and substr (@voices[$voiceIdx], 0, 1) =~ /].*/){
				@isEmptyVoice[$voiceIdx] = 1;
			}	
			next if (@isEmptyVoice[$voiceIdx] == 1);

# for the very voices
			my $index = 1;
			my $noteTmpMem = "n";
			my $isNullStartingNoteTmp = 0;
			my $noteDuration = 0;
			while ($index <= length(@voices[$voiceIdx])) {

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
						elsif ($noteDuration == 16/12) {
							$noteDuration = "2.";
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

# for metas 
# for keyAndTime
				my $keyAndTime = substr (@voices[0], $index-1, 8); # XX XX/XX
					if ($keyAndTime =~ /(..?) (..?\/..?)/) {
						my $time = $2;
						my $key = $1;
						$key = lc $key;
						my $keyFirstChar = substr ($key, 0, 1);
						my $keySecondChar = substr ($key, 1, 1);
						if ($keySecondChar =~ /b/) { $keySecondChar = "es";}
						elsif ($keySecondChar =~ /#/) { $keySecondChar = "is";}
						$key = $keyFirstChar.$keySecondChar;
						if (@isFirstMeta[$voiceIdx] == 0) {
# print "}";
							@score[$voiceIdx] .= "\n}\n";
						}
# print "\\time $time \n\\key $key \\major\n\\transpose c $key\n{\n";
						my $transposeheight = "'";
						if ($voiceIdx == 12 or $voiceIdx == 13) {
							 $transposeheight = ",";
						}
						@score[$voiceIdx] .= "\\time $time \n\\key $key \\major\n\\transpose c $key$transposeheight\n{\n"; 
						@isFirstMeta[$voiceIdx] = 0;
					}

# for partial measures
				my $partialMeasureLength = substr (@voices[4], $index-1, 1);
				if ($partialMeasureLength =~ /\d/) {
					@score[$voiceIdx] .= "\n\\partial $partialMeasureLength\n";
				}

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
for (my $voiceIdx = 9; $voiceIdx <= 13 ; $voiceIdx++){
# print "\\bar \"|.\"\n}"; # for closing transpose
	if(@isEmptyVoice[$voiceIdx] == 0){
		@score[$voiceIdx] .= "\\bar \"|.\"\n}";
	}
}  
#  print Dumper @score;

open(LYTPLFI,FIDIR."/".LYTPLFINAME);
my $lytpllines;
while(<LYTPLFI>){ $lytpllines .= $_; }
close(LYTPLFI);

my $midireplacement;
my $pdfreplacement;
if ($generatemidi == 1){
	$midireplacement = "\\midi{}";
}
if ($generatepdf == 1){
	$pdfreplacement = << 'END';
	\layout
	{
		\context
		{
			\Score
				\override SpacingSpanner
#'base-shortest-duration = #(ly:make-moment 1 10)
		}
	}
END
}

my $staff1tmpl = '';
my $staff2tmpl = '';
my $staff3tmpl = '';

if (@isEmptyVoice[9] == 0) {
$staff1tmpl = << 'END';
      \new Staff
      <<
        {
          \clef treble
          \voiceOne
          [% voiceOneUp %]
        }
      >>
END
}
if (@isEmptyVoice[10] == 0 or @isEmptyVoice[11] == 0) {
$staff2tmpl = << 'END';
      \new Staff
      <<
        {
          \clef treble
          \voiceOne
          [% voiceOne %]
        }
        \\
        {
          \clef treble
          \voiceTwo
          [% voiceTwo %]
        }
      >>
END
}
if (@isEmptyVoice[12] == 0 or @isEmptyVoice[13] == 0) {
$staff3tmpl = << 'END';
      \new Staff
      <<
        {
          \clef bass
          \voiceThree
          [% voiceThree %]
        }
        \\
        {
          \clef bass
          \voiceFour
          [% voiceFour %]
        }
      >>
END
}

$lytpllines =~ s/\[%\s*midi\s*%\]/$midireplacement/g;
$lytpllines =~ s/\[%\s*midiinstrument\s*%\]/$midiinstrument/g;
$lytpllines =~ s/\[%\s*pdf\s*%\]/$pdfreplacement/g;

$lytpllines =~ s/\[%\s*piece\s*%\]/$scoremeta{'piece'}/g;
$lytpllines =~ s/\[%\s*composer\s*%\]/$scoremeta{'composer'}/g;
$lytpllines =~ s/\[%\s*arranger\s*%\]/$scoremeta{'arranger'}/g;
$lytpllines =~ s/\[%\s*poet\s*%\]/$scoremeta{'poet'}/g;

$lytpllines =~ s/\[%\s*staff1\s*%\]/$staff1tmpl/g;
$lytpllines =~ s/\[%\s*staff2\s*%\]/$staff2tmpl/g;
$lytpllines =~ s/\[%\s*staff3\s*%\]/$staff3tmpl/g;

$lytpllines =~ s/\[%\s*voiceOneUp\s*%\]/@score[9]/g;
$lytpllines =~ s/\[%\s*voiceOne\s*%\]/@score[10]/g;
$lytpllines =~ s/\[%\s*voiceTwo\s*%\]/@score[11]/g;
$lytpllines =~ s/\[%\s*voiceThree\s*%\]/@score[12]/g;
$lytpllines =~ s/\[%\s*voiceFour\s*%\]/@score[13]/g;

open(LYFI,">$lyfipath");
print LYFI $lytpllines;
close(LYFI);

system("lilypond --loglevel=ERROR --output=$outprefix $lyfipath");
#unlink($outprefix.".sf",$outprefix.".ly");
}
sub trim {
	return $_[0] =~ s/^\s+|\s+$//rg;
}

#print "Content-type: text/html\n\n";
&sf2ly("/var/tmp/nysolfa/ndriana-ramamonjy_mifankatiava.sf");
1;
