#!/bin/sh
portrait=`gconftool-2 -g /apps/QNeptunea/Theme/Splash/Portrait`
landscape=`gconftool-2 -g /apps/QNeptunea/Theme/Splash/Landscape`

if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    export DBUS_SESSION_BUS_ADDRESS=`cat /tmp/dbus-info-address`
    /opt/qneptunea/bin/qneptunea $@
else
    /usr/bin/invoker -S "$portrait" -L "$landscape" --type=d -s /opt/qneptunea/bin/qneptunea $@
fi
