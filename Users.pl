#!/usr/local/bin/perl -w

#Kajetan Kaczmarek, projekt 2
use Tk;
use warnings;
use strict;
use Getopt::Std;
use File::HomeDir;
use File::Copy;
use Switch;
require Tk::Dialog;
use POSIX qw(strftime);
my $buttonWidth = 30;
my $buttonHeight = 20;
my $Mw;
our($opt_g,$opt_h,$opt_d,$opt_u,$opt_p,$opt_i,$opt_v,$opt_r);
my $date = strftime "%m%d%Y", localtime;
my $logFileName = "$date" .  'Logs.txt';

getopts('ghd:u:p:i:vr') or die "Options error";
if($opt_h && !$opt_g){
	printHelpText();
}
if ($opt_g){
	$Mw = MainWindow->new;
	getStartWindow();
	}
if($opt_d && !$opt_g){
	deleteUserInline();
}
if($opt_u && !$opt_g){
	addUserInline();
}

MainLoop;
sub saveLogAndPrint{
my $msg = shift;
	if($opt_v)
	{
		print $msg;
	}
my $logDir = '/home/Logs';
if (!(-e $logDir and -d $logDir)) {
	system qq(sudo mkdir $logDir);
	print "Created Log Folder";
}
open(my $fileHandle, ">>", $logDir.'/'.$logFileName)	or die "Can't open the log file: $!";

print $fileHandle $msg;

close $fileHandle;
}
sub printHelpText{
	print "\nThis is helptext.\nTo delete users, use -d option followed by UID.\nTo Add users, use -u options followed by username.\nOptions for adding : -r random password -i specify uid(if not free then ignored), -p specify password \n -v for terminal output.\n";
}
sub deleteUserInline{
	my $UID  = $opt_d;
	if(checkUID($UID) == 1){
		saveLogAndPrint("User with UID  $UID  does not exist.Aborting delete\n");
	}
	else{
		my $Username = 	getpwuid($UID);
		saveLogAndPrint("Deleted user $Username with UID $UID");
		deleteUser($UID);
	}
}
sub addUserInline{
	my $UID = '';
	my $username = 	$opt_u;
	my $password = '';
	if($opt_i){
			$UID = $opt_i;
			if(checkUID($UID) == 0){
					$UID = getFreeUID();
					saveLogAndPrint("\nUID Taken - Autogenerated UID = $UID\n");
				}
	}
	else{
		$UID = getFreeUID();
	}
	if($opt_r){
		$password = randomizePassword();
	}
	if($opt_p){
		$password = $opt_p
	}

	createUser($UID,$username,$password);
	}

