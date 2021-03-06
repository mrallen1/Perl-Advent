#!perl -sw
#mods.pl -- Previous Perl Advent Calendar Modules v3

use strict;
use vars '$html'; #Switch for HTML output to provide linked module names

use LWP::Simple;
use HTML::HeadParser;
use HTML::TokeParser;
use Text::Table;
use Lingua::EN::Numbers::Ordinate;

my $table = Text::Table->new( qw(Date Module) );

#2000 is a special case
{
  my $content = get($_="http://perladvent.org/2000/");
  unless( $content ) {
    warn("No content for: $_\n");
    last; }

  my $parser = HTML::TokeParser->new(\$content);

  my $D = 1;
  #Cheaply lifted from the Toke documentation
  while (my $token = $parser->get_tag("li")) {
    my $title = fixTitle( $parser->get_trimmed_text("/li") );
    $table->add(sprintf("2000-12-%02i", $D++), $title);    
  }
}

my $header = HTML::HeadParser->new();

foreach my $Y ( 2001 .. 2004 ){
  foreach my $D ( 1..25 ){

    my $content = get( $_ = sprintf("http://perladvent.org/$Y/%s",
				    ordinate($D))
		     );
    unless( $content ) {
      warn("No content for: $_\n");
      next; }

    $header->parse($content);
    my $title = fixTitle( $header->header('Title'), $Y);
    
    $table->add( sprintf("$Y-12-%02i", $D), $title );
  }
}

print $table;

#Never you mind this...
sub fixTitle{
  my($title, $year) = @_;

  $title =~ s/Perl $year Advent Calendar: // if $year;

  #These are unavailable
  $title = '' if $title =~ /^tbc|Perl Advent Calendar|Lost/;
  if( $html && length($title) ){
    $title = qq(<a href="http://search.cpan.org/search?module=$title">$title</a>);
  }
  elsif( ! length($title) ){
    $title = 'N/A';
  }

  return $title;
}
