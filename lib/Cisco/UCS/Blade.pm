package Cisco::UCS::Blade;

use warnings;
use strict;

use Carp 		qw(croak);
use Scalar::Util 	qw(weaken);
use Cisco::UCS::Common::PowerStats;

our $VERSION = '0.1';

our @ATTRIBUTES	= qw(association availability discovery dn model name operability presence revision serial uuid vendor);

our %ATTRIBUTES = (
		admin_state		=> 'adminState',
		assignment		=> 'assignedToDn',
		conn_path		=> 'connPath',
		conn_status		=> 'connStatus',
		cores_enabled		=> 'numOfCoresEnabled',
		chassis			=> 'chassisId',
		checkpoint		=> 'checkPoint',
		description		=> 'descr',
		id			=> 'slotId',
		managing_instance	=> 'managingInst',
		memory_speed		=> 'memorySpeed',
		memory_available	=> 'availableMemory',
		memory_total		=> 'totalMemory',
		num_adaptors		=> 'numOfAdaptors',
		num_cores		=> 'numOfCores',
		num_cpus		=> 'numOfCpus',
		num_eth_ifs		=> 'numOfEthHostIfs',
		num_fc_ifs		=> 'numOfFcHostIfs',
		num_threads		=> 'numOfThreads',
		oper_power		=> 'operPower',
		oper_state		=> 'operState',
		server_id		=> 'serverId',
		slot_id			=> 'slotId',
		user_label		=> 'usrLbl',
		uuid_original		=> 'originalUuid'
		);

=head1 NAME

Cisco::UCS::Blade - Class for operations with a Cisco UCS blade.

=cut

=head1 SYNOPSIS

    foreach my $blade ($ucs->chassis(1)->get_blades) {
      printf ("%1d\t: %-20s\n", $blade->id, $blade->serial)
    }

    print $chassis(2)->blade(3)->memory_available;

=head1 DECRIPTION

Cisco::UCS::Blade is a class providing operations with a Cisco UCS Blade.

Note that you are not supposed to call the constructor yourself, rather a Cisco::UCS::Blade object
is created automatically by method calls to a L<Cisco::UCS::Chassis> object.

=cut

sub new {
	my ($class, %args) = @_;
	my $self = {};
	bless $self, $class;
	defined $args{dn}	? $self->{dn} = $args{dn}		: croak 'dn not defined';
	defined $args{ucs}	? weaken($self->{ucs} = $args{ucs})	: croak 'dn not defined';
	my %attr = %{$self->{ucs}->resolve_dn(dn => $self->{dn})->{outConfig}->{computeBlade}};
	
	while (my ($k, $v) = each %attr) { $self->{$k} = $v }

	return $self
}

{
        no strict 'refs';

        while ( my ($pseudo, $attribute) = each %ATTRIBUTES ) { 
                *{ __PACKAGE__ . '::' . $pseudo } = sub {
                        my $self = shift;
                        return $self->{$attribute}
                }   
        }   

        foreach my $attribute (@ATTRIBUTES) {
                *{ __PACKAGE__ . '::' . $attribute } = sub {
                        my $self = shift;
                        return $self->{$attribute}
                }   
        }   
}

sub led {
	my ( $self, $state ) = @_;
	$state = lc $state;
	$state eq 'on' || $state eq 'off' or return;
	my $req = <<XML;
	<configConfMos cookie="$self->{ucs}->{cookie}" inHierarchical="false">
		<inConfigs>
        		<pair key="sys/chassis-$self->{chassisId}/blade-$self->{slotId}/locator-led">
				<equipmentLocatorLed adminState="$state" dn="sys/chassis-$self->{chassisId}/blade-$self->{slotId}/locator-led" id="1" name="" ></equipmentLocatorLed>
			</pair>
		</inConfigs>
	</configConfMos>
XML
	my $xml = $self->{ucs}->_ucsm_request( $req );
	
	if ( defined $xml->{'errorCode'} ) {
		my $self->{error} = (defined $xml->{'errorDescr'} ? $xml->{'errorDescr'} : "Unspecified error");
		print "got error: $self->{error}\n";
		return
	}
	
	return 1
}

