#!/usr/bin/env bash
#
# hubs.im command-line helper install script.
#
# See https://github.com/hupstream/hubs-cli-install for source and issue report.
#
# (c) 2013 hupstream
# Published under GPLv2 license.
#

KTHXBYE=$(cat <<K

Please let us know about it at:
 - twitter.com/@hupstream
 - hubs+support@hupstream.com

Thank you, have a nice day!

K
)

NAME=""

identify_system() {
  # Identify current version.
  # /etc/os-release is not stable between versions (at least wheezy and jessie)
  if [ -r /etc/apt/sources.list ]; then
    # FIXME check all possible versions found in sources.list
    VALID_VERSIONS=(wheezy jessie sid)
    VERSION=$(grep ^deb /etc/apt/sources.list|awk '{print $3}'|uniq|head -1)
    for n in "${VALID_VERSIONS[@]}"; do
      if [ "$n" == "$VERSION" ]; then
        NAME=$n
      fi
    done
    if [ "x$NAME" == "x" ]; then
      echo ""
      echo "Ah. Sorry: this Debian version ($VERSION) is not supported, yet."
      echo "We're doing the best we can to make this an useful service."
      echo "$KTHXBYE"
      exit 1
    fi
  else
    echo ""
    echo "This does not seem to be a Debian system (no /etc/apt/sources.list)."
    echo "hubs is still a Debian-only service."
    echo "$KTHXBYE"
    exit 1
  fi
}

install_dependencies() {
  ath=$(dpkg -l |grep apt-transport-https)
  if [ "x$ath" = "x" ]; then
    echo ""
    echo "  - Installing dependencies (using apt-get):"
    echo "    apt-transport-https"
    sudo apt-get install apt-transport-https
  fi
}

add_gpg_keys() {
  echo ""
  echo "  - Adding hubs repository GPG key (using wget, apt-key)"
  wget -qO- https://repo.hubs.im/hubs/keys/$NAME.gpg | sudo apt-key add -
}

add_hubs_repository() {
  echo ""
  echo "  - Adding repository in /etc/apt/sources.list/hubs.list"
  LINE="echo \"deb https://repo.hubs.im/hubs/ $NAME main\" > /etc/apt/sources.list.d/hubs.list"
  echo $LINE | sudo -s
  sudo apt-get update
}

install_hubs_cli() {
  ath=$(dpkg -l |grep hubs)
  if [ "x$ath" = "x" ]; then
    echo ""
    echo "  - Installing hubs (using apt-get)..."
    sudo apt-get install hubs
  else
    echo ""
    echo "  - hubs-cli is already installed."
  fi
}

echo
echo "https://hubs.im/ command-line helper installation"
echo "================================================="

identify_system

echo "Hello $USER!"
echo ""
echo "I am going to install hubs command-line helper on your system."
echo "I will run a few sudo commands, so I may ask for your password once."
echo " - install dependencies,"
echo " - add hubs.im own repository,"
echo " - install hubs command-line helper from there."
echo ""
echo "Feel free to read the source of this script before running it."
echo $KTHXBYE
read -n 1 -p "Shall I install it now? (yes/no) " R

echo ""
if [ "$R" = "y" -o "$R" = "Y" ]; then
  echo "Ok, let's do it:"
else
  echo "Ok, I'm leaving it here. Have a nice day!"
  exit 0
fi

install_dependencies
add_gpg_keys
add_hubs_repository
install_hubs_cli

echo ""
echo "You're set! Welcome on board. Run 'hubs start' to see "
echo "how to get started and build your first package!"

exit 0

