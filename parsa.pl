#!/usr/bin/env perl
use v5.36;

use Cpanel::JSON::XS;
use Web::Scraper;
use Web::Scraper::LibXML;

sub main($dir) {
    state $json = Cpanel::JSON::XS->new->canonical->utf8->pretty;
    state $scraper = scraper {
        process '//link[@rel="canonical"]', url => '@href';
        process '//title', title => 'text';
        process '//div[@id="infobox"]//h2', name => 'text';
        process '//div[@id="breadcrumbs-container"]/a', 'type[]' => 'text';
    };

    my %items;
    opendir(my $dh, $dir) || die "can't open $dir: $!";
    while (my $file = readdir($dh)) {
        $file = "${dir}/${file}";
        next unless -f $file;

        open(my $fh, '<:encoding(UTF-8)', $file) || die "can't open $file: $!";
        my $body = do { local $/; <$fh> };
        close $fh;

        my $doc = $scraper->scrape($body);

        $doc->{title} =~ s{ \s* \| .+ $}{}x;
        s{^ \s+ | \s+ $}{}gx for $doc->{type}->@*;

        my $key = fc $doc->{title};
        $items{$key} = $doc;
    }
    closedir $dh;

    say $json->encode(\%items);
    return 0;
}

exit main('wiki');
