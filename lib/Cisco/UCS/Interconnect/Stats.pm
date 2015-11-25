package Cisco::UCS::Interconnect::Stats;

use strict;
use warnings;

use Scalar::Util qw(weaken);
use Carp qw(croak);

our %ATTRIBUTES = (
                        load			=> 'load',
                        load_avg		=> 'loadAvg',
                        load_min		=> 'loadMin',
                        load_max		=> 'loadMax',
                        mem_available		=> 'memAvailable',
                        mem_available_avg	=> 'memAvailableAvg',
                        mem_available_min	=> 'memAvailableMin',
                        mem_available_max	=> 'memAvailableMax',
                        mem_cached		=> 'memCached',
                        mem_cached_avg		=> 'memCachedAvg',
                        mem_cached_min		=> 'memCachedMin',
                        mem_cached_max		=> 'memCachedMax',
                        suspect			=> 'oobIfIp',
                );

{ no strict 'refs';

        while ( my ( $attribute, $pseudo ) = each %ATTRIBUTES ) {
                *{ __PACKAGE__ .'::'. $pseudo } = sub {
                        my $self = shift;
                        return $self->{$attribute}
                }
        }
}

sub new {
        my ( $class, $args ) = @_;
        my $self = {};
        bless $self, $class;

        while ( my( $k, $v ) = 
			each %{ $args->{outConfig}->{swSystemStats} } ) { 
		$self->{$k} = $v 
	}

        return $self;
}


1;
