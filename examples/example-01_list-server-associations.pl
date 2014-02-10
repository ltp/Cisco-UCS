#!/usr/bin/perl

# This example enumerates each blade in each chassisA and outputs
# the blade service profile association, oper_state and operability.
#
# Essentially it functions like a slightly improved version of the
# 'show server association' command.
#
# perl ./example-01_list-server-associations.pl
#
# Outputs:
#
# Chassis: 1
#	Server 1:                                          (unassociated/operable)
#	Server 2: org-root/ls-vsphere-node-16              (ok/operable)
# Chassis: 2
#	Server 1: org-root/ls-vsphere-node-15              (ok/operable)
# Chassis: 3
#	Server 1: org-root/ls-vsphere-node-8               (ok/operable)
#	Server 2: org-root/ls-vsphere-node-9               (ok/operable)
#	Server 3: org-root/ls-vsphere-node-10              (ok/operable)
#	Server 4: org-root/ls-vsphere-node-11              (ok/operable)
#	Server 6: org-root/ls-vsphere-node-1               (ok/operable)
#	Server 7: org-root/ls-vsphere-node-2               (ok/operable)
#	Server 8: org-root/ls-vsphere-node-3               (ok/operable)
# ... etc.

use strict;
use warnings;

use Cisco::UCS;

my $ucs = Cisco::UCS->new(	
	cluster  => 'ucs.company.com',
	port     => 443,
	username => 'admin',
	passwd   => 'passw0rd',
	proto    => 'https' );

$ucs->login or die "Failed to log in to cluster: $!\n";

map { 
	print "Chassis: ". $_->id ."\n";
	map { 
		printf( "\tServer %1d: %-40s (%s/%s)\n",
			$_->id, $_->assignment, $_->oper_state, $_->operability )
	} 
	sort { $a->id <=> $b->id } $_->get_blades
}
sort { $a->id <=> $b->id } $ucs->get_chassis;

