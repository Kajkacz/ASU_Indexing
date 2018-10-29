#!/usr/local/bin/perl -w

#Kajetan Kaczmarek, zadanie nr.2 Indexing

use Tk;
use warnings;
use strict;

my $Mw = MainWindow->new;
$Mw->geometry("400x200");
$Mw->title("Indexing");

$Mw->Label(-text => 'Indexer')->pack();

$Mw->Button(-text=>"Close", -command =>sub{exit})->pack();
$Mw->Button(-text=>"Execute Exact", -command =>sub{&readFromFile})->pack();
$Mw->Button(-text=>"Execute Regular Expression", -command =>sub{&readFromFile})->pack();

my $filePathEntry = $Mw->Entry(-text=>"Test.txt" )->pack(); #/home/Kajkaz/Dokumenty/ASU_Projekt/
my $phraseToSearch = $Mw->Entry(-text=>"Phrase to find" )->pack();

dbmopen(%DATA, "IndexDB", 0644)
  or die "Cannot create IndexDataBase: $!";
 
MainLoop;

sub readFromFile{
my $filePath = $filePathEntry->get();
print("Path of file to open : " ,$filePath, "\n");

open(my $File, '<:encoding(UTF-8)',$filePath)
	or die"Could not open file '$filePath' $!";

while(my $row = <$File>){
	chomp $row;
	print "$row\n";
	
}
}