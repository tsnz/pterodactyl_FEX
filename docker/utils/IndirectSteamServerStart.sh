#!/bin/bash
set -o pipefail

# Usage info
show_help() {
cat << EOF
Usage: ${0##*/} -c COMMAND -l LOGFILE_PATH -x EXECUTABLE_NAME -s KILL_SIGNAL
Start server in seperate process and tail logfile. Depending on ENV var \$AUTO_UPDATE try to update using SteamCMD before starting.
Environment variable PROTON_REPO_API_URL needs to be set to proton git hub repo's API URL

    -h      Display this help and exit.
    -c      Command to execute to start the server.
    -l      Log file to tail after server start.
    -x      Executable name to look for to get PID.
    -s      Signal to send to server process when shutting down.
EOF
}

_shutdown() {
    if [ -z "$SHUTDOWN_IN_PROGRESS" ]; then
        echo "Received shut down request, sending $terminate_signal to $pid"
        kill -s "$terminate_signal" "$pid"
        SHUTDOWN_IN_PROGRESS=1
    else
        echo "Received 2nd shut down request, sending SIGKILL to $pid"
        kill -s SIGKILL "$pid"
    fi
}

trap _shutdown SIGINT
trap _shutdown SIGTERM

while getopts hc:l:x:s: opt; do
    case $opt in
        h)
            show_help
            exit 0
           ;;
        c)
            start_command="$OPTARG"
            ;;
        l)
            logfile="$OPTARG"
            ;;
        x)
            executable="$OPTARG"
            ;;
        s)
            terminate_signal="$OPTARG"
            ;;
        *)
            show_help >&2
            exit 1
            ;;
        esac
done

# Check if all needed params are provided
for arg in start_command executable; do
    if [ -z "${!arg}" ]; then
        echo "Missing required argument for ${arg@Q}" >&2
        show_help >&2
        exit 1
    fi
done

# Use SIGTERM as defautl signal
if [ -z "$terminate_signal" ]; then
    terminate_signal=SIGTERM
fi

# Check if auto update is enabled
if [ "$AUTO_UPDATE" = "1" ]; then
    echo "Auto Update enabled, updating server"
    if ! FEX "$STEAMCMD_PATH"/steamcmd.sh "$( [ "$FORCE_WIN" = "1" ] &&  printf '+@sSteamCmdForcePlatformType windows' )" \
      +force_install_dir "$HOME"/server +login anonymous +app_update "$APP_ID" +quit; then
        echo "Error while updating server, continuing without updating. Restart server to try again."
    fi
fi

# Start server in background and try to capture pid
echo "Executing: $start_command"
$start_command &

for try in {1..18}; do
    # Only use first PID if multiple exist
    echo "Try $try to find server executable"
        pid="$(pgrep -x "$executable" | head -1)"
        if [ -n "$pid" ]; then
            break;
        fi
        sleep 5
done

# Exit if server did not start
if [ -z "$pid" ]; then
    echo "Server did not start up. Exiting startup script."
    exit 1
else
    echo -e "Found associated PID: $pid"
fi

if [ ! -e "$logfile" ]; then
    echo "Logfile not found, contents will not be displayed on the terminal or relayed to docker logs"
    logfile="/dev/null"
fi

tail -F "$logfile" --pid="$pid" --lines 0 &
tail_pid=$!

# Wait for tail to exit, which in turn waits for the server to exit
wait $tail_pid

# Either server died, or SIGINT. Wait for tail in case of SIGINT to capture shut down logs
wait $tail_pid

if ps -p "$pid" > /dev/null; then
    echo "WARNING: Server appears to still be running! PID: $pid"
else
    echo "Server shut down complete"
fi
