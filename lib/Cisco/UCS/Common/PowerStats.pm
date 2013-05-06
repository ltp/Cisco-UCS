package Cisco::UCS::Common::PowerStats;

use strict;
use warnings;

use Scalar::Util qw(weaken);

our $VERSION = '0.01';

our %V_MAP = (
	consumedPower	=> 'consumed_power',
	consumedPowerAvg=> 'consumed_power_avg',
	consumedPowerMin=> 'consumed_power_min',
	consumedPowerMax=> 'consumed_power_max',
	inputCurrent	=> 'input_current',
	inputCurrentAvg	=> 'input_current_avg',
	inputCurrentMin => 'input_current_min',
	inputCurrentMax => 'input_cureent_max',
	inputVoltage	=> 'input_voltage',
	inputVoltageAvg	=> 'input_voltage_avg',
	inputVoltageMin	=> 'input_voltage_min',
	inputVoltageMax	=> 'input_voltage_max',
	thresholded	=> 'thresholded',
	suspect		=> 'suspect',
	timeCollected	=> 'time_collected'
);

{ no strict 'refs';

	while ( my ($attribute, $pseudo) = each %V_MAP ) {
		*{ __PACKAGE__ .'::'. $pseudo } = sub {
			my $self = shift;
			return $self->{$attribute}
		}
	}
}

sub new {
	my ( $class, $args ) = @_;

	my $self = bless {}, $class;
	
	foreach my $var ( keys %$args ) {
		$self->{ $var } = $args->{ $var };
	}

	return $self
}

1;

__END__

=head1 NAME

Cisco::UCS::Common::PowerStats - Class for operations with a Cisco UCS Common::PowerStats power usage statistics.

=cut

=head1 SYNOPSIS

	# Print all blades in all chassis along with a cacti-style listing of the
	# blades current, minimum and maximum power consumption values.

	map { 
		print "Chassis: " . $_->id ."\n";
		map { print "\tCommon::PowerStats: ". $_->id ." - Power consumed -"
			  . " Current:". $_->power_stats->consumed_power 
			  . " Max:". $_->power_stats->consumed_power_max 
			  . " Min:". $_->power_stats->consumed_power_min ."\n" 
		} 
		sort { $a->id <=> $b->id } $_->get_blades
	} 
	sort { 
		$a->id <=> $b->id 
	} $ucs->get_chassiss;

	# Prints something like:
	#
	# Chassis: 1
	#	Blade: 1 - Power consumed - Current:115.656647 Max:120.913757 Min:110.399513
	#	Blade: 2 - Power consumed - Current:131.427994 Max:139.313675 Min:126.170883
	#	Blade: 3 - Power consumed - Current:131.427994 Max:157.713593 Min:126.170883
	#	Blade: 4 - Power consumed - Current:0.000000 Max:0.000000 Min:0.000000
	#	Blade: 5 - Power consumed - Current:0.000000 Max:0.000000 Min:0.000000
	#	Blade: 6 - Power consumed - Current:0.000000 Max:0.000000 Min:0.000000
	#	Blade: 7 - Power consumed - Current:0.000000 Max:0.000000 Min:0.000000
	#	Blade: 8 - Power consumed - Current:0.000000 Max:0.000000 Min:0.000000
	# Chassis: 2
	#	Blade: 1 - Power consumed - Current:131.427994 Max:136.685120 Min:128.799438
	#	Blade: 2 - Power consumed - Current:126.170883 Max:131.427994 Min:123.542320
	#	Blade: 3 - Power consumed - Current:134.056564 Max:155.085037 Min:131.427994
	# ...etc.

=head1 DECRIPTION

Cisco::UCS::Common::PowerStats is a class providing operations with a Cisco UCS Common::PowerStats.

Note that you are not supposed to call the constructor yourself, rather a Cisco::UCS::Common::PowerStats object
is created automatically by method calls on a L<Cisco::UCS::Blade> object.

=cut

=head1 METHODS

=head3 admin_state

Returns the administrative state of the specified Common::PowerStats.

=head3 assignment

Returns the dn of the service profile currently assigned to the specified Common::PowerStats.

