# nysolfa

`nysolfa` was a web application for editing [tonic solfa](https://en.wikipedia.org/wiki/Tonic_sol-fa) scores.
Around 2012 to 2014, it was accessible at http://nysolfa.org.
Since then, the webapp died.
However, `nysolfa` can still be used as a CLI tool.


## Features

`nysolfa` can produce [solfège](https://en.wikipedia.org/wiki/Solf%C3%A8ge) from solfa,
as well as corresponding midi sounds.

```
$ brew install lilypond
$ perl Solfa.pm ./sfexamples/fihirana-ffpm_441.sf 0       <-- use 0 for pdf generation
$ perl Solfa.pm ./sfexamples/fihirana-ffpm_441.sf 1       <-- use 0 for midi generation
```

Examples are given in `./sfexamples`.


## License

Technically speaking, nysolfa is a compiler from sf (a custom SolFa-based language) to [lilypond](https://lilypond.org/).
As lilypond is released under the GNU GPL license, hence so is nysolfa.
