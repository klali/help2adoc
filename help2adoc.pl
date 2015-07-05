#!/usr/bin/perl

# Copyright (c) 2015 Yubico AB
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
# 
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
# 
#     * Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

use strict;
use warnings;

use Getopt::Long qw/:config auto_abbrev no_ignore_case/;

our $VERSION = "0.0.1";

my $executable;
my $helpSwitch = "--help";
my $versionSwitch = "--version";
my $verbose = 0;
my $longName;
my $include;

GetOptions("executable|e=s" => \$executable,
  "help-switch=s" => \$helpSwitch,
  "version-switch=s" => \$versionSwitch,
  "name|n=s" => \$longName,
  "include|i=s" => \$include,
  "verbose|v" => \$verbose,
  "help|h" => \&help,
  "version|V" => \&version,
);

die "No executable given" unless $executable;

sub help {
  print "help2adoc $VERSION\n\n";
  print "Usage: help2adoc [OPTIONS]...\n\n";
  print "  -e, --executable\twhat executable to extract from\n";
  print "  --help-switch\t\twhat option to get help (default=--help)\n";
  print "  --version-switch\twhat option to get version (default=--version)\n";
  print "  -n, --name\t\tthe descriptive name to use\n";
  print "  -v, --verbose\t\tprint more information\n";
  print "  -h, --help\t\tPrint help and exit\n";
  print "  -V, --version\t\tPrint version and exit\n";
  exit 0;
}

sub version {
  print "help2adoc $VERSION\n";
  exit 0;
}

my $name;
my $synopsis;
my @help;
my $version;
my $bugs;
my $home;
my @other;

warn "Going to run '$executable' with '$helpSwitch' and '$versionSwitch'.\n" if $verbose;
open(my $helpStream, "-|", "$executable $helpSwitch") or die;

my $gotHelp = 0;
while(<$helpStream>) {
  s/\s+$//;
  s/^(\s+)//;
  my $len = length($1);
  $len = 0 unless $len;
  if(m/^[uU]sage: ([a-zA-Z0-9-_]+) (.*)?/) {
    warn "'$_' matched as usage" if $verbose;
    $name = $1 if $1;
    $synopsis = $2 if $2;
    next;
  }
  next unless $name;
  $gotHelp = 0 if $len == 0 && $_ ne "";
  if(m/^-/) {
    $gotHelp++;
    push @help, $_;
  } elsif(m/^[Rr]eport.* bugs/) {
    $gotHelp = 0;
    $bugs = $_;
  } elsif(m/[Hh]ome\s?page/) {
    $gotHelp = 0;
    $home = $_;
  } elsif($gotHelp) {
    if($_ eq "") {
      $_ = "+";
    }
    my $part = pop(@help);
    $part .= "\n$_";
    push @help, $part;
  } else {
    if($_ eq "") {
      next if $#other == 0;
      $_ = " +";
    }
    push @other, $_;
  }
}
close $helpStream;

die "Failed to extract name" unless $name;
$longName = $name unless $longName;

open(my $versionStream, "-|", "$executable $versionSwitch") or die;
while(<$versionStream>) {
  s/^\s+|\s+$//g;
  if(m/^$name.*\s([a-zA-Z0-9-_\.]+)$/) {
    $version = $1;
  } elsif(m/^([a-zA-Z0-9-_\.]+)/) {
    $version = $1;
  }
  last if $version;
}
close $versionStream;

print "= " . uc($name) . "(1)\n";
print ":doctype:\tmanpage\n";
print ":man source:\t$name\n";
print ":man version:\t$version\n\n";
print "== NAME\n";
print "$name - $longName\n\n";
print "== SYNOPSIS\n";
print "*$name* $synopsis\n\n";
print "== OPTIONS\n";
foreach my $option (@help) {
  my @first;
  my $second;
  foreach my $part (split(/\s/, $option)) {
    if($part =~ m/^-/) {
      push @first, $part;
    } else {
      last;
    }
  }
  $second = $option;
  $second =~ s/,\s-[a-zA-Z0-9-_=\[\]]+//g;
  $second =~ s/^-[a-zA-Z0-9-_=\[\]]+//g;
  $second =~ s/^\s*|[\+]$//g;
  chomp($second);

  print "*" . join(" ", @first) . "*::\n";
  print "$second\n\n";
}

if($include) {
  open(my $includeStream, "<", $include) or die;
  while(<$includeStream>) {
    print $_;
  }
  close $includeStream;
}

if($bugs) {
  print "== REPORTING BUGS\n";
  print "$bugs\n\n";
}

if($home) {
  print "== HOMEPAGE\n";
  print "$home\n\n";
}

if($#other > 0) {
  print "== OTHER\n";
  foreach my $line (@other) {
    print "$line\n";
  }
}
