#!/bin/bash

# Switch to the container's working directory
cd /home/container || exit 1

# Convert all of the "{{VARIABLE}}" parts of the command into the expected shell
# variable format of "$VARIABLE"
PARSED=$(sed -E "s/\{\{(\w+)\}\}/\"$\1\"/g" <<< "$STARTUP")

# Display the command we're running in the output, and then execute it using eval
# to expand ENV variables
printf "\033[1m\033[33mcontainer@pterodactyl~ \033[0m%s\n" "STARTUP COMMAND -> $PARSED"
eval exec "$PARSED"
