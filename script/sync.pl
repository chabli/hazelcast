#!/usr/bin/perl 

use strict;
use warnings;
use LWP::Simple;
use JSON qw( decode_json );
use Try::Tiny;
use Getopt::Long;

my ($host, $port, $map, $clusterName, $interactive, $usage);

usage() if !@ARGV;
GetOptions(
    "host=s"      => \$host,
    "port=i"      => \$port,
    "map=s"       => \$map,
    "cluster=s"   => \$clusterName,
    "interactive" => \$interactive,
    "usage"       => \$usage,
);
usage() if $usage;

if ($interactive || !$host || !$port || !$map || !$clusterName) {
    my $config = interactiveConfig();

    $host = $config->{'host'};
    $port = $config->{'port'}; 
    $map  = $config->{'map'}; 
    $clusterName = $config->{'clusterName'}; 
}

my $url = buildUrl($host, $port, $map, $clusterName);
checkSync($url);

sub interactiveConfig {
    my %config;

    print 'Host IP of your mancenter (example: 10.142.66.115): ';
    $config{'host'} = getInput();

    print 'Port Number (example: 9010): ';
    $config{'port'} = getInput();

    print 'Map Name (example: AFS_VSI_Authenticate_v1): ';
    $config{'map'} = getInput();

    print 'Cluster Name (example: PPRD): ';
    $config{'clusterName'} = getInput();

    return \%config;
}

sub checkSync {
    my ($url) = @_;

    try{
        my $contents = get($url);
        my $decodedJson = decode_json($contents);
        my $noeud1IP = $decodedJson->{'fillMapMemoryTable'}['0']['1'];
        my $noeud2IP = $decodedJson->{'fillMapMemoryTable'}['1']['1'];
        my $noeud1Entries = $decodedJson->{'fillMapMemoryTable'}['0']['2'];
        my $noeud2Entries = $decodedJson->{'fillMapMemoryTable'}['1']['2'];
        my $noeud1Backups = $decodedJson->{'fillMapMemoryTable'}['0']['4'];
        my $noeud2Backups = $decodedJson->{'fillMapMemoryTable'}['1']['4'];
        print "\nNode 1  = $noeud1IP  -  Entries: $noeud1Entries - Backups_Entries: $noeud1Backups  \n";
        print "Node 2  = $noeud2IP  -  Entries: $noeud2Entries - Backups_Entries: $noeud2Backups  \n\n";

        my $loopContinue = 1;
        my $sleepSec = 2;
        my $waitingTime = 0;
        while ($loopContinue) {
            my $contents = get($url);   
            my $decodedJson = decode_json($contents);
            my $noeud1Entries = $decodedJson->{'fillMapMemoryTable'}['0']['2'];
            my $noeud2Entries = $decodedJson->{'fillMapMemoryTable'}['1']['2'];
            my $noeud1Backups = $decodedJson->{'fillMapMemoryTable'}['0']['4'];
            my $noeud2Backups = $decodedJson->{'fillMapMemoryTable'}['1']['4'];

            if ($noeud1Backups == $noeud2Entries &&  $noeud2Backups == $noeud1Entries) {
                print "\nNodes are synchronized \n";
                $loopContinue = 0;

            }else{
                print "\nWarning ! Synchronization in progress... \n";
                sleep($sleepSec);
            }

            $waitingTime += $sleepSec;
            if($waitingTime % 10 == 0)  {
                print "\nDo you want to continue ? (y/n) \n";
                my $choice = getInput();
                chomp $choice;
                if (lc($choice) eq 'n') {
                    last;
                }
             }  
        }
    } catch {
        warn "caught error: $_";
    };
}

sub buildUrl {
    my ($host, $port, $map, $clusterName) = @_;

    return "http://$host:$port/mancenter-3.1.5/main.do?cluster=$clusterName&operation"
    . "=memberlist_instancelist_alertPopup_versionMismatch_charts_dataTablesMap&type=map"
    . "&instance=$map&chart1type=i_Map_OwnedEntryCount&chart2type=o_Map_total&throughputInterval=60000&curtime=0";
}

sub getInput {
    chomp(my $input = <STDIN>);
    return $input;
}

sub usage {
    die "Usage: $0 --host hostname --port 9010 --map map_name --cluster cluster_name | --interactive\n";
}
