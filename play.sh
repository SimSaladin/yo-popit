#!/bin/bash

mpc clear
mpc load $1
mpc random off
mpc single off
mpc repeat off
mpc consume on
mpc enable 1

sleep 2 && mpc play