sub copyFiles{
	my $source = shift;
	saveLogAndPrint("Copying files, ");
	saveLogAndPrint("source :  $source");
	my $destination = shift;
	saveLogAndPrint(", destination :  $destination\n");
	system "sudo cp $source $destination" or die "Error copying files";
	saveLogAndPrint("Finished Copying \n\n");
}
sub deleteUser{
	my $UID = shift;
	my $username = 	getpwuid($UID);
	saveLogAndPrint("\nDeleting user with UID :  $UID  and username  $username \n");
	my $deluser = '/usr/sbin/userdel';
	my $cmd = qq(sudo $deluser $username);
  system $cmd;
}
sub createUser{
	my $UID = shift;
	my $username = 	shift;
	my $password = shift;
	$UID = getFreeUID() if checkUID($UID) ==0;
	my $encryptedPasswd = crypt($password,"lk");
	saveLogAndPrint("Creating user with UID : " . $UID .", username ". $username ." and password $password\n");
	my $adduser = '/usr/sbin/useradd';
	my $cmd = qq(sudo $adduser -p $encryptedPasswd -u $UID \"$username\");
	copyFiles("/etc/skel","/home/$username");
	system $cmd;
}

sub deleteFromGroup{
	my $username = shift;
	my $groupname = shift;
	#my $cmd = qq(sudo /usr/sbin/userdel $username $groupname ); #UBUNTU
	my $cmd= qq(sudo /usr/bin/gpasswd -d $username $groupname );#FEDORA
	print $cmd;
	system $cmd;
}

sub addToGroup{
	my $username = shift;
	my $groupname = shift;
	my $cmd = qq(sudo /usr/sbin/usermod -a -G  $groupname $username);
	system $cmd;
}

sub getShells{
	my $shellMenu = shift;
	my $cmd = qq(sudo /bin/cat /etc/shells);
	my $opts = `$cmd`;
	my @options = split /\n/,$opts;
	shift @options;
	foreach my $option (@options){
			$shellMenu->addOptions($option);
			print "Available Shell = " . $option . "\n";
		}
	}

sub checkUID{
	my $uidToCheck = shift;
	my $isTaken = 0;
	my $nameTaken = "";
	while((my $name,my $passwd,my $uid,my $gid,my $gcos,my $dir,my $shell) = getpwent(  )){
		if($uid eq $uidToCheck){
			$isTaken = 1;
			$nameTaken = $name;
			last;
		}
	}
	endpwent(  );

	if($isTaken == 1){
		$Mw->Dialog(-title => "Uid Taken!", -text => "UID $uidToCheck is already taken by user " . $nameTaken)->Show if $opt_g;
		return 0 ;#if $opt_u || $opt_d;
	}
	else{
		$Mw->Dialog(-title => "Uid Free!", -text => "Yay! Uid $uidToCheck is Free!")->Show if $opt_g;
		return 1 ;#if $opt_u || $opt_d;
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
	my $height = 120;
	my $uid;
	my $deleteMenu=$Mw ->Optionmenu(-variable=> \$uid);
	$Mw->Label(-text=>"Users Present in the system")->grid();
	while((my $name,my $passwd,my $uid,my $gid,my $gcos,my $dir,my $shell) = getpwent(  )){
		if($uid>=1000 && $uid<=60000){
			$deleteMenu->addOptions($uid);
 			$Mw->Label(-text=>$name)->grid($Mw->Label(-text=>$uid));
			$height+=30;
		}
	}
	$Mw->geometry("500x$height");
	$Mw->Label(-text=>"Delete User with provided UID")->grid();
	$Mw->Button(-text=>"Delete user" ,-command=>sub{deleteUser($uid)} ,-width => 15)->grid(	$deleteMenu);
	$Mw->Button(-text=>"Back to Main Menu", -command =>sub{getStartWindow()})->grid(	$Mw->Button(-text=>"Refresh", -command =>sub{listUsersPage()}));
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
	$Mw->Button(-text=>"Get Random Password", -command =>sub{$uspasswd = randomizePassword()},-width => $buttonWidth)->grid();

	$Mw->Button(-text=>"Back to Main Menu", -command =>sub{getStartWindow()},-width => $buttonWidth)->grid();

}

sub groupsPage{
	$Mw->destroy;
	$Mw = MainWindow->new;
	$Mw->geometry("500x400");
	$Mw->title("My Groups");
	my $height = 300;
	my $username = 	shift;
	my $un = $username;
	my $usernameMenu=$Mw ->Optionmenu(-variable=> \$username);

	while((my $name,my $passwd,my $uid,my $gid,my $gcos,my $dir,my $shell) = getpwent(  )){
		if($uid>=1000 && $uid<=60000){
			$usernameMenu->addOptions($name);
		}
	}
	$Mw->geometry("500x$height");
	$username =$un;
	endpwent();
	my $grName = '';
	my $groupToAdd = '';
	my $groupToDel = '';
	my $agroups = `getent group | grep -v $username `;
	my $mgroups = `getent group | grep  $username `;

	my @allGroups = split /\n/,$agroups;
	my @myGroups = split /\n/,$mgroups;

	my %groupMap;

	my $menuAdd=$Mw ->Optionmenu(-variable=> \$groupToAdd);
	my $menuDel=$Mw ->Optionmenu(-variable=> \$groupToDel);

	$Mw->Label(-text=>"User : ")->grid($usernameMenu,$Mw->Button(-text=>"Refresh list", -command =>sub{groupsPage($username)}));
	$Mw->Label(-text=>"GID")->grid($Mw->Label(-text=>"Group Name"));

	foreach my $group(@allGroups){
		$grName = join ':', (split(':',$group))[0];
		$group = join ':', (split(':',$group))[0 .. 2];
		$group =~ s/.*\://;
		next if $group <1000;
		$groupMap{$grName} = $group;
		$menuAdd->addOptions($grName);
	}
	foreach my $group(@myGroups){
		$height+=30;
		$grName = join ':', (split(':',$group))[0];
		$group = join ':', (split(':',$group))[0 .. 2];
		$group =~ s/.*\://;
		next if $group <1000;
		$menuDel->addOptions($grName);
		$groupMap{$grName} = $group;
		$Mw->Label(-text=>$group)->grid($Mw->Label(-text=>$grName));
	}
	$Mw->Button( -command =>sub{addToGroup($username,$groupToAdd)},-width => $buttonWidth,-text=>"Add to a group")->grid($menuAdd);
	$Mw->Button( -command =>sub{deleteFromGroup($username,$groupToDel)},-width => $buttonWidth,-text=>"Remove from a group")->grid($menuDel);
	$Mw->Button(-text=>"Back to Main Menu", -command =>sub{getStartWindow()},-width => $buttonWidth)->grid();

}

sub getStartWindow{
		$Mw->destroy;
		$Mw = MainWindow->new;
		$Mw->geometry("270x180");
		$Mw->title("User Managment Tool");

		$Mw->Label(-text => 'User Administration')->pack();

		$Mw->Button(-text=>"Create User", -command =>sub{createUserPage()} ,-width => $buttonWidth)->pack();
		$Mw->Button(-text=>"List and delete the users", -command =>sub{listUsersPage()},-width => $buttonWidth)->pack();
		$Mw->Button(-text=>"My Groups", -command =>sub{groupsPage(getpwuid($>))},-width => $buttonWidth)->pack();

		$Mw->Button(-text=>"Close", -command =>sub{exit()})->pack();

	}
