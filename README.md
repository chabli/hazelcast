hazelcast
=========

Scripts, tools, clients for Hazelcast



Saturday, March 29, 2014
Hazelcast - Script to know if nodes are synchronized
1. Problem

Currently hazelcast does not expose any API on completion of migrations or backups. So if you you want to know quickly if your nodes are synchronised after a reboot, a migration or a backup you must go on the Hazelcast GUI (Mancenter) and check manually if the backup count of each node is correct.

2. The solution

The idea is to use the same mechanism than Hazelcast GUI. I developed quickly a Perl Script that you can get in my GitHub.

3. How To / Tutorial

Requirement: 

Hazelcast + Mancenter (tested with 3.1.5)
Perl 5
Perl Modules :

LWP::Simple 
JSON 
Try::Tiny
Getopt::Long

First execute the sync.pl perl script :

# perl sync.pl --interactive

Then enter the Host IP of your mancenter + the port Number
Enter the map name that you want to check if it's sync in all nodes
Then your cluster name.
