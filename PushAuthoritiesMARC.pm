#!/usr/bin/perl
#
# This perltidy formatter configuration should be used if formatting in vim:
#
# filetype plugin indent on
# autocmd FileType perl setlocal equalprg=perltidy\ -st\ -l=160\ -i=2
#
# Vim document format Keys combo: gg=G

use strict;
use warnings;
use YAML::XS 'LoadFile';

use Net::Z3950::ZOOM;

my $cfg = LoadFile('cfg.yaml');

my $beVerbose = $cfg->{beVerbose};

my $server = $cfg->{server};
my $port   = $cfg->{port};

my $user                     = $cfg->{user};
my $group                    = $cfg->{group};
my $pw                       = $cfg->{pw};
my $dbName                   = $cfg->{dbName};
my $charset                  = $cfg->{charset};
my $authenticationMode       = $cfg->{authenticationMode};
my $targetImplementationName = $cfg->{targetImplementationName};
my $sru                      = $cfg->{sru};
my $init_opt_search          = $cfg->{init_opt_search};

my $opacFrom          = $cfg->{opacFrom};
my $recordFormat      = $cfg->{recordFormat};
my $recordCharsetFrom = $cfg->{recordCharsetFrom};
my $recordCharsetInto = $cfg->{recordCharsetInto};

my $debug    = $cfg->{debug};
my $apdulog  = $debug;
my $saveAPDU = $debug;

# Connect ..
my $conn = Net::Z3950::ZOOM::connection_new( $server, $port );
checkError($conn);

# Set connection options now ..
Net::Z3950::ZOOM::connection_option_set( $conn, user                     => $user );
Net::Z3950::ZOOM::connection_option_set( $conn, group                    => $group );
Net::Z3950::ZOOM::connection_option_set( $conn, password                 => $pw );
Net::Z3950::ZOOM::connection_option_set( $conn, databaseName             => $dbName );
Net::Z3950::ZOOM::connection_option_set( $conn, charset                  => $charset );
Net::Z3950::ZOOM::connection_option_set( $conn, authenticationMode       => $authenticationMode );
Net::Z3950::ZOOM::connection_option_set( $conn, targetImplementationName => $targetImplementationName );
Net::Z3950::ZOOM::connection_option_set( $conn, init_opt_search          => $init_opt_search );
Net::Z3950::ZOOM::connection_option_set( $conn, sru                      => $sru );
Net::Z3950::ZOOM::connection_option_set( $conn, apdulog                  => $apdulog );
Net::Z3950::ZOOM::connection_option_set( $conn, saveAPDU                 => $saveAPDU );

#$query = Net::Z3950::ZOOM::query_create();
#Net::Z3950::ZOOM::query_destroy($query);

my $countOfResultSet      = "10";
my $preferredRecordSyntax = "USMARC";
my $searchQuery           = "Karel";

my $resultSet = Net::Z3950::ZOOM::connection_search_pqf( $conn, $searchQuery );
checkError($conn);

Net::Z3950::ZOOM::resultset_option_set( $resultSet, preferredRecordSyntax => $preferredRecordSyntax );
Net::Z3950::ZOOM::resultset_option_set( $resultSet, count => $countOfResultSet );
my $resultsNo = Net::Z3950::ZOOM::resultset_size($resultSet);

if ($resultsNo) {
  print "$resultsNo result/s found for query $searchQuery\n";
  my $record = Net::Z3950::ZOOM::resultset_record( $resultSet, 0 );
  checkRecordError($record);

  my $type = $recordFormat;
  if ($recordCharsetFrom) {
    $type .= "; charset=$recordCharsetFrom";

    if ($opacFrom) {
      $type .= "/$opacFrom";
    }

    if ($recordCharsetInto) {
      $type .= ",$recordCharsetInto";
    }
  }

  my $recordRaw = Net::Z3950::ZOOM::record_get( $record, $type, 0 );

  print "Record in raw format:\n$recordRaw\n";
  print "Record type: $type\n";

  Net::Z3950::ZOOM::record_destroy($record);
}
elsif ($beVerbose) {
  print "No result found for query $searchQuery\n";
}

Net::Z3950::ZOOM::resultset_destroy($resultSet);
Net::Z3950::ZOOM::connection_destroy($conn);

=head2 checkError($conn)

	The syntax in checkError($conn)

	It prints on STDOUT an error message if the last executed command has any error ...

=cut

my $errCheckNo = 0;

sub checkError {
  my ($conn) = @_;

  ++$errCheckNo;

  my $errmsg  = "";
  my $addinfo = "";
  my $errcode = Net::Z3950::ZOOM::connection_error( $conn, $errmsg, $addinfo );
  if ( $errcode != 0 ) {
    print "ERROR:\n";
    print "$errmsg\n";
    print "$addinfo\n";
    print "Traceback: ErrCheckNo: $errCheckNo\n";
    if ( $debug == 1 ) {
      my $logs = Net::Z3950::ZOOM::connection_option_get( $conn, 'APDU' );
      if ($logs) {
        print "Logs available: $logs\n";
      }
    }
  }
}

=head2 checkRecordError($record)

	Same as checkError($conn) but for $record

=cut

my $recErrCheckNo = 0;

sub checkRecordError {
  my ($record) = @_;

  ++$recErrCheckNo;

  my $errmsg  = "";
  my $addinfo = "";
  my $diagset = "";
  my $errcode = Net::Z3950::ZOOM::record_error( $record, $errmsg, $addinfo, $diagset );
  if ( $errcode != 0 ) {
    print "RECORD_ERROR:\n";
    print "$errmsg\n";
    print "$addinfo\n";
    print "$diagset\n";
    print "Traceback: RecErrCheckNo: $recErrCheckNo\n";
  }
}

1;
