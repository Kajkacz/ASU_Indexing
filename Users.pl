#!/usr/local/bin/perl -w

#Kajetan Kaczmarek, projekt 2
use Tk;
use warnings;
use strict;
require Tk::Dialog;
my $buttonWidth = 30;
my $buttonHeight = 20;
my $Mw = MainWindow->new;

getStartWindow;

MainLoop;
sub deleteUser{
	my $UID = shift;
	my $username = 	getpwuid($UID);
	my $deluser = '/usr/sbin/deluser';
	my $cmd = qq($deluser $username);
  system $cmd;
}
sub createUser{
	my $UID = shift;
	my $username = 	shift;
	my $password = shift;
	my $adduser = '/usr/sbin/useradd';
	my $cmd = qq($adduser \"$username\");
	# my $cmd = qq($adduser \"$username\" -p \"$password\" -u $UID);
	print "$cmd \n";
  system $cmd;
}
sub saveCredentials{
	#//TODO
}
sub checkUID{
	my $uidToCheck = shift;
	my $isTaken = 0;
	my $nameTaken = "";
	print $uidToCheck;
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
	endpwent(  );

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
	my $uid;
	$Mw->Label(-text=>"Delete User with provided UID")->grid();
	$Mw->Button(-text=>"Delete user" ,-command=>sub{deleteUser($uid)} ,-width => 15)->grid($Mw->Entry(-textvariable=> \$uid ));
	$Mw->Button(-text=>"Back to Main Menu", -command =>sub{getStartWindow})->grid(	$Mw->Button(-text=>"Refresh", -command =>sub{listUsersPage}));
	endpwent(  );
}

sub randomizePassword{
	my @chars = ("A".."Z", "a".."z");
	my $string;
	$string .= $chars[rand @chars] for 1..8;
	return $string;
}

sub createUserPage{
	$Mw->destroy;
	$Mw = MainWindow->new;
	$Mw->geometry("500x300");
	$Mw->title("Create User");

	my $uid = getFreeUID;
	my $uspasswd = randomizePassword;
	my $usname = 'UsernameHere';

	my $username = $Mw->Entry(-textvariable=> \$usname )->grid($Mw->Label(-text => 'Username'));
	my $UID = $Mw->Entry(-textvariable=> \$uid )->grid($Mw->Label(-text => 'UID'));
	my $password = $Mw ->Entry(-textvariable=> \$uspasswd)->grid($Mw->Label(-text => 'Password'));

	$Mw->Button(-text=>"Create User", -command =>sub{createUser($uid,$usname,$uspasswd)},-width => $buttonWidth)->grid();
	$Mw->Button(-text=>"Check If UID is free", -command =>sub{checkUID($uid)},-width => $buttonWidth)->grid();
	$Mw->Button(-text=>"Get Random Password", -command =>sub{$uspasswd = randomizePassword},-width => $buttonWidth)->grid();

	$Mw->Button(-text=>"Back to Main Menu", -command =>sub{getStartWindow},-width => $buttonWidth)->grid();

}


sub myCredentialsPage{
	$Mw->destroy;
	$Mw = MainWindow->new;
	$Mw->geometry("600x400");
	$Mw->title("My Credentials");

	my $olduid = $>;
	my $newuid = $>;
	my $oldusername = 	getpwuid($>);
	my $newusername = 	getpwuid($>);
	(my $name,my  $pass,my  $uid,my  $gid,my  $quota,my  $comment,my  $gcos,my  $dir,my  $shell,my  $expire) = getpwnam($oldusername);
	my $newpasswd = $pass;
	my $oldpasswd = $pass;
	my $oldgcos=  $gcos;
	my $newgcos= $gcos;
	my $olddir=$dir;
	my $newdir=$dir;
	my $oldshell=$shell ;
	my $newshell=$shell;
	my $groupName = getgrgid($gid);

	my $columnNames = $Mw ->Label(-text=>"")->grid($Mw ->Label(-text=>"Old Value"),$Mw ->Label(-text=>"New Value"));
	my $uidButton = $Mw->Label(-text => 'My UID')->grid( $Mw->Label(-textvariable=> \$olduid ), $Mw->Entry(-textvariable=> \$newuid ));
	my $usernameButton = $Mw->Label(-text => 'My Username')->grid($Mw->Label(-textvariable=> \$oldusername ),$Mw->Entry(-textvariable=> \$newusername ));
	my $PasswordButton =$Mw->Label(-text => 'Password')->grid( $Mw ->Label(-textvariable=> \$oldpasswd), $Mw ->Entry(-textvariable=> \$newpasswd));
	my $gcosButton = $Mw->Label(-text => 'My Gcos')->grid($Mw ->Label(-textvariable=> \$oldgcos),$Mw ->Entry(-textvariable=> \$newgcos));
	my $dirButton = $Mw->Label(-text => 'My Directory')->grid($Mw ->Label(-textvariable=> \$olddir),$Mw ->Entry(-textvariable=> \$newdir));
	my $shellButton =$Mw->Label(-text => 'My Shell')->grid( $Mw ->Label(-textvariable=> \$oldshell), $Mw ->Entry(-textvariable=> \$newshell));
	my $gtoupButton =$Mw->Label(-text => 'My Group')->grid( $Mw ->Label(-textvariable=> \$groupName), $Mw ->Label(-textvariable=> \$gid));

	$Mw->Button(-text=>"Save My Credentials", -command =>sub{saveCredentials},-width => $buttonWidth)->grid();
	$Mw->Button(-text=>"Get Random Password", -command =>sub{$newpasswd = randomizePassword},-width => $buttonWidth)->grid();

	$Mw->Button(-text=>"Back to Main Menu", -command =>sub{getStartWindow},-width => $buttonWidth)->grid();
}
sub copyPage{
	$Mw->destroy;
	$Mw = MainWindow->new;
	$Mw->geometry("500x300");




	$Mw->Button(-text=>"Back to Main Menu", -command =>sub{getStartWindow})->grid();

}
sub getStartWindow{
	$Mw->destroy;
	$Mw = MainWindow->new;
	$Mw->geometry("300x200");
	$Mw->title("User Managment Tool");

	$Mw->Label(-text => 'Administration')->pack();

	$Mw->Button(-text=>"Create User", -command =>sub{createUserPage} ,-width => $buttonWidth)->pack();
	$Mw->Button(-text=>"List and delete the users", -command =>sub{listUsersPage},-width => $buttonWidth)->pack();
	$Mw->Button(-text=>"Copy . files", -command =>sub{copyPage},-width => $buttonWidth)->pack();
	$Mw->Button(-text=>"My Credentials", -command =>sub{myCredentialsPage},-width => $buttonWidth)->pack();


	$Mw->Button(-text=>"Close", -command =>sub{exit})->pack();
	}
