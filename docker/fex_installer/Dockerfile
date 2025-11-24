FROM    ubuntu:24.04

ENV     DEBIAN_FRONTEND=noninteractive

# Install needed packages for FEX as well as some other usefull things
RUN     apt update && apt upgrade -y  \
            && apt install -y  --no-install-recommends ca-certificates python3 curl sudo software-properties-common jq
            
# Install FEX without a RootFS, RootFS will be installed by installer script
COPY    ./utils/InstallFEX.py /usr/local/bin/InstallFEX.py
RUN     python3 /usr/local/bin/InstallFEX.py \
            && rm -rf /var/lib/apt/lists/*

# Copy more installer
COPY    ./utils/InstallProton.sh /usr/local/bin/InstallProton.sh
COPY    ./utils/InstallSteamCMD.sh /usr/local/bin/InstallSteamCMD.sh

# Add ENV vars for installation
ENV     STEAMCMD_PATH=/home/container/Steam
ENV     STEAM_COMPAT_DATA_PATH=${STEAMCMD_PATH}/steamapps/compatdata/

CMD     ["/bin/bash"]
