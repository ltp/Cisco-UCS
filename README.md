Cisco::UCS - A Perl interface to the Cisco UCS XML API
------------------------------------------------------

SYNOPSIS
--------

    use Cisco::UCS;

    # Connect to our UCS cluster
    my $ucs = Cisco::UCS->new (
                            cluster         => $cluster, 
                            username        => $username,
                            passwd          => $password
                            );

    $ucs->login();

    # Retrieve all unacknowledged errors with a severity of critical
    @errors = $ucs->get_errors(severity=>"critical",ack="no");

    # And print them out
    foreach my $error_id (@errors) {
            my %this_error = $ucs->get_error_id($error_id);
            print "Error ID: $error_id.  Severity: $this_error{severity}.  Description: $this_error{descr}\n";
    }

    # Print the serial number of fabric interconnect A
    print "Interconnect A serial : " . $ucs->interconnect(A)->serial . "\n";

    # Print the serial number of each chassis
    foreach my $chassis ($ucs->chassis) {
            print "Chassis " . $chassis->id . " serial : " . $chassis->serial . "\n"
    }

    # prints:
    # "Chassis 1 serial : ABC1234"
    # "Chassis 2 serial : ABC1235"
    # etc.

    # Print the total transmitted bytes of Ethernet port 1/1/ on fabric interconnect A
    print "Interconnect A Ethernet 1/1 TX bytes: " . $ucs->interconnect(A)->card(1)->eth_port(1)->tx_total_bytes . "\n";

    # prints "Interconnect A Ethernet 1/1 TX bytes: 83462486"

    # Close our session
    $ucs->logout();

DESCRIPTION
-----------
This package provides an interface to the Cisco UCS Manager XML API and
Cisco UCS Management Information Model.

The Cisco UCS Manager (UCSM) is an embedded software agent providing
access to the hardware and configuration management features of attached
Cisco UCS hardware. The Management Information Model for the UCSM is
organised into a structured heirachy of both physical and virtual
objects. Accessing objects within the heirachy is done through a number
of high level calls to heirachy search and traversal methods.

The primary aim of this package is to provide a simplified and abstract
interface to this management heirachy.

METHODS
-------
* new ( CLUSTER, PORT, PROTO, USERNAME, PASSWORD )


        my $ucs = Cisco::UCS->new ( cluster         => $cluster, 
                                    port            => $port,
                                    proto           => $proto,
                                    username        => $username,
                                    passwd          => $passwd
                                   );

Constructor. Creates a new Cisco::UCS object representing a
connection to the Cisco UCSM XML API.

Parameters are:

    * cluster
The common name of the target cluster. This name should be resolvable
on the host from which the script is run.

    * username
The username to use for the connection. This username needs to have
the correct permission and access for the operations that one intends
to perform

    * passwd
The plaintext password of the username specified for the username
attribute for the connection.

    * port
The port on which to connect to the UCSM XML API on the target
cluster. This parameter is optional and will default to 443 if not
provided.

    * proto
The protocol with which to connect to the UCSM XML API on the target
cluster. This value is optional hould be one of 'http' or 'https' and
will default to 'https' if not provided.

* login ()


        $ucs->login;
        print "Authentication token is $ucs->cookie\n";

Creates a connection to the XML API interface of a USCM management
instance. If sucessful, the attributes of the UCSM management instance
are inherited by the object. Most important of these parameters is
'cookie' representing the authetication token that uniquely identifies
the connection and which is subsequently passed transparently on all
further communications.

The default time-out value for a token is 10 minutes, therefore if you
intend to create a long-running session you should periodically call
refresh.

* refresh ()


        $ucs->refresh;

Resets the expiry time limit of the existing authentication token to the
default timeout period of 10m. Usually not necessary for short-lived
connections.

* logout ()


        $ucs->logout;

Expires the current authentication token. This method should always be
called on completion of a script to expire the authentication token and
free the current session for use by others. The UCS XML API has a
maximum number of available connections, and a maximum number of
sessions per user. In order to ensure that the session remain available
(especially if using common credentials), you should always call this
method on completion of a script, as an argument to die, or in any eval
where a script may fail and exit before logging out;

