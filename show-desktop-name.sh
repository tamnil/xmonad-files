#!/bin/bash
wmctrl -l -d | grep \* | awk '{print $9}'

