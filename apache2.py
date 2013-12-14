#############################################
#											#
#				apache2.py					#
#											#
#############################################
#											#
#	Fichier de configuration python			#
# pour le script de cloisonnement MakeJail	#
# pour le confinement du precessus 			#
# apache2-mpm-itk 							#
# 											#
#############################################
#				Changelog					#
# 											#
# Creation		26/10/2013		B. WENDLING	#
# Update		26/10/2013		B. WENDLING	#
# 											#
#############################################


###################
#####  BASIC  #####
#
# CHROOT
# The path to the chroot. The directory must exist and have correct permissions and ownerships.
# Format: "/path/to/jail"
# Default: None
chroot="/chroot/apache2"

# TESTCOMMANDSINSIDEJAIL
# The commands used to start the daemon, a good starting point may be
# the command used in the startup script in /etc/init.d
# Format: ["command1","command2"]
# Default: []
testCommandsInsideJail=["/usr/sbin/apache2ctl start"]

# PROCESSNAMES
# The name of the runnning processes after the daemon has been started.
# Format: ["process1","process2"]
# Default: []
processNames=["apache2"]


###################
#####  TESTS  #####
#
# TESTCOMMANDSOUTSIDEJAIL
# The test commands which should be executed.
# Format: ["command1","command2"]
# Default: []
testCommandsOutsideJail=["wget -r --spider http://localhost/",
						 "lynx --source https://localhost/"]


###################
# DEBIAN SPECIFIC #
#
# PACKAGES
# The name of the packages. It will copy the files which belongs to the package
# according to the file /var/lib/dpkg/info/$package.list.
# Format: ["package1","package2"]
# Default: []


###################
## Copying files ##
#
# FORCECOPY
# When initializing the jail, copy the files matching these patterns according
# to the rules used by the Unix shell.
# No tilde expansion is done, but *, ?, and character ranges expressed
# with [] will be correctly matched.
# Format: ["path1","path2"]
# Default: []
forceCopy=[ "/etc/hosts",
            "/etc/mime.types",
            "/etc/resolv.conf",
            "/etc/apache2/mods-enables/*",
            "/usr/lib/gconv",
            "/usr/lib/perl",
            "/usr/share/perl*"]

# PRESERVE
# Useful only if cleanJailFirst=1, makejail won't remove files or directories if
# their path begins with one of the strings in this list.
# When updating a jail, you should for example put the locations of log files here.
# Format: ["path1","path2"]
# Default: []
preserve=["/var/www",
		  "/var/log/apache",
		  "/dev/log",
		  "/etc/shadow"]

# USERS
# Makejail will filter the files listed in the directive userFiles and
# copy only lines matching these users, which means lines starting with "user:"
# You can use ["*"] to disable filtering and copy the whole file.
# Format: ["user1","user2"]
# Default: []
users=["www-data"]

# GROUPS
# Makejail will filter the files listed in the directive groupFiles and
# copy only lines matching these groups, which means lines starting with "group:"
# You can use ["*"] to disable filtering and copy the whole file.
# Format: ["group1","group2"]
# Default: []
groups=["www-data"]


########################################
# PATHS SO SPECIFIC FILES AND COMMANDS #
#
# USERFILES
# List of the files whose contents should be filtered, to keep only the users
# listed in the directive "users".
# Format: ["file1","file2]
# Default: ["/etc/passwd","/etc/shadow"]

# GROUPFILES
# List of the files whose contents should be filtered, to keep only the groups
# listed in the directive "groups".
# Format: ["file1","file2]
# Default:["/etc/group","/etc/gshadow"]
