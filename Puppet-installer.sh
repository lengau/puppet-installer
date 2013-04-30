#!/bin/bash
#
#		Puppet Installer
#
#	Copyright (C) 2013 Alex M. Lowe (amlowe@ieee.org)
#	Released into the public domain on 2013-04-28
#
#	This script installs the latest version of Puppet from the repositories on a Debian-based system.
#	REQUIRES: Repository with package "puppet" in it, including correct dependencies.

echo "Updating APT repositories..."
sudo apt-get update > /dev/null

echo "Installing Puppet agent..."
sudo apt-get install puppet

echo "Installing base configuration..."
sudo cp puppet.conf.base /etc/puppet/puppet.conf
echo -n "Please enter your Puppet master server's DNS name: "
read SERVERNAME
echo $SERVERNAME|sudo tee -a /etc/puppet/puppet.conf
sudo cp puppet-defaults /etc/default/puppet

echo "Starting Puppet agent..."
sudo puppet agent --test >/dev/null
echo "Please login to your Puppetmaster server ($SERVERNAME) and sign this server's key."
echo "The command is: puppet cert sign $(hostname -f)"

RESPONSE='n'
while [ $RESPONSE != "y" ]; do
	echo -n "Have you completed this signing task? (y/N)"
	read RESPONSE
	# This just allows us to assume no on an empty input.
	if [ "x$RESPONSE" == "x" ]; then
		RESPONSE=N
	fi
	if [ $RESPONSE != "y" ]; then
		echo "Please sign the key before proceeding."
	fi
done

echo "Starting Puppet agent..."
sudo puppet resource service puppet ensure=running