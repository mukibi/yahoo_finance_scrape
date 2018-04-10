#!/usr/bin/perl

use strict;
use warnings;

use LWP::UserAgent;

my $ua = LWP::UserAgent->new();
$ua->timeout(10);
$ua->ssl_opts( verify_hostname => 0 ,SSL_verify_mode => 0x00);


open(my $f, ">meta.csv");

for my $id (1..10000) {

	print $id,$/;
	my $response = $ua->head("https://www.nse.co.ke/%20index.php?option=com_phocadownload&view=category&download=$id");

	if ( $response->is_success ) {

		my $content_disposition = $response->header("Content-Disposition");
		my $f_name = "N/A";

		if (defined $content_disposition) {

			if ($content_disposition =~ /filename="([^"]+)"/) {
				$f_name = $1;
			}

		}

		print $f "$id,$f_name", $/;

	}

	else {
		print STDERR $id, ": ", $response->status_line(), $/;
	}

}
