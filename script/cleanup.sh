#!/bin/sh
find . -name .DS_Store | xargs rm
find . -name "*.qmlproject.user" | xargs rm
