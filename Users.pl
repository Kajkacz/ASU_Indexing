#!/usr/local/bin/perl -w

#Kajetan Kaczmarek, projekt 2 
use Tk;
use warnings;
use strict;
require Tk::Dialog;

my $Mw = MainWindow->new;

&getStartWindow;

MainLoop;


sub checkUID{
	my $uidToCheck = shift;
	my $isTaken = 0;
	my $nameTaken = "";

	while((my $name,my $passwd,my $uid,my $gid,my $gcos,my $dir,my $shell) = getpwent(  )){
		if($uid==$uidToCheck){
			$isTaken = 1;
			$nameTaken = $name;
			print $uid;
			last;
		}
	}
	endpwent(  );
	if($isTaken == 1){
		$Mw->Dialog(-title => "Uid Taken!", -text => "UID already taken by user " . $nameTaken)->Show;
	}
	else{
		$Mw->Dialog(-title => "Uid Free!", -text => "Yay!")->Show;
	}
	
}
sub getFreeUID{
	my $uidSelected = 0;

	while((my $name,my $passwd,my $uid,my $gid,my $gcos,my $dir,my $shell) = getpwent(  )){
		if($uid>=1000 && $uid<60000){
			$uidSelected = ($uidSelected < $uid )? $uid : $uidSelected ;
			
		}
	}
	return ++$uidSelected;
	
}

sub listUsersPage{
	$Mw->destroy;
	$Mw = MainWindow->new;
	$Mw->geometry("500x300");
	$Mw->title("User List");
	
	while((my $name,my $passwd,my $uid,my $gid,my $gcos,my $dir,my $shell) = getpwent(  )){
		if($uid>=1000 && $uid<=60000){
			$Mw->Label(-text=>$name)->grid($Mw->Label(-text=>$uid));
		}
	}
	$Mw->Button(-text=>"Back to Main Menu", -command =>sub{&getStartWindow})->grid();
	endpwent(  );
}

sub randomizePassword{
	my @chars = ("A".."Z", "a".."z");
	my $string;
	$string .= $chars[rand @chars] for 1..8;
	return $string;
}
sub createUser{
	#//TODO
}
sub createUserPage{
	$Mw->destroy;
	$Mw = MainWindow->new;
	$Mw->geometry("500x300");
	$Mw->title("Create User");
	
	my $uid = &getFreeUID;
	my $uspasswd = '';
	my $usname = '';
	
	my $username = $Mw->Entry(-textvariable=> \$usname )->grid($Mw->Label(-text => 'Username'));
	my $UID = $Mw->Entry(-textvariable=> \$uid )->grid($Mw->Label(-text => 'UID'));
	my $password = $Mw ->Entry(-textvariable=> \$uspasswd)->grid($Mw->Label(-text => 'Password'));

	$Mw->Button(-text=>"Create User", -command =>sub{&createUser})->grid();
	$Mw->Button(-text=>"Check If UID is free", -command =>sub{&checkUID($uid)})->grid();
	$Mw->Button(-text=>"Get Random Password", -command =>sub{$uspasswd = &randomizePassword})->grid();
	
	$Mw->Button(-text=>"Back to Main Menu", -command =>sub{&getStartWindow})->grid();

}

sub saveCredentials{
	
}
sub myCredentialsPage{
	$Mw->destroy;
	$Mw = MainWindow->new;
	$Mw->geometry("500x300");
	$Mw->title("My Credentials");
	
	my $nwpasswd = '';
	my $oldpasswd = '';
	my $myuid = $>;
	my $usname = 	getpwuid($>);
	my $uid = $Mw->Label(-textvariable=> \$myuid )->grid($Mw->Label(-text => 'My UID'));
	my $username = $Mw->Label(-textvariable=> \$usname )->grid($Mw->Label(-text => 'My Username'));
	my $newPassword = $Mw ->Entry(-textvariable=> \$nwpasswd)->grid($Mw->Label(-text => 'New Password'));
	my $oldPassword = $Mw ->Entry(-textvariable=> \$oldpasswd)->grid($Mw->Label(-text => 'New Password'));


	$Mw->Button(-text=>"Save My Credentials", -command =>sub{&saveCredentials})->grid();
	$Mw->Button(-text=>"Get Random Password", -command =>sub{$nwpasswd = &randomizePassword})->grid();
	
	$Mw->Button(-text=>"Back to Main Menu", -command =>sub{&getStartWindow})->grid();
}
sub myGroupsPage{
	$Mw->destroy;
	$Mw = MainWindow->new;
	$Mw->geometry("500x300");
	$Mw->title("User List");
	
	while((my $name,my $passwd,my $uid,my $gid,my $gcos,my $dir,my $shell) = getpwent(  )){
		if($uid>=1000 && $uid<=60000){
			$Mw->Label(-text=>$name)->grid($Mw->Label(-text=>$uid));
		}
	}
	$Mw->Button(-text=>"Back to Main Menu", -command =>sub{&getStartWindow})->grid();
	endpwent(  );
}
sub getStartWindow{
	$Mw->destroy;
	$Mw = MainWindow->new;
	$Mw->geometry("500x300");
	$Mw->title("User Managment Tool");

	$Mw->Label(-text => 'Administration')->pack();

	$Mw->Button(-text=>"Create User", -command =>sub{&createUserPage})->pack();
	$Mw->Button(-text=>"List and delete the users", -command =>sub{&listUsersPage})->pack();
	$Mw->Button(-text=>"My Groups", -command =>sub{&myGroupsPage})->pack();
	$Mw->Button(-text=>"My Credentials", -command =>sub{&myCredentialsPage})->pack();


	$Mw->Button(-text=>"Close", -command =>sub{exit})->pack();
	}