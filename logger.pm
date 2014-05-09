#!/usr/bin/perl

package logger;

use strict;
use warnings;
use Exporter qw(import);

our $VERSION = 0.1;
our @ISA = qw(Exporter);
our @EXPORT = qw();
our @EXPORT_OK = qw(base_logger);

sub base_logger {

    my $file = shift;

    open LOG, '>>', $file or die "Cannot write to log file: $!\n";
    print LOG "[", scalar localtime , "] : @_\n";
    close LOG;
}

1;
