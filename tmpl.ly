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
[% staff1 %]
[% staff2 %]
[% staff3 %]
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
