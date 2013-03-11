#!/bin/bash

mpc="mpc -p 6601"

$mpc clear

$mpc load $1

# set some settings
$mpc random off
$mpc single off
$mpc repeat off
$mpc consume on
$mpc crossfade 1
$mpc replaygain off

$mpc enable 1

sleep 2 && $mpc play
