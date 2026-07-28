#!/bin/bash

GLOFAS_CACHE=/var/cache/glofas

find "$GLOFAS_CACHE" -mindepth 1 -maxdepth 1 -type f |
	xargs -r ls -td |
	tail -n +30 |
	xargs -r rm -rf
