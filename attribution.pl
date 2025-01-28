########################################
# Header ###############################
########################################

use strict;
use Irssi;
use vars qw($VERSION %IRSSI);
$VERSION = 'r2';
%IRSSI = (
    'name'        => 'attribution',
    'authors'     => 'Trilkk',
    'contact'     => 'trilkk ät iki.fi',
    'url'         => 'https://github.com/trilkk/irssi-attribution',
    'license'     => 'BSD',
    'description' => 'Extracts attribution from bridge bot messages into nicknames',
);

# Block for reacting to the same signal twice.
my $input_block = 0;

# Padding length for continuatio.
my $continuation_pad_length = 0;

########################################
# Functions ############################
########################################

# Gets the listing of attributors.
# \return List of attributors.
sub get_attributors
{
    my $attributors = Irssi::settings_get_str('attribution_attributors');
    $attributors =~ s/^\s+//;
    $attributors =~ s/\s+$//;
    return split /\s/, $attributors;
}

# Checks if given party is a legal attributor.
# \param 0 Nick to test.
# \return True if valid attributor, false otherwise.
sub is_attributor
{
    my $nick = $_[0];
    my @attributors = get_attributors();
    foreach my $ii (@attributors)
    {
        if($nick eq $ii)
        {
            return 1;
        }
    }
    return 0;
}

# Strip any unnecessary extra elements from a nickname.
# In practice, color codes and username indicators.
# \param 0 Input string.
# \return Input string without color codes.
sub strip_nick
{
    my $nick = $_[0];
    # Strip color codes.
    $nick =~ s/\cC\d+(,\d+)?//g;
    $nick =~ s/\cC//g;
    $nick =~ s/\cO//g;
    # Strip matrix user indicator.
    $nick =~ s/\s\(@\w+:\w+\.(\w+\.)+\w+\)//g;
    return $nick;
}

########################################
# Signals ##############################
########################################

# Modifies incoming messages to transfer attribution from message into nick.
# Does not return anything, but instead reissues a modified signal.
# \param 0 Server sturct.
# \param 1 Message.
# \param 2 Input nickname.
# \param 3 ???
# \param 4 ???
sub attribution_input
{
    if($input_block)
    {
        return;
    }

    my ($server, $msg, $nick, $param3, $param4) = @_;
    my $signal = Irssi::signal_get_emitted();

    if(is_attributor($nick))
    {
        $msg =~ /^(PRIVMSG\s#\S+\s:)<([^>]+)>\s+(.*)$/;
        my $modified = $1 . $3;
        my $extracted = strip_nick($2);

        # Someone is being attributed.
        if($modified && $extracted)
        {
            utf8::decode($extracted);
            $continuation_pad_length = length($extracted);
            my $indicator = Irssi::settings_get_str('attribution_indicator');
            utf8::decode($indicator);
            my $nick = $extracted . $indicator;
            utf8::encode($nick);
            $input_block = 1;
            Irssi::signal_emit($signal, $server, $modified, $nick, $param3, $param4);
            Irssi::signal_stop();
            $input_block = 0;
            return;
        }

        # Continuing from linefeed or the like.
        my $nick = "";
        utf8::decode($nick);
        my $continuation_pad = Irssi::settings_get_str('attribution_continuation_pad');
        utf8::decode($continuation_pad);
        if($continuation_pad)
        {
            while(length($nick) < $continuation_pad_length)
            {
                $nick .= $continuation_pad;
            }
        }
        my $continuation = Irssi::settings_get_str('attribution_continuation');
        utf8::decode($continuation);
        $nick .= $continuation;
        utf8::encode($nick);
        $input_block = 1;
        Irssi::signal_emit($signal, $server, $msg, $nick, $param3, $param4);
        Irssi::signal_stop();
        $input_block = 0;
        return;
    }

    # Pass message without modification.
    $input_block = 1;
    Irssi::signal_emit($signal, $server, $msg, $nick, $param3, $param4);
    Irssi::signal_stop();
    $input_block = 0;
}

########################################
# Hooks ################################
########################################

Irssi::settings_add_str('misc', 'attribution_attributors', '^tg^');
Irssi::settings_add_str('misc', 'attribution_continuation', '…');
Irssi::settings_add_str('misc', 'attribution_continuation_pad', "");
Irssi::settings_add_str('misc', 'attribution_indicator', '⇋');

Irssi::signal_add_first('server event', 'attribution_input');
