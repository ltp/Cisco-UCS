package Cisco::UCS::Common::PowerStats;

use strict;
use warnings;

use Scalar::Util qw(weaken);

our $VERSION = '0.01';
our %V_MAP = (
	inputCurrent	=> 'input_current',
	inputCurrentMin => 'input_current_min',
	inputCurrentMax => 'input_cureent_max',
	consumedPower	=> 'consumed_power',
	timeCollected	=> 'time_collected',
	inputVoltageAvg	=> 'input_voltage_avg',
	inputVoltageMin	=> 'input_voltage_min',
	thresholded	=> 'thresholded',
	suspect		=> 'suspect',
	consumedPowerMin=> 'consumed_power_min',
	inputCurrentAvg	=> 'input_current_avg',
	consumedPowerMax=> 'consumed_power_max',
	inputVoltageMax	=> 'input_voltage_max',
	inputVoltage	=> 'input_voltage',
	consumedPowerAvg=> 'consumed_power_avg'
);

{ no strict 'refs';

	while ( my ($pseudo, $attribute) = each %V_MAP ) {
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
