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

__END__

=head1 NAME

Cisco::UCS::Blade::PowerBudget - Class for operations with a Cisco UCS blade power budgets.

=cut

=head1 SYNOPSIS

        # Print all blades in all chassis along with the chassis current output power
        # and each blades current input power both in watts and as a percentage of
        # the chassis input power level.

        map { 
                my $c_power = $_->stats->output_power;
                printf( "Chassis: %d - Output power: %.3f\n", $_->id, $c_power );
                map {
                        printf( "\tBlade: %d - Input power: %.3f (%.2f%%)\n",
                        $_->id, $_->power_budget->current_power, 
                        ( $c_power == 0 ? '-' : ( $_->power_budget->current_power / $c_power * 100 ) ) ) 
                }   
                sort { $a->id <=> $b->id } $_->get_blades 
        } 
        sort { 
                $a->id <=> $b->id 
        } $ucs->get_chassiss;

        # E.g.
        #
        # Chassis: 1 - Output power: 704.000
        #       Blade: 1 - Input power: 119.000 (16.90%)
        #       Blade: 2 - Input power: 134.000 (19.03%)
        #       Blade: 3 - Input power: 135.000 (19.18%)
        #       Blade: 4 - Input power: 0.000 (0.00%)
        #       Blade: 5 - Input power: 0.000 (0.00%)
        #       Blade: 6 - Input power: 0.000 (0.00%)
        #       Blade: 7 - Input power: 0.000 (0.00%)
        #       Blade: 8 - Input power: 136.000 (19.32%)
        # Chassis: 2 - Output power: 1188.000
        #       Blade: 1 - Input power: 127.000 (10.69%)
        #       Blade: 2 - Input power: 0.000 (0.00%)
        #       Blade: 3 - Input power: 120.000 (10.10%)
        #       Blade: 4 - Input power: 0.000 (0.00%)
        #       Blade: 5 - Input power: 127.000 (10.69%)
        #       Blade: 6 - Input power: 121.000 (10.19%)
        #       Blade: 7 - Input power: 172.000 (14.48%)
        #       Blade: 8 - Input power: 136.000 (11.45%)
        # etc.

=head1 DECRIPTION

Cisco::UCS::Blade::PowerBudget is a class providing operations with a Cisco UCS blade power budget.

Note that you are not supposed to call the constructor yourself, rather a Cisco::UCS::Blade::PowerBudget object
is created automatically by method calls on a L<Cisco::UCS::Blade> object.

=cut

=head1 METHODS

=head3 admin_commited
=head3 admin_peak
=head3 cap_action
=head3 catalog_power
=head3 current_power
=head3 dn
=head3 dyn_reallocation
=head3 group_name
=head3 idle_power
=head3 max_power
=head3 min_power
=head3 oper_commited
=head3 oper_min
=head3 oper_peak
=head3 oper_state
=head3 priority
=head3 psu_capacity
=head3 psu_state
=head3 scaled_wt
=head3 style
=head3 update_time
=head3 weight

=head1 AUTHOR

Luke Poskitt, C<< <ltp at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-cisco-ucs-blade-powerbudget at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Cisco-UCS-Blade-PowerBudget>.  I will 
be notified, and then you'll automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Cisco::UCS::Blade::PowerBudget


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Cisco-UCS-Blade-PowerBudget>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Cisco-UCS-Blade-PowerBudget>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Cisco-UCS-Blade-PowerBudget>

=item * Search CPAN

L<http://search.cpan.org/dist/Cisco-UCS-Blade-PowerBudget/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2013 Luke Poskitt.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut
