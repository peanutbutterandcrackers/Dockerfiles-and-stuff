# GUIX package manager configurations for a 'foreign distro'
# For GUIX_VERSION=1.0.1

function guix_profile_init {
    # A dummy `$ guix profile init`; no such command exists, yet.
    # Use an empty manifest file to instantiate a guix profile
	echo "####### GUIX FIRST-RUN PROFILE SET-UP #######"
	echo -e "(This may take some time. Please be patient.)\n"
	local GUIX_EMPTY_MANIFEST=`mktemp /tmp/XXXXXXXXXXXXX`
	echo -n "(packages->manifest '())" > "$GUIX_EMPTY_MANIFEST"
	guix package --verbosity=3 --manifest="$GUIX_EMPTY_MANIFEST"
	# In case of failure, cleanup
	if [ $? -ne 0 ]; then
		local GUIX_PROFILE="$HOME/.guix-profile"
		rm -rf "$GUIX_PROFILE" "`readlink -f $GUIX_PROFILE`"
	fi
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
[ -L "$HOME/.guix-profile" ] || guix_profile_init

export GUIX_PROFILE="$HOME/.guix-profile"
export GUIX_LOCPATH="$GUIX_PROFILE/lib/locale"
export PATH="$GUIX_PROFILE/bin${PATH:+:}$PATH"

# GUIX_PROFILE is the user's guix profile at $HOME/.guix-profile.
# However, there is also ~/.config/guix/current. This one is also
# a profile - but for guix and guix-daemon itself. This is a careful
# design descision made by the devs so as to allow users to roll-back
# to previous versions of their profile without rolling back guix itself
# and vice-versa. ~/.config/guix/current is initialized only after a su-
# ccessful `guix pull`. The following adds it to the PATH if it exists.
if [ -L "$HOME/.config/guix/current" ]; then
	export PATH="$HOME/.config/guix/current/bin:$PATH"
fi

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