* cookie ()


        print $ucs->cookie;

Returns the value of the authentication token.

* cluster ()


        print $ucs->cluster;

Returns the value of cluster as given in the constructor.

* dn ()


        print $ucs->dn;

Returns the distinguished name that specifies the base scope of the
Cisco::UCS object.

* get_error_id ( $ID )


        my %error = $ucs->get_error_id($id);
    
        while (my($key,$value) = each %error) {
            print "$key:\t$value\n";
        }

This method is deprecated, please use the equivalent get_error method.

Returns a hash containing the UCSM event detail for the given error id.
This method takes a single argument; the UCSM error_id of the desired
error.

* error ( $id )
 

        my $error = $ucs->get_error($id);
        print $error->id . ":" . $error->desc . "\n";

Returns a Cisco::UCS::Fault object representing the specified error.
Note that this is a caching method and will return a cached object that
has been retrieved on previous queries should on be available.

If you require a fresh object, consider using the equivalent non-caching
get_error method below.

* get_error ( $ID )

Returns a Cisco::UCS::Fault object representing the specified error.
Note that this is a non-caching method and that the UCSM will always be
queried for information. Consequently this method may be more expensive
than the equivalent caching method error described above.

* get_errors ()

        map {
                print '-'x50,"\n";
                print "ID               : " . $_->id . "\n";
                print "Severity         : " . $_->severity . "\n";
                print "Description      : " . $_->description . "\n";
        } grep {
                $_->severity !~ /cleared/i;
        } $ucs->get_errors;

Returns an array of Cisco::UCS::Fault objects with each object
representative of a fault on the target system.

* resolve_class ( %ARGS )

This method is used to retrieve objects from the UCSM management
heirachy by resolving the classId for specific object types. This method
reflects one of the base methods provided by the UCS XML API for
resolution of objects. The method returns an XML::Simple parsed object
from the UCSM containing the response.

This method accepts a hash containing the value of the classID to be
resolved and Unless you have read the UCS XML API Guide and are certain
that you know what you want to do, you shouldn't need to alter this
method.

* resolve_classes ( %ARGS )

This method is used to retrieve objects from the UCSM management
heirachy by resolving several classIds for specific object types. This
method reflects one of the base methods provided by the UCS XML API for
resolution of objects. The method returns an XML::Simple object from the
UCSM containing the parsed response.

Unless you have read the UCS XML API Guide and are certain that you know
what you want to do, you shouldn't need to alter this method.

* resolve_dn ( %ARGS )


        my $blade = $ucs->resolve_dn( dn => 'sys/chassis-1/blade-2');

This method is used to retrieve objects from the UCSM management
heirachy by resolving a specific distinguished name (dn) for a managed
object. This method reflects one of the base methods provided by the UCS
XML API for resolution of objects. The method returns an XML::Simple
parsed object from the UCSM containing the response.

The method accepts a single key/value pair, with the value being the
distinguished name of the object. If not known, the dn can be usually be
retrieved by first using one of the other methods to retrieve a list of
all object types (i.e. get_blades) and then enumerating the results to
extract the dn from the desired object.

    my @blades = $ucs->get_blades;

    foreach my $blade in (@blades) {
        print "Dn is $blade->dn\n";
    }

Unless you have read the UCS XML API Guide and are certain that you know
what you want to do, you shouldn't need to alter this method.

* resolve_children ( %ARGS )


    use Data::Dumper;

    my $children = $ucs->resolve_children(dn => 'sys');
    print Dumper($children);

This method is used to resolve all child objects for a given
distinguished named (dn) object in the UCSM management heirachy. This
method reflects one of the base methods provided by the UCS XML API for
resolution of objects. The method returns an XML::Simple parsed object
from the UCSM containing the response.

In combination with Data::Dumper this is an extremely useful method for
further development by enumerating the child objects of the specified
dn. Note however, that the response returned from UCSM may not always
accurately reflect all elements due to folding.

