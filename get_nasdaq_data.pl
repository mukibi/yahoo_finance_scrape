#!/usr/bin/perl

use strict;
use warnings;

use LWP::UserAgent;
use HTTP::Cookies;

opendir (my $dir_h, ".");
my @files = readdir($dir_h);

my %companies = ();

open (my $f, "<companies2.csv");

while (<$f>) {

	chomp;
	my @bts = split/,/,$_;

	my $symbol = $bts[0];
	my $market_cap = $bts[1];

	$companies{$symbol} = $market_cap;
} 

for my $file (@files) {

	if ( $file =~ /^(.*)\.csv$/ ) {
		my $sym = $1;
		delete $companies{$sym};
	}

}

my $cookies_jar = HTTP::Cookies->new();
my @cookies = (
"DSS|ts=1470822494&cnt=0&sdts=1491854944&sdtp=mozilla|/|.yahoo.com",
"B|85o7gd9cf9b07&b=3&s=31|/|.yahoo.co.jp",
"BX|eksgml1br3flq&b=3&s=k7|/|.yahooapis.com",
"PRF|t%3DCSV|/|.finance.yahoo.com",
"B|eksgml1br3flq&b=3&s=k7|/|.yahoo.com"
);

for my $cookie (@cookies) {

	my @bts = split/\|/, $cookie;
	$cookies_jar->set_cookie(1, $bts[0], $bts[1], $bts[2], $bts[3], "443", 1, 1, 3600, 0, {}); 
}

my $ua = LWP::UserAgent->new();
$ua->timeout(10);

my $fails = 0;

for my $company (sort { $companies{$b} <=>  $companies{$a} } keys %companies) {

	
	$ua->cookie_jar($cookies_jar);
	
	my $url = "https://query1.finance.yahoo.com/v7/finance/download/$company?period1=1198489336&period2=1513849336&interval=1d&events=history&crumb=LnG3KlrTDRC";
		
	my $response = $ua->get($url);
		
	if ($response->is_success) {

		open (my $csv_f, ">$company.csv");

		my $content = $response->decoded_content();
		print $csv_f $content;
	
	}
	
	else {

		if (++$fails < 4) {
			redo;
		}
		else {
			$fails = 0;
		}

		print STDERR $response->status_line();
	}

	#last;
}
