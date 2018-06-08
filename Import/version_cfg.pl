#!/usr/bin/perl

require 5.8.0;

#== Includes ==============
use strict;
use warnings;
use Getopt::Std;
use Data::Dumper;
use Config;

#== Program data ==============
my $prog_data = " ATS Version tool\n".
                " v1.2\n" .
                " Author: Efren Gonzalez Armayor\n\n\n";
printf "$prog_data";

#####################################################################
######################     DEFAULTS     #############################
#####################################################################
my $OP_SYS = $Config{osname};

my $DEBUG = 0;
my $input_file = "01versions.txt";
my @process_extensions = ("txt", "vsprops", "makefile", "sh", "bat");

my $module_pattern = '(\w+)\s+([-\d]+)';     # $1: module name $2: version  // Example ABSE 1-18-0-0

#####################################################################
######################     Globals      #############################
#####################################################################

my $current_time = time();
my $local_time = localtime($current_time);
printf "\tToday is %s\n\n",$local_time;

my $usage = "\nUsage ./version_cfg.pl [d] import file\n" .
            "will modify import files according to version.txt\n\n" .
            "\t -d\tDebug option, to obtain debug output in stdout\n\n\n";

# Call arguments
my %parameters;

# Files to configure
my @files;
# Modules to modify
my %modules;
my @modules;

#DEBUG

#####################################################################
########################     Traps     ##############################
#####################################################################

#-- press control-c to get here
$SIG{INT} = sub {
};

#####################################################################
#########################     MAIN     ##############################
#####################################################################

#-- Check arguments ------------------------
if( !get_options() )
{
    printf "$usage";
    exit 1;
}

main();


#== Main ============================================================

sub main
{
    #Start
    print "Version configuring...\n";

    read_input();

    if($DEBUG){ print "INPUT DEBUG files: "; print Dumper \@files; }
    if($DEBUG){ print "INPUT DEBUG variables: "; print Dumper \%modules; }

    process_files();
}