Unless you have read the UCS XML API Guide and are certain that you know
what you want to do, you shouldn't need to alter this method.

* resolve_class_filter ( %ARGS )


    my $associated_servers = $ucs->resolve_class_filter(    classId         => 'computeBlade',
                                                            association     => 'associatied'        );

This method is used to retrieve objects from the UCSM management
heirachy by resolving the classId for specific object types matching a
specified filter composed of any number of key/value pairs that
correlate to object attributes.

This method is very similar to the resolve_class method, however a
filter can be specified to restrict the objects returned to those having
certain characteristics. This method is largely exploited by subclasses
to return specific object types.

The filter is to be specified as any number of name/value pairs in
addition to the classId parameter.

* get_cluster_status ()


    my $status = $ucs->get_cluster_status;

This method returns an anonymous hash representing a brief overall
cluster status. In the standard configuration of a HA pair of Fabric
Interconnects, this status is representative of the cluster as a single
managed entity.

* version ()


    my $version = $ucs->version;

This method returns a string containign the running UCSM software
version.

* mgmt_entity ( $id )


    print "HA status : " . $ucs->mgmt_entity(A)->ha_readiness . "\n";
    
    my $mgmt_entity = $ucs->mgmt_entity('B');
    print $mgmt_entity->leadership;

Returns a Cisco::UCS::MgmtEntity object for the specified management
instance (either 'A' or 'B').

This is a caching method and will return a cached copy of a previously
retrieved Cisco::UCS::MgmtEntity object should one be available. i If
you require a fresh copy of the object then consider using the
get_mgmt_entity method below.

Please see the Caching Methods section in NOTES for further information.

* get_mgmt_entity ( $id )


    print "Management services state : " . $ucs->get_mgmt_entity(A)->mgmt_services_state . "\n";

Returns a Cisco::UCS::MgmtEntity object for the specified management
instance (either 'A' or 'B').

This method always queries the UCSM for information on the specified
management entity - consequently this method may be more expensive that
the equivalent caching method *get_mgmt_entity*.

Please see the Caching Methods section in NOTES for further information.

* get_mgmt_entities ()

 
    my @mgmt_entities = $ucs->get_mgmt_entities;

    foreach $entity (@mgmt_entities) {
        print "Management entity " . $entity->id . " is the " . $entity->leadership . " entity\n";
    }

Returns an array of Cisco::UCS::MgmtEntity objects representing all
management entities in the cluster (usually two - 'A' and 'B').

* get_primary_mgmt_entity ()


    my $primary = $ucs->get_primary_mgmt_entity;
    print "Management entity $entity->{id} is primary\n";

Returns an anonymous hash containing information on the primary UCSM
management entity object. This is the active managing instance of UCSM
in the target cluster.

* get_subordinate_mgmt_entity ()


    print 'Management entity ', $ucs->get_subordinate_mgmt_entity->{id}, ' is the subordinate management entity in cluster ',$ucs->{cluster},"\n";

Returns an anonymous hash containing information on the subordinate UCSM
management entity object.

* service_profile ( $ID )

Returns a Cisco::UCS::ServiceProfile object where $ID is the
user-specified name of the service profile.

This is a caching method and will return a cached copy of a previously
retrieved Cisco::UCS::ServiceProfile object should one be available. i
If you require a fresh copy of the object then consider using the
get_service_profile method below.

Please see the Caching Methods section in NOTES for further information.

* get_service_profile ( $ID )

Returns a Cisco::UCS::ServiceProfile object where $ID is the
user-specified name of the service profile.

This method always queries the UCSM for information on the specified
service profile - consequently this method may be more expensive that
the equivalent caching method *service_profile*.

Please see the Caching Methods section in NOTES for further information.

* get_service_profiles ()


    my @service_profiles = $ucs->get_service_profiles;

    foreach my $service_profile (@service_profiles) {
        print "Service Profile: " . $service_profile->name 
        . " associated to blade: " . $service_profile->pnDn 
        . "\n";
    }

Returns an array of Cisco::UCS::ServiceProfile objects representing all
service profiles currently present on the target UCS cluster.

