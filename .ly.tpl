\version "2.18.2"
\book
{
  \paper {
    scoreTitleMarkup = \markup {
      \fill-line {
        \null
        \fill-line {
          \dir-column {
            \center-align \fontsize #4 \bold \fromproperty #'header:piece
            \fromproperty #'header:composer
            \fromproperty #'header:arranger
          }
        }
      }
    }
  }
  \header { tagline = ##f }\score
  {
    \new PianoStaff
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
    \midi { }    
    \layout
    {
      \context
      {
        \Score
        \override SpacingSpanner
        #'base-shortest-duration = #(ly:make-moment 1 10)
      }
    }
  }
}