=head3 association

Returns the association status of the specified Common::PowerStats.

=head3 availability 

Returns the availability status of the specified Common::PowerStats.

=head3 conn_path

Returns the connectivity path detail of the specified Common::PowerStats.

=head3 conn_status

Returns the connectivity path status of the specified Common::PowerStats.

=head3 cores_enabled

Returns the number of enabled cores for the specified Common::PowerStats.

=head3 chassis

Returns the chassis ID of the chassis in which the specified Common::PowerStats is located.

=head3 checkpoint

returns the checkpoint status of the specified Common::PowerStats.

=head3 description

Returns the value of the user description field for the specified Common::PowerStats.

=head3 discovery

Returns the discovery status of the specified Common::PowerStats.

=head3 dn

Returns the dn (distinguished name) of the specified Common::PowerStats in the UCS management heirarchy.

=head3 id

Returns the id of the specified Common::PowerStats in the chassis  - this is equivalent to the slot ID number (e.g. 1 .. 8).

=head3 led ( $state )

Sets the locator led of the Common::PowerStats to the desired state; either on or off;

=head3 managing_instance

Returns the managing instance for the specified Common::PowerStats (either A or B).

=head3 memory_available

Returns the amount of available memory (in Mb) for the specified Common::PowerStats.

=head3 memory_speed

Returns the operational memory speed (in MHz) of the specified Common::PowerStats.

=head3 memory_total

Returns the total amount of memory installed (in Mb) in the specified Common::PowerStats.

=head3 model

Returns the model number of the specified Common::PowerStats.

=head3 name

Returns the name of the specified Common::PowerStats.

=head3 num_adaptors

Returns the number of adaptors in the specified Common::PowerStats.

=head3 num_cores

Returns the number of CPU cores in the specified Common::PowerStats.

=head3 num_cpus

Returns the number of CPUs in teh specified Common::PowerStats.

=head3 num_eth_ifs

Returns the number of Ethernet interfaces configured on teh specified Common::PowerStats.

=head3 num_fc_ifs

Returns the number of Fibre Channel interfaces configured on teh specified Common::PowerStats.

=head3 num_threads

Returns the number of execution threads available on the specified Common::PowerStats.

=head3 operability

Returns the operability status of the specified Common::PowerStats.

=head3 oper_power

Returns the operational power state of the specified Common::PowerStats.

=head3 oper_state

Returns the operational status of the specified Common::PowerStats.

=head3 presence

Returns the presence status of the specified Common::PowerStats.

=head3 power_stats

Returns a L<Cisco::UCS::Common::PowerStats> object representing the power usage
statistics of the specified Common::PowerStats.

=head3 revision

Returns the revision level of the specified Common::PowerStats.

=head3 serial

Returns the serial number of the specified Common::PowerStats.

=head3 server_id

Returns the ID of the specified Common::PowerStats in chassis/slot notation (e.g. this value would be 2/8
for a server in the eight slot of the second chassis).

=head3 slot_id

Returns the slot ID of the specified Common::PowerStats - this is the same value as returned by the I<id> method.

=head3 user_label

Returns the value for the user-specified label of the designated Common::PowerStats.

=head3 uuid

Returns the UUID of the specified Common::PowerStats - note that this UUID value is the user-specified value and may differ
to the original UUID value of the Common::PowerStats (see I<uuid_original>).

=head3 uuid_original

Returns the original UUID value of the specified Common::PowerStats - this value is the "burned-in" UUID for the Common::PowerStats.

=head3 vendor

Returns the vendor identifier of the specified Common::PowerStats.


=head1 AUTHOR

Luke Poskitt, C<< <ltp at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-cisco-ucs-Common::PowerStats at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Cisco-UCS-Common::PowerStats>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Cisco::UCS::Common::PowerStats


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Cisco-UCS-Common::PowerStats>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Cisco-UCS-Common::PowerStats>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Cisco-UCS-Common::PowerStats>

=item * Search CPAN

L<http://search.cpan.org/dist/Cisco-UCS-Common::PowerStats/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Luke Poskitt.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut
