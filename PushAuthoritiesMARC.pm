#!/usr/bin/perl
#
# This Perl script is written with respect to ZOOM YAZ C++ API:
# http://www.indexdata.com/yaz/doc/zoom.extendedservices.html
#
# This perltidy formatter configuration should be used if formatting in vim:
#
# filetype plugin indent on
# autocmd FileType perl setlocal equalprg=perltidy\ -st\ -l=160\ -i=2
#
# Vim document format Keys combo: gg=G

use strict;
use warnings;
use Curses;
use YAML::XS 'LoadFile';

use Net::Z3950::ZOOM;

my $errorcode;
my $cfg = LoadFile('cfg.yaml');

my $beVerbose = $cfg->{beVerbose};
my $debug     = $cfg->{debug};

my $conn = createConnection($cfg);

# Packaging ..
my $package = createPackage($cfg);

my $sendTypeUpdate = 'update';
my $sendTypeCommit = 'commit';

printDebug("Sending first package ..");

Net::Z3950::ZOOM::package_send( $package, $sendTypeUpdate );
checkError( $conn, "Could not send package" );

if ( $errorcode == 0 ) {
  printDebug("Package has been successfully sent :)");
}
elsif ( $errorcode == 9999 ) {
  printDebug("Could not send first package .. creating new connection");
  Net::Z3950::ZOOM::connection_destroy($conn);

  $conn = createConnection($cfg);

  print "Press ENTER to attempt to send the package over new connection ..\n";
  $btn = <STDIN>;

  Net::Z3950::ZOOM::package_send( $package, $sendTypeUpdate );
  checkError( $conn, "Could not send package" );
}

my $result = Net::Z3950::ZOOM::package_option_get( $package, 'targetReference' );

if ( defined $result ) {
  print "The result is:\n $result";
}
Net::Z3950::ZOOM::package_destroy($package);
Net::Z3950::ZOOM::connection_destroy($conn);

=head2 checkError($conn)

	The syntax in checkError($conn)

	It prints on STDOUT an error message if the last executed command has any error ...

=cut

sub checkError {
  my ( $conn, $msg ) = @_;

  my $errmsg  = "";
  my $addinfo = "";
  my $dset    = "";

  $errorcode = Net::Z3950::ZOOM::connection_error_x( $conn, $errmsg, $addinfo, $dset );

  if ( $errorcode != 0 ) {

    print "ERROR with code $errorcode:\n";

    my $isUnknownErr = $errmsg eq "Unknown error";

    if ( $isUnknownErr and defined $msg ) {
      print "$msg:\n";
    }
    else {
      print "$errmsg";
      if ( defined $msg ) {
        print " ($msg)";
      }
      print ":\n";
    }
    print "$addinfo\n";
    if ( defined $debug and $debug == 1 ) {
      my $apdu = Net::Z3950::ZOOM::connection_option_get( $conn, 'APDU' );
      if ($apdu) {
        print "Traceback:\n";
        print "Logs available: \n$apdu\n";
      }
    }
    print "\n";
    if ($debug) {
      print "dset: $dset\n";

    }
  }
}

=head2 createConnection()

=cut

sub createConnection {
  my ($cfg) = @_;

  my $server = $cfg->{server};
  my $port   = $cfg->{port};

  unless ( defined $server and defined $port ) {
    print "You have to define server & port first!\n";
    exit 1;
  }

  my $databaseName = $cfg->{dbName};
  unless ($databaseName) {
    print "Cannot place query on unknown database .. please specify dbName!\n";
    exit 1;
  }

  my $user                     = $cfg->{user};
  my $group                    = $cfg->{group};
  my $password                 = $cfg->{pw};
  my $charset                  = $cfg->{charset};
  my $authenticationMode       = $cfg->{authenticationMode};
  my $targetImplementationName = $cfg->{targetImplementationName};
  my $implementationVersion    = $cfg->{implementationVersion};
  my $implementationName       = $cfg->{implementationName};
  my $sru                      = $cfg->{sru};
  my $sru_version              = $cfg->{sruVersion};
  my $init_opt_search          = $cfg->{init_opt_search};

  my $opacFrom          = $cfg->{opacFrom};
  my $recordFormat      = $cfg->{recordFormat};
  my $recordCharsetFrom = $cfg->{recordCharsetFrom};
  my $recordCharsetInto = $cfg->{recordCharsetInto};

  my $debug    = $cfg->{debug};
  my $apdulog  = $debug;
  my $saveAPDU = $debug;

  my $serverImplementationVersion = $cfg->{serverImplementationVersion};

  my $options = Net::Z3950::ZOOM::options_create();

  Net::Z3950::ZOOM::options_set( $options, user                        => $user )                        if defined $user;
  Net::Z3950::ZOOM::options_set( $options, group                       => $group )                       if defined $group;
  Net::Z3950::ZOOM::options_set( $options, password                    => $password )                    if defined $password;
  Net::Z3950::ZOOM::options_set( $options, databaseName                => $databaseName )                if defined $databaseName;
  Net::Z3950::ZOOM::options_set( $options, charset                     => $charset )                     if defined $charset;
  Net::Z3950::ZOOM::options_set( $options, authenticationMode          => $authenticationMode )          if defined $authenticationMode;
  Net::Z3950::ZOOM::options_set( $options, targetImplementationName    => $targetImplementationName )    if defined $targetImplementationName;
  Net::Z3950::ZOOM::options_set( $options, implementationName          => $implementationName )          if defined $implementationName;
  Net::Z3950::ZOOM::options_set( $options, init_opt_search             => $init_opt_search )             if defined $init_opt_search;
  Net::Z3950::ZOOM::options_set( $options, sru                         => $sru )                         if defined $sru;
  Net::Z3950::ZOOM::options_set( $options, sru_version                 => $sru_version )                 if defined $sru_version;
  Net::Z3950::ZOOM::options_set( $options, apdulog                     => $apdulog )                     if defined $apdulog;
  Net::Z3950::ZOOM::options_set( $options, saveAPDU                    => $saveAPDU )                    if defined $saveAPDU;
  Net::Z3950::ZOOM::options_set( $options, implementationVersion       => $implementationVersion )       if defined $implementationVersion;
  Net::Z3950::ZOOM::options_set( $options, serverImplementationVersion => $serverImplementationVersion ) if defined $serverImplementationVersion;

  printDebug("Trying to establish an connection to $server:$port");
  my $conn = Net::Z3950::ZOOM::connection_create($options);
  checkError( $conn, "Could not create ZOOM_connection object" );

  printDebug("Trying to establish an connection to $server:$port");
  Net::Z3950::ZOOM::connection_connect( $conn, $server, $port );
  checkError( $conn, "Could not establish connection to $server:$port" );

  return $conn;
}

