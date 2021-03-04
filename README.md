# irssi-attribution

Extracts attribution information from bridge bots to make it seem as if the users behind the bridge were at the channel.

## Usage

Clone this repository somewhere in your home directory. Let's assume directly at `~`:

    cd ~
    git clone https://github.com/trilkk/irssi-attribution.git

Go to `.irssi/scripts/autorun` and enable the script:

    cd ~/.irssi/scripts/autorun
    ln -s ../../../irssi-attribution/attribution.pl

## Settings

The script provides the following settings:

    attribution_attributors : str
    attribution_indicator : str

`attribution_attributors` is a whitespace-separated list of names that should be considered legitimate attributors. IRC does not support whitespace in usernames, so this is a valid restriction.

`attribution_indicator` is a character appended to nicknames from behind bridges. The indicator may be an empty string.

Example addition to `~/.irssi/config`:

    settings = {
        "perl/core/scripts" = {
            attribution_attributors = "^tg^ ^tg^1";
            attribution_indicator = "⇋";
        };
    };

**Note:** If the attribution indicator is a non-legal IRC nickname character, a related project [irssi-colored-nicks](https://github.com/trilkk/irssi-colored-nicks) will color the indicator as dark gray.