#####################################################################
##########################   INPUT     ##############################
#####################################################################
sub read_input
{
    open (INPUT, "<$input_file" ) or die ("Cannot open $input_file");
    print "\tModules Configured: \n";
    while(<INPUT>)
    {
        # Get all modules
        if($DEBUG){ print "\tRead modules $_\n"; }
        /${module_pattern}/;
        print "\t\t$1\n";
        $modules{$1} = $2;      # Set hash with MODULE => VERSION
        if($DEBUG){ print "\t\t[$1] = > $2\n"; }
    }
    close(INPUT);
}
#####################################################################
#########################   OUTPUT     ##############################
#####################################################################
sub process_files
{
    my $extension;
    foreach my $file (@files)
    {
        open (INPUT, "<$file") or die ("Cannot open $file");
        $file =~ /\w+.(\w+)/;
        $extension = $1;
        print "\tConfiguring $file\n";
        #--Setup file for output
        my $output_file    = $file . ".tmp";
#        $\ = "\x0d";
        # Output to temp file
        open (OUTPUT, ">$output_file" ) or die ("Cannot open $output_file");
        while(<INPUT>)
        {
#            chomp;
            # Process all modules
            my @vars = keys(%modules);
            my $new_version;
            my @version_split;
            my $version_part;
            if($DEBUG){ print "\tPROCESS - @vars\n"; }
            foreach my $var (@vars)
            {
#                if($DEBUG){ print "\t\tPROCESS - $var: $modules{$var}\n"; }
                if($extension eq "txt")
                {
                    $new_version = $modules{$var};
                    s/(%\w+%\s+)${var}(\s+VERSION_)[-\d]+(\s+.*)/$1${var}$2${new_version}$3/;
                }
                elsif($extension eq "vsprops")
                {
                    @version_split = split(/-/,$modules{$var}); # Version has 4 digits
                    # High part of version
                    $version_part = '_VER_HI';
                    $new_version = join('-',$version_split[0], $version_split[1] );
                    if($DEBUG){ print "\t\t\tPROCESS - $var: VER_HI = $new_version\n"; }
                    s/(.*)${var}${version_part}(.+\s+Value=")[-\d]+("\s+.*)/$1${var}${version_part}$2${new_version}$3/;
                    
                    # Low part of version
                    $version_part = '_VER_LO';
                    $new_version = join('-',$version_split[2], $version_split[3] );
                    if($DEBUG){ print "\t\t\tPROCESS - $var: VER_LO = $new_version\n"; }
                    s/(.*)${var}${version_part}(.+\s+Value=")[-\d]+("\s+.*)/$1${var}${version_part}$2${new_version}$3/;
                    
                    # For binary version only
                    # Binary version
                    $version_part = '_VER_BIN';
                    $new_version = join('-',$version_split[0], $version_split[1], $version_split[2] );
                    if($DEBUG){ print "\t\t\tPROCESS - $var: VER_BIN = $new_version\n"; }
                    s/(.*)${var}${version_part}(.+\s+Value=")[-\d]+("\s+.*)/$1${var}${version_part}$2${new_version}$3/;
                }
                elsif($extension eq "makefile")
                {
                    @version_split = split(/-/,$modules{$var}); # Version has 4 digits
                    # High part of version
                    $version_part = '_VER_HI';
                    $new_version = join('-',$version_split[0], $version_split[1] );
                    if($DEBUG){ print "\t\t\tPROCESS - $var: VER_HI = $new_version\n"; }
                    s/${var}${version_part}(\s+:=\s+)[-\d]+/${var}${version_part}$1${new_version}/;
                    
                    # Low part of version
                    $version_part = '_VER_LO';
                    $new_version = join('-',$version_split[2], $version_split[3] );
                    if($DEBUG){ print "\t\t\tPROCESS - $var: VER_LO = $new_version\n"; }
                    s/${var}${version_part}(\s+:=\s+)[-\d]+/${var}${version_part}$1${new_version}/;
                    
                    # For binary version only
                    # Binary version
                    $version_part = '_VER_BIN';
                    $new_version = join('-',$version_split[0], $version_split[1], $version_split[2] );
                    if($DEBUG){ print "\t\t\tPROCESS - $var: VER_BIN = $new_version\n"; }
                    s/${var}${version_part}(\s+:=\s+)[-\d]+/${var}${version_part}$1${new_version}/;
                }
                elsif($extension eq "sh")
                {
                    $new_version = $modules{$var};
                    s/(${var}_VER=)[-\d]+/$1${new_version}/;
                }
                elsif($extension eq "bat")
                {
                    $new_version = $modules{$var};
                    s/(${var}_VER=)[-\d]+/$1${new_version}/;
                }
            }
            print OUTPUT;
        }
        close(OUTPUT);
#        $\ = undef;
        close(INPUT);
        
        my $cmd;
        # Replace input file with temp file
        if($OP_SYS eq "MSWin32")
        {
            $cmd = "copy " . $output_file  . " " . $file;
        }
        elsif( ($OP_SYS eq "linux")  || ($OP_SYS eq "solaris") )
        {
            $cmd = "cp " . $output_file  . " " . $file;
        }
        else
        {
            die "OPERATING SYSTEM not supported!";
        }
        `$cmd`;
        # Delete temp file
        if($OP_SYS eq "MSWin32")
        {
            $cmd = "del /Q " . $output_file;
        }
        elsif( ($OP_SYS eq "linux")  || ($OP_SYS eq "solaris") )
        {
            $cmd = "rm -f " . $output_file;
        }
        else
        {
            die "OPERATING SYSTEM not supported!";
        }
        `$cmd`;
    }
}

#####################################################################
#######################    PARAMETERS   #############################
#####################################################################

#= Get command line options==========================================
sub get_options
{
    # Look verbose and pid number parameters. ATENTION! CAUTION! see $usage string
    if( !getopts('d', \%parameters) )
    {
        print "Parameter obtention, with errors\n";
        return 0;
    }

    # Debug set
    $DEBUG = ( exists($parameters{d}) );
    
    # last parameter must be configuration file
    # $#ARGV  is generally the number of arguments minus one,
    # because $ARGV[0]  is the first argument, not the program's command name itself.
    # Valid number of arguments
    unless( ($#ARGV > -1) && ($#ARGV < 1) )
    {
        return 0;
    }
    $parameters{file} = $ARGV[$#ARGV];
    #Validate files
    my $filename;
    foreach my $ext (@process_extensions)
    {
        $filename = $parameters{file} . "." . $ext;
        die "Can't find file \"$filename\""
          unless -f ($filename);
        push(@files, $filename);
    }

    if($DEBUG){ printf "\tDEBUG Parameters obtention\n"; print Dumper \%parameters; }

    return 1;
}

#####################################################################
#########################     AUX      ##############################
#####################################################################
