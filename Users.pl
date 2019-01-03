#!/usr/local/bin/perl -w

#Kajetan Kaczmarek, projekt 2
use Tk;
use warnings;
use strict;
use Getopt::Std;
use File::HomeDir;
use File::Copy;
use Switch;
#use Crypt::PBKDF2;
#use lib "/usr/local/share/perl/5.22.1/Module";
require Tk::Dialog;
my $buttonWidth = 30;
my $buttonHeight = 20;
my $Mw;
our($opt_g,$opt_t);

getopts('gt') or die "Options error";
if ($opt_g){
	$Mw = MainWindow->new;
	getStartWindow();
	}
if($opt_t){
	inlineMain();
}

MainLoop;
sub inlineMain{
	print "What do you want to do?\n1.Create new user?\n2.Delete user by UID?\n3.List exisitng Users?\n4.Copy . files? \n5.Modify User Data\n(q to exit at any time)\n";
	my $choice = <STDIN>;
	chomp $choice;
	switch($choice){
		case 1{
			print "\nCreate new user\n";
			inlineCreateUser();
		}
		case 2{
			print "\nDelete user by UID\n";
			inlineDeleteUser();
		}
		case 3{
			print "\nList of exisitng Users\n";
			listUsersInline();
		}
		case 4{
			print "\nCopy . files\n";
			inlineCopyFile();
		}
		case 5{
			print "\nModify User Data\n";
			inlineChangeCredentials();
		}
		case 'q'{
			print "Exiting.Have a great day! \n";
			exit;
		}
		else{
			print "\nCommand Unrecognized\n";
			inlineMain();
		}
	}
}
sub inlineCopyFile{
	my $source = '';
	my $destination = '';
	print "Choose source folder :  ";
	my $choice = <STDIN>;
	chomp $choice;
	switch($choice){
		case "q" {
			print "\nExiting program\n" ;
			exit;
		}
		else{
			$source = $choice;
		}
	}
	print "Choose destination folder :  ";
	$choice = <STDIN>;
	chomp $choice;
	switch($choice){
		case "q" {
			print "\nExiting program\n" ;
			exit;
		}
		else{
			$destination = $choice;
		}
	}
	copyFiles($source,$destination);
	inlineMain();
}
sub inlineChangeCredentials{
	print "Which user to change?Provide username \n";
	my $UID = '';
	my $username = 	'';
	my $password = '';
	my $oldUsername = '';
	my $choice = <STDIN>;
	chomp $choice;
	switch($choice){
		case "q" {
			print "\nExiting program\n" ;
			exit;
		}
		else{
			$oldUsername = $choice;
		}
	}
	print " Provide New Username : [blank for no change]\n";
	$choice = <STDIN>;
	chomp $choice;
	switch($choice){
		case "q" {
			print "\nExiting program\n" ;
		 	exit;
		}
		case ''{
			print "No change to Username \n"
		}
		else{
			$username = $choice;
		}
	}

	print " Provide Uid (a for automatic free id, blank for no change): \n";

	$choice = <STDIN>;
	chomp $choice;
	switch($choice){
		case "q" {
			print "\nExiting program\n" ;
			exit;
		}
		case ''{
			print "No change to UID \n"

		}
		case "a"{
			$UID = getFreeUID();
			print "Free UID  = " . $UID ." - Enter to Continue \n" ;
			$choice = <STDIN>;
		}
		else{
			if(checkUID($UID) == 1){
				$UID = $choice;
			}
			else{
				$UID = getFreeUID();
				print "\nUID Taken - Autogenerated UID = " . $UID . "\n";
			}
		}
	}
	print  "\nPlease provide password  [blank for no change] \n";
	$choice = <STDIN>;
	chomp $choice;
	switch($choice){
		case "q" {
			print "\nExiting program\n" ;
			exit;
		}
		case ''{
			print "No change to password \n"
		}
		else{
			$password = $choice;
		}
	}
	if(	$UID eq '' && $username eq '' && $password eq ''){
		print "No changes to user\n";
	}else{
		my $changeUserInfoCmd = 'sudo /usr/sbin/usermod';
		if($username ne ''){
			print "	New username = $username\n";
			$changeUserInfoCmd .=" -l \"$username\" ";
		}
		if($UID ne ''){
			print "	New UID = $UID\n";
			$changeUserInfoCmd .=" -u \"$UID\" ";
		}
		if($password ne ''){
			my $encryptedPasswd = crypt($password,"lk");
			print "	Changing password as well , password is encrypted\n";
			$changeUserInfoCmd .=" -p $encryptedPasswd ";
		}
		$changeUserInfoCmd .=" $oldUsername ";
		system $changeUserInfoCmd;
	}
	inlineMain();
}
sub listUsersInline{
	while((my $name,my $passwd,my $uid,my $gid,my $gcos,my $dir,my $shell) = getpwent(  )){
		if($uid>=1000 && $uid<=60000){
			print "User " . $name . " with UID " . $uid ."\n";
		}
	}
	print "\n";
	endpwent(  );
	inlineMain();
}
sub inlineDeleteUser{
	print "Provide UID of user to be deleted\n";
	my $UID  = '';
	my $choice = <STDIN>;
	chomp $choice;
	switch($choice){
		case "q" {
			print "\nExiting program\n" ;
			exit;
		}
		else{
			$UID = $choice;
		}
	}
	if(checkUID($UID) == 1){
		print "User with UID " . $UID ." does not exist.Exiting to menu\n";
		$UID = '';
	}

	if($UID ne ''){
		deleteUser($UID);
	}
	inlineMain();
}
sub inlineCreateUser{
	print " Provide Username : \n";
	my $UID = '';
	my $username = 	'';
	my $password = '';

	my $choice = <STDIN>;
	chomp $choice;
	switch($choice){
		case "q" {
			print "\nExiting program\n" ;
		 	exit;
		}
		else{
			$username = $choice;
			print " Provide Uid (a for automatic free id): \n";
		}
	}


	$choice = <STDIN>;
	chomp $choice;
	switch($choice){
		case "q" {
			print "\nExiting program\n" ;
			exit;
		}
		case "a"{
			$UID = getFreeUID();
			print "Free UID  = " . $UID ." - Enter to Continue \n" ;
			$choice = <STDIN>;
			print  "\nPlease provide password \n";
		}
		else{
			if(checkUID($UID) == 1){
				$username = $choice;
				print  "\nPlease provide password \n";
			}
			else{
				$UID = getFreeUID();
				print "\nUID Taken - Autogenerated UID = " . $UID . "\nPlease provide password \n";
			}
		}
	}
	$choice = <STDIN>;
	chomp $choice;
	switch($choice){
		case "q" {
			print "\nExiting program\n" ;
			exit;
		}
		else{
			$password = $choice;
		}
	}
	if(	$UID ne '' && $username ne ''){
		createUser($UID,$username,$password);
	}
	inlineMain();
}
sub copyFiles{
	my $source = shift;
	print "Copying files, ";
	print 'source : '. $source;
	my $destination = shift;
	print ', destination : '. $destination. "\n";
	opendir(DH,$source) or die "Error opening source directory";
	my @files = readdir(DH);
	foreach my $file (@files){
		next if($file !~ /^\..*$/);
		next if($file =~ /^\.+$/);
		copy($file,$destination) or die "Error copying file : $file";
		print 'File : ' . $file .  " copied \n";
	}
	print "Finished Copying \n\n";
}
sub deleteUser{
	my $UID = shift;
	my $username = 	getpwuid($UID);
	if($opt_t)
	{
		print "Are you sure you want to delete User " . $username . " with UID " . $UID ." ? [Y/N] \n";
		my $choice = <STDIN>;
		chomp $choice;
		if($choice ne "y" && $choice ne "Y"){
				exit;
		}
	}
	print "\nDeleting user with UID : " . $UID ." and username ". $username ."\n";
	my $deluser = '/usr/sbin/userdel';
	my $cmd = qq(sudo $deluser $username);
  system $cmd;
}
sub createUser{
	my $UID = shift;
	my $username = 	shift;
	my $password = shift;
	print "\nCreating user with UID : " . $UID ." and username ". $username ."\n";
	my $adduser = '/usr/sbin/useradd';
	my $cmd = qq(sudo $adduser \"$username\");
	# my $cmd = qq($adduser \"$username\" -p \"$password\" -u $UID);
	#print "$cmd \n";
  system $cmd;
}
sub saveCredentials{
	my $oldusername = shift;
	my $newusername = shift;
	my $oldgcos = shift;
	my $newgcos = shift;
	my $olduid = shift;
	my $newuid = shift;
	my $olddir = shift;
	my $newdir = shift;
	my $oldshell = shift;
	my $newshell = shift;
	my $newpasswd = shift;
	my $anythingNew = 0;
	print " \nChanging user info for user $oldusername - \n";
	my $changeUserInfoCmd = 'sudo /usr/sbin/usermod';

	if($oldusername ne $newusername){
		print "	New username = $newusername\n";
		$changeUserInfoCmd .=" -l \"$newusername\" ";
		$anythingNew = 1;
	}
	if($oldgcos ne $newgcos){
		print "	New Gcos = $newgcos\n";
		my $changeGcosCmd = '/usr/bin/chfn';
		my $cmdGcos = qq(sudo $changeGcosCmd -f \"$newgcos\" \"$oldusername\");
		print $cmdGcos;
		#system $cmdGcos;
	}
	if($olduid ne $newuid){
		print "	New Uid = $newuid\n";
		$changeUserInfoCmd .=" -u $newuid  ";
		$anythingNew = 1;
	}
	if($olddir ne $newdir){
		print "	New dir = $newdir\n";
		$changeUserInfoCmd .=" -d $newdir  ";
		$anythingNew = 1;
	}
	if($oldshell ne $newshell){
		print "	New shell = $newshell\n";
		$changeUserInfoCmd .=" -s $newshell ";
		$anythingNew = 1;
	}
	if($newpasswd ne ''){
		my $encryptedPasswd = crypt($newpasswd,"lk");
		print "Changing password as well , password is encrypted\n";
		$changeUserInfoCmd .=" -p $encryptedPasswd ";
		$anythingNew = 1;
	}
	if($anythingNew == 1){
		$changeUserInfoCmd .= $oldusername;
		print $changeUserInfoCmd ."\n";
		system $changeUserInfoCmd;
	}
}
sub deleteFromGroup{
	my $username = shift;
	my $groupname = shift;
	my $cmd = qq(sudo /usr/sbin/deluser $username $groupname );
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
	print $uidToCheck;
	while((my $name,my $passwd,my $uid,my $gid,my $gcos,my $dir,my $shell) = getpwent(  )){
		if($uid eq $uidToCheck){
			$isTaken = 1;
			$nameTaken = $name;
			print $uid;
			last;
		}
	}
	endpwent(  );

	if($isTaken == 1){
		$Mw->Dialog(-title => "Uid Taken!", -text => "UID $uidToCheck is already taken by user " . $nameTaken)->Show if $opt_g;
		return 0 if $opt_t;
	}
	else{
		$Mw->Dialog(-title => "Uid Free!", -text => "Yay! Uid $uidToCheck is Free!")->Show if $opt_g;
		return 1 if $opt_t;
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
	$Mw->geometry("600x400");
	$Mw->title("My Groups");
	my $username = 	shift;
	my $un = $username;
	my $usernameMenu=$Mw ->Optionmenu(-variable=> \$username);

	while((my $name,my $passwd,my $uid,my $gid,my $gcos,my $dir,my $shell) = getpwent(  )){
		if($uid>=1000 && $uid<=60000){
			$usernameMenu->addOptions($name);
		}
	}
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
	my $i = 0;
	foreach my $group(@allGroups){
		$grName = join ':', (split(':',$group))[0];
		$group = join ':', (split(':',$group))[0 .. 2];
		$group =~ s/.*\://;
		$groupMap{$grName} = $group;
		$menuAdd->addOptions($grName);
		if($i++>23){last;}
	}
	foreach my $group(@myGroups){
		$grName = join ':', (split(':',$group))[0];
		$group = join ':', (split(':',$group))[0 .. 2];
		$group =~ s/.*\://;
		$menuDel->addOptions($grName);
		$groupMap{$grName} = $group;
		$Mw->Label(-text=>$group)->grid($Mw->Label(-text=>$grName));
	}
	$Mw->Button( -command =>sub{addToGroup($username,$groupToAdd)},-width => $buttonWidth,-text=>"Add to a group")->grid($menuAdd);
	$Mw->Button( -command =>sub{deleteFromGroup($username,$groupToDel)},-width => $buttonWidth,-text=>"Remove from a group")->grid($menuDel);
	$Mw->Button(-text=>"Back to Main Menu", -command =>sub{getStartWindow()},-width => $buttonWidth)->grid();

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
	chop($gcos);
	chop($gcos);
	chop($gcos);
	my $newpasswd = '';
	my $oldpasswd = '';
	my $oldgcos=  $gcos;
	my $newgcos= $gcos;
	my $olddir=$dir;
	my $newdir=$dir;
	my $oldshell=$shell ;
	my $newshell=$shell;
	my $menu=$Mw ->Optionmenu(-variable=> \$newshell);

	my $columnNames = $Mw ->Label(-text=>"")->grid($Mw ->Label(-text=>"Old Value"),$Mw ->Label(-text=>"New Value"));
	my $uidButton = $Mw->Label(-text => 'My UID')->grid( $Mw->Label(-textvariable=> \$olduid ), $Mw->Entry(-textvariable=> \$newuid ));
	my $usernameButton = $Mw->Label(-text => 'My Username')->grid($Mw->Label(-textvariable=> \$oldusername ),$Mw->Entry(-textvariable=> \$newusername ));
	my $gcosButton = $Mw->Label(-text => 'My Gcos')->grid($Mw ->Label(-textvariable=> \$oldgcos),$Mw ->Entry(-textvariable=> \$newgcos));
	my $dirButton = $Mw->Label(-text => 'My Directory')->grid($Mw ->Label(-textvariable=> \$olddir),$Mw ->Entry(-textvariable=> \$newdir));
	my $shellButton =$Mw->Label(-text => 'My Shell')->grid( $Mw ->Label(-textvariable=> \$oldshell), $menu);
	my $PasswordButton =$Mw->Label(-text => 'Password')->grid( $Mw ->Label(-textvariable=> \$oldpasswd), $Mw ->Entry(-textvariable=> \$newpasswd));


	getShells($menu);

	$Mw->Button(-text=>"Save My Credentials", -command =>sub{saveCredentials($oldusername,$newusername, $oldgcos, $newgcos,$olduid, $newuid,$olddir,$newdir,$oldshell, $newshell,$newpasswd)},-width => $buttonWidth)->grid();
	$Mw->Button(-text=>"Get Random Password", -command =>sub{$newpasswd = randomizePassword()},-width => $buttonWidth)->grid();

	$Mw->Button(-text=>"Back to Main Menu", -command =>sub{getStartWindow()},-width => $buttonWidth)->grid();
}
sub copyPage{
	$Mw->destroy;
	$Mw = MainWindow->new;
	$Mw->geometry("500x300");
	my $source = "/home/kajkacz/Documents/ASU/ASU_Indexing/Test";
	my $destination = File::HomeDir->my_home . "/Test";
	my $sourceEntry = $Mw->Entry(-textvariable=> \$source )->grid($Mw->Label(-text => 'Source catalogue'));
	my $destinationEntry = $Mw->Entry(-textvariable=> \$destination )->grid($Mw->Label(-text => 'Destination catalogue'));
	my $copyButton = $Mw->Button(-text=>"Copy . files", -command =>sub{copyFiles($source,$destination)},-width => $buttonWidth)->grid();


	$Mw->Button(-text=>"Back to Main Menu", -command =>sub{getStartWindow()})->grid();

}
sub getStartWindow{
		$Mw->destroy;
		$Mw = MainWindow->new;
		$Mw->geometry("300x250");
		$Mw->title("User Managment Tool");

		$Mw->Label(-text => 'Administration')->pack();

		$Mw->Button(-text=>"Create User", -command =>sub{createUserPage()} ,-width => $buttonWidth)->pack();
		$Mw->Button(-text=>"List and delete the users", -command =>sub{listUsersPage()},-width => $buttonWidth)->pack();
		$Mw->Button(-text=>"Copy . files", -command =>sub{copyPage()},-width => $buttonWidth)->pack();
		$Mw->Button(-text=>"My Credentials", -command =>sub{myCredentialsPage()},-width => $buttonWidth)->pack();
		$Mw->Button(-text=>"My Groups", -command =>sub{groupsPage(getpwuid($>))},-width => $buttonWidth)->pack();

		$Mw->Button(-text=>"Close", -command =>sub{exit()})->pack();

	}
