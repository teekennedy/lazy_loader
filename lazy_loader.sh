#!/usr/bin/env bash

# lazy_loader.sh
# Copyright 2018 Terrance Kennedy
# MIT License, http://www.opensource.org/licenses/mit-license.php

# Defer initialization steps until one or more trigger commands is invoked.
#
# Usage: lazy_load <initialization_function> <cmd1> [ <cmd2> [..] ]
#
# Given an initialization_function and a list of commands that depend on that
# initialization_function, lazy_load creates a stub for each command that runs
# the initialization_function before invoking the command. It also unloads the
# stub, so the next time the command is ran, it's ran directly.
function lazy_load() {
    if [ $# -lt 2 ]; then
        echo "Usage: lazy_load <initialization_function> <cmd> [ <cmd2> [..] ]"
        return
    fi

    # name of the function that will be called to initialize the tool
    local init_func=$1
    shift
    # one or more commands to trigger initialization of the tool
    local cmd_list=( "$@" )

    # create a stub function for each command
    for cmd in "${cmd_list[@]}"; do
        # define cmd as a function
        eval "function $cmd() {
            echo \"Lazy loading $cmd...\"
            # destroy all stub functions related to init_func
            unset -f ${cmd_list[@]}
            # run init_func
            $init_func
            # run the command this stub was wrapping
            $cmd \$@
        }"
    done
}
