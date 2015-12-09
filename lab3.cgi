#!/usr/bin/perl

use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);

use lab3::st00::st00;
use lab3::st01::st01;
use lab3::st02::st02;
use lab3::st03::st03;
use lab3::st04::st04;
use lab3::st06::st06;
use lab3::st07::st07;
use lab3::st09::st09;
use lab3::st11::st11;
use lab3::st13::st13;
use lab3::st14::st14;
use lab3::st18::st18;
use lab3::st19::st19;
use lab3::st22::st22;
use lab3::st24::st24;
use lab3::st26::st26;
use lab3::st27::st27;
use lab3::st28::st28;
use lab3::st29::st29;
use lab3::st30::st30;
use lab3::st31::st31;
use lab3::st32::st32;
use lab3::st33::st33;
use lab3::st39::st39;
use lab3::st43::st43;
use lab3::st45::st45;
use lab3::st46::st46;
use lab3::st47::st47;

my @MODULES = 
(
	\&ST00::st00,
	\&ST01::st01,
	\&ST02::st02,
	\&ST03::st03,
	\&ST04::st04,
	\&ST06::st06,
	\&ST07::st07,
	\&ST09::st09,
	\&ST11::st11,
	\&ST13::st13,
	\&ST14::st14,
	\&ST18::st18,
	\&ST19::st19,
	\&ST22::st22,
	\&ST24::st24,
	\&ST26::st26,
	\&ST27::st27,
	\&ST28::st28,
	\&ST29::st29,
	\&ST30::st30,
	\&ST31::st31,
	\&ST32::st32,
	\&ST33::st33,
	\&ST39::st39,
	\&ST43::st43,
	\&ST45::st45,
	\&ST46::st46,
	\&ST47::st47,
);

my @NAMES = 
(
	"00. Sample",
	"01. Baglikova",
	"02. Badrudinova",
	"03. Baranov",
	"04. Borisenko",
	"07. Goncharov",
	"07. Gorinov",
	"09. Greznev",
	"11. Droggin",
	"13. Zlotnikov",
	"09. Ivanova",
	"18. Klykov",
	"19. Konstantinova",
	"22. Lomakina",
	"24. Mamedov",
	"26. Mikaelian",
	"27. Nikishaev",
	"28. Nikolaeva",
	"29. Novozhentsev",
	"30. Pereverzev",
	"30. Podkolzin",
	"32. Pyatakhina",
	"33. Rekhlova",
	"39. Stupin",
	"43. Frolov",
	"45. Yazkov",
	"46. Bushmakin",
	"47. Utenov",
);

Lab2Main();

sub menu
{
	my ($q, $global) = @_;
	print $q->header();
	my $i = 0;
	print "<pre>\n------------------------------\n";
	foreach my $s(@NAMES)
	{
		$i++;
		print "<a href=\"$global->{selfurl}?student=$i\">$s</a>\n";
	}
	print "------------------------------</pre>";
}

sub Lab2Main
{
	my $q = new CGI;
	my $st = 0+$q->param('student');
	my $global = {selfurl => $ENV{SCRIPT_NAME}, student => $st};
	if($st && defined $MODULES[$st-1])
	{
		$MODULES[$st-1]->($q, $global);
	}
	else
	{
		menu($q, $global);
	}
}
