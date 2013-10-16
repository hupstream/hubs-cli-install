#!/usr/bin/env bash
#
# hubs.im command-line helper install script.
#
# See https://github.com/hupstream/hubs-cli-install for source and issue report.
#
# (c) 2013 hupstream
# Published under GPLv2 license.
#

KTHXBYE=<<EOF
Please let us know at @hupstream or mailbox@hupstream.com about it.

Thank you and have a great, nice day!

EOF

NAME=""

identify_system() {
  # Identify current version.
  # /etc/os-release is not stable between versions (at least wheezy and jessie)
  if [ -r /etc/apt/sources.list ]; then
    # FIXME check all possible versions found in sources.list
    VALID_VERSIONS=(wheezy jessie sid)
    VERSION=$(grep ^deb /etc/apt/sources.list|awk '{print $3}'|uniq|head -1)
    for n in $VALID_VERSIONS; do
      if [ "$n" = "$VERSION" ]; then
        NAME=$n
      fi
    done
    if [ "x$NAME" = "x" ]; then
      echo ""
      echo "Ah. Sorry, but this version ($VERSION) is not supported, yet."
      echo "We're doing the best we can to make this an useful service."
      echo $KTHXBYE
      exit 1
    fi
  else
    echo ""
    echo "Ah."
    echo "This does not seem to be a Debian system (no /etc/apt/sources.list)."
    echo "hubs is still a Debian-only service. Sorry for that."
    echo $KTHXBYE
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

echo "Hello $USER!"
echo ""
echo "I am going to install hubs command-line helper on your system."
echo "I will run a few sudo commands, so I may ask for your password once."
echo ""
echo "Please, feel free to read the source of this script before I run it."
echo $KTHXBYE
read -n 1 -p "Shall I install it now? (yes/no) " R

echo ""
if [ "$R" = "y" -o "$R" = "Y" ]; then
  echo "Ok, let's do it:"
else
  echo "Ok, not doing anything. Have a great, nice day!"
  exit 0
fi

identify_system
install_dependencies
add_gpg_keys
add_hubs_repository
install_hubs_cli

echo ""
echo "You're set! Welcome on board. You may now run 'hubs start' to see "
echo "how to get started and build your first package!"

exit 0

