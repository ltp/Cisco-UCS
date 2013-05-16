package Cisco::UCS::Blade::PowerBudget;

use strict;
use warnings;

use Cisco::UCS::Blade::PowerBudget;
use Scalar::Util qw(weaken);

our $VERSION = '0.01';
our %V_MAP = (
	adminCommitted	=> 'admin_commited',
	adminPeak	=> 'admin_peak',
	capAction	=> 'cap_action',
	catalogPower	=> 'catalog_power',
	currentPower	=> 'current_power',
	dn		=> 'dn',
	dynRealloc	=> 'dyn_reallocation',
	groupName	=> 'group_name',
	idlePower	=> 'idle_power',
	maxPower	=> 'max_power',
	minPower	=> 'min_power',
	operCommitted	=> 'oper_commited',
	operMin		=> 'oper_min',
	operPeak	=> 'oper_peak',
	operState	=> 'oper_state',
	prio		=> 'priority',
	psuCapacity	=> 'psu_capacity',
	psuState	=> 'psu_state',
	scaledWt	=> 'scaled_wt',
	style		=> 'style',
	updateTime	=> 'update_time',
	weight		=> 'weight',
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
