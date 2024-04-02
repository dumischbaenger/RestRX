#!/usr/bin/env bash

#set -xu

DEPLOYMENT_DIR="$(dirname "$(readlink -f "$0")")"

PATH=$PATH:"$DEPLOYMENT_DIR/glassfish7/bin/"