=head2 createPackage($cfg)

=cut

sub createPackage {

  my ($cfg) = @_;

  my $packageName     = $cfg->{packageName};
  my $packageFunction = $cfg->{packageFunction};

  my $options = Net::Z3950::ZOOM::options_create();

  my $package = Net::Z3950::ZOOM::connection_package( $conn, $options );
  checkError( $conn, "Could not create ZOOM_package object" );

  # Set common package options ..
  Net::Z3950::ZOOM::package_option_set( $package, 'package-name' => $packageName )     if defined $packageName;
  Net::Z3950::ZOOM::package_option_set( $package, function       => $packageFunction ) if defined $packageFunction;

  # Set update package options ..
  my $action = $cfg->{recordUpdateAction};

  my $recordIdOpaque = $cfg->{recordIdOpaque};
  my $recordIdNumber = $cfg->{recordIdNumber};

  my $filename = $cfg->{fileToTest};

  open FILE, $filename or die "Couldn't open file: $!";
  my $record = join( "", <FILE> );
  close FILE;

  printDebug("Just loaded file $filename with contents:\n$record");

  my $syntax              = $cfg->{syntax};
  my $databaseName        = $cfg->{dbName};
  my $correlationInfoNote = $cfg->{correlationInfoNote};
  my $correlationInfoId   = $cfg->{correlationInfoId};
  my $elementSetName      = $cfg->{elementSetName};
  my $updateVersion       = $cfg->{updateVersion};

  Net::Z3950::ZOOM::package_option_set( $package, 'action'               => $action )              if defined $action;
  Net::Z3950::ZOOM::package_option_set( $package, 'recordIdOpaque'       => $recordIdOpaque )      if defined $recordIdOpaque;
  Net::Z3950::ZOOM::package_option_set( $package, 'recordIdNumber'       => $recordIdNumber )      if defined $recordIdNumber;
  Net::Z3950::ZOOM::package_option_set( $package, 'record'               => $record )              if defined $record;
  Net::Z3950::ZOOM::package_option_set( $package, 'syntax'               => $syntax )              if defined $syntax;
  Net::Z3950::ZOOM::package_option_set( $package, 'databaseName'         => $databaseName )        if defined $databaseName;
  Net::Z3950::ZOOM::package_option_set( $package, 'correlationInfo.note' => $correlationInfoNote ) if defined $correlationInfoNote;
  Net::Z3950::ZOOM::package_option_set( $package, 'correlationInfo.id'   => $correlationInfoId )   if defined $correlationInfoId;
  Net::Z3950::ZOOM::package_option_set( $package, 'elementSetName'       => $elementSetName )      if defined $elementSetName;
  Net::Z3950::ZOOM::package_option_set( $package, 'updateVersion'        => $updateVersion )       if defined $updateVersion;

  # Set empty targetReference ... here will be stored the result
  Net::Z3950::ZOOM::package_option_set( $package, 'targetReference' => "" );

  return $package;
}

=head2 printDebug($messageToPrint)

=cut

sub printDebug {
  my ($message) = @_;
  if ($debug) {
    print "DEBUG INFO: ";
    print "$message\n\n";
  }
}

1;
