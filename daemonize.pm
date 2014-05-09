#!/usr/bin/perl

package daemonize;

use strict;
use warnings;
use Exporter qw(import);
use POSIX qw(setsid :sys_wait_h);

our $VERSION = 0.1;
our @ISA = qw(Exporter);
our @EXPORT = qw();
our @EXPORT_OK = qw(write_pid kill_before_start daemon daemonize);

sub write_pid {

    my $pid = shift;
    my $pidfile = shift;

    open my $fh, ">", $pidfile or die "Cannot open pidfile: $!\n";
    print $fh $pid;
    close $fh;
}

sub kill_before_start {

    my $pidfile = shift;
    my $pid;

    if ( -f $pidfile ) {
        open my $fh, "<", $pidfile or die "Pidfile present but cannot open it: $!\n";
        my $pid = <$fh>;
        close $fh;

        if ( -f "/proc/$pid/cmdline" ) {
            print "Found previous running daemon with pid $pid. Killing.\n";
            kill 9, $pid;
        }
    }
}

sub daemon {

    my $pidfile = shift;

    kill_before_start($pidfile);

    chdir '/'                 or die "Can't chdir to /: $!";
    umask 0;
    open STDIN, '/dev/null'   or die "Can't read /dev/null: $!";
    open STDOUT, '>/dev/null' or die "Can't write to /dev/null: $!";
    open STDERR, '>/dev/null' or die "Can't write to /dev/null: $!";
    defined(my $pid = fork)   or die "Can't fork: $!";
    exit if $pid;
    setsid                    or die "Can't start a new session: $!";

    write_pid($pidfile, $$);
}

sub daemonize {

    my $pidfile = shift;
    my $name = shift;

    daemon($pidfile);

    $0 = $name;
}

1;
