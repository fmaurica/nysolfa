#!/usr/bin/perl

use CGI;
use CGI::Carp 'fatalsToBrowser';

use HTML::Template;
 
use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib dirname(dirname abs_path $0);
use Solfa qw(sf2ly);

use constant TMPDIR => "C:\\Users\\Public\\solfa";

my $q = CGI->new;

$lightweight_fh = $q->upload('file');

# undef may be returned if it's not a valid file handle
if (defined $lightweight_fh) {
  # Upgrade the handle to one compatible with IO::Handle:
  my $io_handle = $lightweight_fh->handle;

  my $filename = $q->param('file');
  my $savepath = TMPDIR."\\$filename";
  open (OUTFILE,'>',$savepath);
  while ($bytesread = $io_handle->read($buffer,1024)) {
    print OUTFILE $buffer;
  }
  close OUTFILE;
  &sf2ly($savepath);
  my $fileprefix = substr($filename,0,-3);
  my $result = HTML::Template->new(filename => 'result.tmpl.html');
  $result->param(PDFURL => "files/$fileprefix.pdf");
  $result->param(MIDIURL => "files/$fileprefix.mid");
  print "Content-type: text/html\n\n", $result->output;
}