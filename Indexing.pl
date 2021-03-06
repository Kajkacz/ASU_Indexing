#!/usr/local/bin/perl -w

#Kajetan Kaczmarek, zadanie nr.2 Indexing

use Tk;
use warnings;
use strict;

my $Mw = MainWindow->new;
$Mw->geometry("500x300");
$Mw->title("Indexing");

$Mw->Label(-text => 'Indexer')->pack();

$Mw->Button(-text=>"Close", -command =>sub{exit})->pack();
$Mw->Button(-text=>"Search Exact", -command =>sub{&searchFileExact})->pack();
$Mw->Button(-text=>"Search Regular Expression", -command =>sub{&searchFileRegular($Mw )})->pack();
$Mw->Button(-text=>"Index", -command =>sub{&Index})->pack();

my $filePathEntry = $Mw->Entry(-text=>"Test.txt" )->pack(); #/home/Kajkaz/Dokumenty/ASU_Projekt/
my $phraseToSearch = $Mw->Entry(-text=>"Phrase to find" )->pack();

MainLoop;

sub searchFileExact{
my $filePath = $filePathEntry->get();
print("Path of file to open : " ,$filePath, "\n");

open(my $File, '<:encoding(UTF-8)',$filePath)
	or die"Could not open file '$filePath' $!";
my $phrase = $phraseToSearch->get();

my @results;
my $i = 1;
local $/ = ' ';

while(my $word = <$File>){
	if(index($word, $phrase) != -1){
		push(@results,$i);}
	$i++;
}
print @results;
return @results;
}

sub searchFileRegular{
	
my $filePath = $filePathEntry->get();
print("Path of file to open : " ,$filePath, "\n");

open(my $File, '<:encoding(UTF-8)',$filePath)
	or die"Could not open file '$filePath' $!";
my $phrase = $phraseToSearch->get();

my @results;
my $i = 1;
local $/ = ' ';

while(my $word = <$File>){
	if($word =~ /$phrase/){
		push(@results,$i);
		}
	$i++;
}
print @results , " ";
print "\n";
my $Mv = shift;
my $dialog = $Mv->Dialog(
	-title => "Result",
	-text => @results);
			
$dialog->Popup(qw/
    -popover    => $Mv,
    -overanchor => c ,
    -popanchor  => c ,
/);
return @results;

	}

sub Index{
my $filePath = $filePathEntry->get();
print("Path of file to open : " ,$filePath, "\n");

open(my $File, '<:encoding(UTF-8)',$filePath)
	or die"Could not open file '$filePath' $!";
	
my %results;
my $i = 1;
local $/ = ' ';
while(my $word = <$File>){
	push(@{$results{$word}}, $i++);
}
use feature 'say';
for my $phrase (keys %results){
	print "$phrase : @{ $results{$phrase} } \n";
	} 
return %results;
}