sub get_power_stats {
	my $self = shift;
	return Cisco::UCS::Common::PowerStats->new( 
		$self->{ucs}->resolve_dn( dn => "$self->{dn}/board/power-stats" )->{outConfig}->{computeMbPowerStats} )
}

1;
__END__

=head1 METHODS

=head3 admin_state

Returns the administrative state of the specified blade.

=head3 assignment

Returns the dn of the service profile currently assigned to the specified blade.

=head3 association

Returns the association status of the specified blade.

=head3 availability 

Returns the availability status of the specified blade.

=head3 conn_path

Returns the connectivity path detail of the specified blade.

=head3 conn_status

Returns the connectivity path status of the specified blade.

=head3 cores_enabled

Returns the number of enabled cores for the specified blade.

=head3 chassis

Returns the chassis ID of the chassis in which the specified blade is located.

=head3 checkpoint

returns the checkpoint status of the specified blade.

=head3 description

Returns the value of the user description field for the specified blade.

=head3 discovery

Returns the discovery status of the specified blade.

=head3 dn

Returns the dn (distinguished name) of the specified blade in the UCS management heirarchy.

=head3 id

Returns the id of the specified blade in the chassis  - this is equivalent to the slot ID number (e.g. 1 .. 8).

=head3 led ( $state )

Sets the locator led of the blade to the desired state; either on or off;

=head3 managing_instance

Returns the managing instance for the specified blade (either A or B).

=head3 memory_available

Returns the amount of available memory (in Mb) for the specified blade.

=head3 memory_speed

Returns the operational memory speed (in MHz) of the specified blade.

=head3 memory_total

Returns the total amount of memory installed (in Mb) in the specified blade.

=head3 model

Returns the model number of the specified blade.

=head3 name

Returns the name of the specified blade.

=head3 num_adaptors

Returns the number of adaptors in the specified blade.

=head3 num_cores

Returns the number of CPU cores in the specified blade.

=head3 num_cpus

Returns the number of CPUs in teh specified blade.

=head3 num_eth_ifs

Returns the number of Ethernet interfaces configured on teh specified blade.

=head3 num_fc_ifs

Returns the number of Fibre Channel interfaces configured on teh specified blade.

=head3 num_threads

Returns the number of execution threads available on the specified blade.

=head3 operability

Returns the operability status of the specified blade.

=head3 oper_power

Returns the operational power state of the specified blade.

=head3 oper_state

Returns the operational status of the specified blade.

=head3 presence

Returns the presence status of the specified blade.

=head3 revision

Returns the revision level of the specified blade.

=head3 serial

Returns the serial number of the specified blade.

=head3 server_id

Returns the ID of the specified blade in chassis/slot notation (e.g. this value would be 2/8
for a server in the eight slot of the second chassis).

=head3 slot_id

Returns the slot ID of the specified blade - this is the same value as returned by the I<id> method.

=head3 user_label

Returns the value for the user-specified label of the designated blade.

=head3 uuid

Returns the UUID of the specified blade - note that this UUID value is the user-specified value and may differ
to the original UUID value of the blade (see I<uuid_original>).

=head3 uuid_original

Returns the original UUID value of the specified blade - this value is the "burned-in" UUID for the blade.

=head3 vendor

Returns the vendor identifier of the specified blade.


=head1 AUTHOR

Luke Poskitt, C<< <ltp at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-cisco-ucs-blade at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Cisco-UCS-Blade>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Cisco::UCS::Blade


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Cisco-UCS-Blade>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Cisco-UCS-Blade>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Cisco-UCS-Blade>

=item * Search CPAN

L<http://search.cpan.org/dist/Cisco-UCS-Blade/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Luke Poskitt.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut
