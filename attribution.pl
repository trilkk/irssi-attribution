########################################
# Header ###############################
########################################

use strict;
use Encode ();
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

# Strip color codes from a potential IRC nickname.
# \param 0 Input string.
# \return Input string without color codes.
sub strip_color
{
    my $nick = $_[0];
    $nick =~ s/\cC\d+(,\d+)?//g;
    $nick =~ s/\cC//g;
    $nick =~ s/\cO//g;
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

    $msg =~ /^(PRIVMSG\s#\S+\s:)<([^>]+)>\s+(.*)$/;
    my $modified = $1 . $3;
    my $attr = strip_color($2);

    # Only certain attributors are allowed.
    if($attr && is_attributor($nick))
    {
        my $indicator = Irssi::settings_get_str('attribution_indicator');
        $input_block = 1;
        Irssi::signal_emit($signal, $server, $modified, $attr . $indicator, $param3, $param4);
        Irssi::signal_stop();
        $input_block = 0;
        return;
    }

    $input_block = 1;
    Irssi::signal_emit($signal, $server, $msg, $nick, $param3, $param4);
    Irssi::signal_stop();
    $input_block = 0;
}

########################################
# Hooks ################################
########################################

Irssi::settings_add_str('misc', 'attribution_attributors', '^tg^');
Irssi::settings_add_str('misc', 'attribution_indicator', '⇋');

Irssi::signal_add_first('server event', 'attribution_input');