* interconnect ( $ID )


    my $serial = $ucs->interconnect(A)->serial;

    print "Interconnect $_ serial: " . $ucs->interconnect($_) . "\n" for qw(A B);

Returns a Cisco::UCS::Interconnect object for the specified interconnect
ID (either A or B).

Note that the default behaviour of this method is to return a cached
copy of a previously retrieved Cisco::UCS::Interconnect object if one is
available. Please see the Caching Methods section in NOTES for further
information.

* get_interconnect ( $ID )


    my $interconnect = $ucs->get_interconnect(A);

    print $interconnect->model;

Returns a Cisco::UCS::Interconnect object for the specified interconnect
ID (either A or B).

This method always queries the UCSM for information on the specified
interconnect - contrast this with the behaviour of the caching method
*interconnect()*.

Please see the Caching Methods section in NOTES for further information.

* get_interconnects ()


    my @interconnects = $ucs->get_interconnects;

    foreach my $ic (@interconnects) {
        print "Interconnect $ic->id operability is $ic->operability\n";
    }

Returns an array of Cisco::UCS::Interconnect objects. This is a
non-caching method.

* blade ( $ID )


    print "Blade 1/1 serial : " . $ucs->blade('1/1')->serial .. "\n;

Returns a Cisco::UCS::Blade object representing the specified blade as
given by the value of $ID. The blade ID should be given using the
standard Cisco UCS blade identification form as used in the UCSM CLI;
namely chassis_id/blade_id where both chassis_id and blade_id are valid
numerical values for the target cluster. Note that you will have to
enclose the value of $ID in quotation marks to avoid a syntax error.

Note that this is a caching method and the default behaviour of this
method is to return a cached copy of a previously retrieved
Cisco::UCS::Blade object if one is available. If a non-cached object is
required, then please consider using the equivalent get_blade method
below.

Please see the Caching Methods section in NOTES for further information.

* get_blade ( $ID )


    print "Blade 1/1 serial : " . $ucs->get_blade('1/1')->serial .. "\n;

Returns a Cisco::UCS::Blade object representing the specified blade as
given by the value of $ID. The blade ID should be given using the
standard Cisco UCS blade identification form as used in the UCSM CLI;
namely chassis_id/blade_id where both chassis_id and blade_id are valid
numerical values for the target cluster. Note that you will have to
enclose the value of $ID in quotation marks to avoid a syntax error.

Note that this method is non-caching and always queries the UCSM for
information. Consequently may be more expensive than the equivalent
caching blade method described above.

* get_blades ()


    my @blades = $ucs->get_blades();

    foreach my $blade (@blades) {
        print "Model: $blade->{model}\n";
    }

Returns an array of Cisco::UCS::Blade objects with each object
representing a blade within the UCS cluster.

* chassis ( $ID )

    
    my $chassis = $ucs->chassis(1);
    print "Chassis 1 serial : " . $chassis->serial . "\n";
    # or
    print "Chassis 1 serial : " . $ucs->chassis(1)->serial . "\n";

    foreach my $psu ( $ucs->chassis(1)->get_psus ) {
        print $psu->id . " thermal : " . $psu->thermal . "\n"
    }

Returns a Cisco::UCS::Chassis object representing the chassis identified
by by the specified value of ID.

Note that this is a caching method and the default behaviour of this
method is to return a cached copy of a previously retrieved
Cisco::UCS::Chassis object if one is available. If a non-cached object
is required, then please consider using the equivalent get_chassis
method below.

Please see the Caching Methods section in NOTES for further information.

* get_chassis ( $ID )
    
    my $chassis = $ucs->get_chassis(1);
    print "Chassis 1 label : " . $chassis->label . "\n";
    # or
    print "Chassis 1 label : " . $ucs->get_chassis(1)->label . "\n";

Returns a Cisco::UCS::Chassis object representing the chassis identified
by by the specified value of ID.

Note that this method is non-caching and always queries the UCSM for
information. Consequently may be more expensive than the equivalent
caching chassis method described above.

