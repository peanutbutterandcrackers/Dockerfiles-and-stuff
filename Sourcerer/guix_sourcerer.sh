# GUIX package manager configurations for a 'foreign distro'
# For GUIX_VERSION=1.0.1

function guix_profile_init {
    # A dummy `$ guix profile init`; no such command exists, yet.
    # Use an empty manifest file to instantiate a guix profile
	GUIX_EMPTY_MANIFEST=`mktemp /tmp/XXXXXXXXXXXXX`
    echo "(packages->manifest '())" > "$GUIX_EMPTY_MANIFEST"
    guix package --manifest="$GUIX_EMPTY_MANIFEST"
}

# LANG can be either left unset or be set to something
# like "en_US.UTF8". However, if LANG is set to "C.UTF-8",
# then guix throws warnings about failing to install locale,
# despite installing `glibc-utf8-locales` and `glibc-locales`
# AND having set the correct GUIX_LOCPATH.
# LANG was defaulting to "C.UTF-8" for newly-created non-root
# users. So, unset LANG
unset LANG

# Instantiate a GUIX profile for the $USER if that hasn't been done yet
[ -L "$HOME/.guix-profile" ] || guix_profile_init &> /dev/null

export GUIX_PROFILE="$HOME/.guix-profile"
export GUIX_LOCPATH="$GUIX_PROFILE/lib/locale"
export PATH="$GUIX_PROFILE/bin${PATH:+:}$PATH"

# Export all search-paths/environment-vars required to run packages
# installed by GUIX. `guix package --search-paths=prefix` returns all
# necessary environment variables including PATH (in the first line of
# the output by default). PATH specification is skipped (to prevent PATH
# from being cluttered with duplicate entries) and the rest are evaluated.
# The reason why PATH is exported in isolation (and not evaluated from here)
# is because when a user's guix profile is first being instantiated, the 
# following evaluates to nothing. Doing so also allows the user to run their
# first `guix install hello` program, without worrying about $PATH.
eval `guix package --search-paths=prefix 2> /dev/null | tail -n +2`
