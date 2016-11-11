#!/bin/sh

ifconfig | awk "/inet / && /broadcast/" | awk '$1 == "inet" {print $2}'