* get_chassiss
    

    my @chassis = $ucs->get_chassiss();

    foreach my $chassis (@chassis) {
        print "Chassis $chassis->{id} serial number: $chassis->{serial}\n";
    }

Returns an array of Cisco::UCS::Chassis objects representing all chassis
present within the cluster.

Note that this method is named get_chassiss (spelt with two sets of
double-s's) as there exists no English language collective plural for
the word chassis.

* full_state_backup
This method generates a new "full state" type backup for the target UCS
cluster. Internally, this method is implemented as a wrapper method
around the private backup method. Required parameters for this method:

    * backup_proto
The protocol to use for transferring the backup from the target UCS
cluster to the backup host. Must be one of: ftp, tftp, scp or sftp.

    * backup_host
The host to which the backup will be transferred.

    * backup_target
The fully qualified name of the file to which the backup is to be
saved on the backup host. This should include the full directory path
and the target filename.

    * backup_username
The username to be used for creation of the backup file on the backup
host. This username should have write/modify file system access to
the backup target location on the backup host using the protocol
specified in the backup-proto attribute.

    * backup_passwd
The plaintext password of the user specified for the backup_username
attribute.

    * all_config_backup
This method generates a new "all configuration" backup for the target
UCS cluster. Internally, this method is implemented as a wrapper method
around the private backup method. For the required parameters for this
method, please refer to the documentation of the full_state_backup
method.

    * system_config_backup
This method generates a new "system configuration" backup for the target
UCS cluster. Internally, this method is implemented as a wrapper method
around the private backup method. For the required parameters for this
method, please refer to the documentation of the full_state_backup
method.

    * logical_config_backup
This method generates a new "logical configuration" backup for the
target UCS cluster. Internally, this method is implemented as a wrapper
method around the private backup method. For the required parameters for
this method, please refer to the documentation of the full_state_backup
method.

NOTES
-----

* Caching Methods

Several methods in the module return cached objects that have been
previously retrieved by querying UCSM, this is done to improve the
performance of methods where a cached copy is satisfactory for the
intended purpose. The trade off for the speed and lower resource
requirement is that the cached copy is not guaranteed to be an
up-to-date representation of the current state of the object.

As a matter of convention, all caching methods are named after the
singular object (i.e. interconnect(), chassis()) whilst non-caching
methods are named *get_<object*>. Non-caching methods will always query
UCSM for the object, as will requests for cached objects not present in
cache.

*  The documentation could be cleaner and more thorough. The module was
written some time ago with only minor amounts of time and effort
invested since. There's still a vast opportunity for improvement.

*  etter error detection and handling. Liberal use of Carp::croak
should ensure that we get some minimal diagnostics and die nicely,
and if used according to instructions, things should generally work.
When they don't however, it would be nice to know why.

* Detection of request and return type. Most of the methods are fairly
explanatory in what they return, however it would be nice to make
better use of wantarray to detect what the user wants and handle it
accordingly.

* Clean up of the UCS package to remove unused methods and improve the
ones that we keep. I'm still split on leaving some of the methods
common to most object type (fans, psus) in the main package.

AUTHOR
------

Luke Poskitt, "<ltp at cpan.org>"

BUGS
----

Please report any bugs or feature requests to "bug-cisco-ucs at
rt.cpan.org", or through the web interface at
<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Cisco-UCS>. I will be
notified, and then you'll automatically be notified of progress on your
bug as I make changes.

SUPPORT
-------
You can find documentation for this module with the perldoc command.

    perldoc Cisco::UCS

You can also look for information at:

*   RT: CPAN's request tracker

    <http://rt.cpan.org/NoAuth/Bugs.html?Dist=Cisco-UCS>

*   AnnoCPAN: Annotated CPAN documentation

    <http://annocpan.org/dist/Cisco-UCS>

*   CPAN Ratings

    <http://cpanratings.perl.org/d/Cisco-UCS>

*   Search CPAN

    <http://search.cpan.org/dist/Cisco-UCS/>

LICENSE AND COPYRIGHT
---------------------

Copyright 2014 Luke Poskitt.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

