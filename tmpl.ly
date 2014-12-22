\version "2.16.2"
\book
{
  \paper {
    scoreTitleMarkup = \markup {
      \fill-line {
        \null
        \dir-column {
          \fill-line {
            \center-align \fontsize #3 \bold \fromproperty #'header:piece
          }
	  \fill-line {
	    \concat {
              \hspace #8
              \fromproperty #'header:poet
            }
            \dir-column {
              \fromproperty #'header:composer
              \fromproperty #'header:arranger
            }
	  }
	}
      }
    }
  }
  \header { tagline = ##f }\score
  {
    \new PianoStaff \with {midiInstrument = #"[% midiinstrument %]"}
    <<
      \new Staff
      <<
        {
          \clef treble
          \voiceOne
          [% voiceOneUp %]
        }
      >>
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
    >>
    
    \header 
    {  
      piece = "[% piece %]"
      composer = "[% composer %]"
      arranger = "[% arranger %]"
      poet = "[% poet %]"
    }
    [% midi %]
    [% pdf %]
  }
}
