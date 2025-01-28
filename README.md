# irssi-attribution

Extracts attribution information from bridge bots to make it seem as if the users behind the bridge were at the channel.

## Usage

Clone this repository somewhere in your home directory. Let's assume directly at `~/`:

    cd ~
    git clone https://github.com/trilkk/irssi-attribution.git

Go to `.irssi/scripts/` and enable the script:

    cd ~/.irssi/scripts
    ln -s ../../irssi-attribution/attribution.pl

To enable the script automatically, add it to `~/.irssi/scripts/autorun/`:

    cd ~/.irssi/scripts/autorun
    ln -s ../attribution.pl

## Settings

The script provides the following settings:

    attribution_attributors : str
    attribution_continuation : str
    attribution_indicator : str

`attribution_attributors` is a whitespace-separated list of names that should be considered legitimate attributors. IRC does not support whitespace in usernames, so this is a valid restriction.

`attribution_continuation` is a string used as a replacement for a nickname when an attributor is speaking without attributing anyone. This is a typical case for successive lines of multiline messages. May be an empty.

`attribution_continuation_pad` is a string used to pad the continuation to the length of the pervious nickname attributed. Can be used to align the continuation to the same length if the user's theme does not have indenting. Whitespace is accepted. Empty string implies no padding done.

`attribution_indicator` is a string appended to nicknames from behind bridges. May be an empty.

Example addition to `~/.irssi/config`:

    settings = {
        "perl/core/scripts" = {
            attribution_attributors = "^tg^ ^tg^1";
            attribution_continuation = "…";
            attribution_continuation_pad = "";
            attribution_indicator = "⇋";
        };
    };

**Note:** If the attribution indicator is a non-legal IRC nickname character, a related project [irssi-colored-nicks](https://github.com/trilkk/irssi-colored-nicks) will color the indicator as dark gray.
