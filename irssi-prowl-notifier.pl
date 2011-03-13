use strict;
use Crypt::SSLeay;
use WebService::Prowl;
use vars qw($VERSION %IRSSI);

use Irssi;
$VERSION = '0.2';
%IRSSI = (
	authors     => 'Nathan Chowning',
	contact     => 'nathanchowning@me.com',
	name        => 'irssi-prowl-notifier',
	description => 'Catches private messages and nick highlights and directs them to the Prowl API',
	url         => 'http://www.nathanchowning.com/projects/irssi-prowl-notifier',
	license     => 'GPL'
);

######
# Parts of this script are based on fnotify created by Thorsten Leemhuis
# http://www.leemhuis.info/files/fnotify/
######

######
# Private message parsing
######

sub private_msg {
	my ($server,$msg,$nick,$address,$target) = @_;
    return unless $server->{usermode_away} eq 1;
    prowlsend($nick,$msg);
}

######
# Sub to catch nick hilights
######

sub nick_hilight {
    my ($dest, $text, $stripped) = @_;
    if ($dest->{level} & MSGLEVEL_HILIGHT) {
	prowlsend($dest->{target}, $stripped);
    }
}

######
# Sub to send events to the prowl api
######

sub prowlsend {
    my(@smessage) = @_;
    my $apikey = '43aa85ee6ac8d9e0ad8e9940a122d2b513ff2019';
    my $ws = WebService::Prowl->new(apikey => $apikey);
    $ws->verify || die $ws->error();
    $ws->add(application => "irssi",
        event => @smessage[0],
        description => @smessage[1],
        url => "")
}

######
# Irssi::signal_add_last / Irssi::command_bind
######

Irssi::signal_add_last("message private", "private_msg");
Irssi::signal_add_last("print text", "nick_hilight");
