FROM    ubuntu:24.04

ENV     DEBIAN_FRONTEND=noninteractive

# Install needed packages for FEX as well as some other usefull things
RUN     apt update && apt upgrade -y  \
            && apt install -y  --no-install-recommends ca-certificates python3 curl sudo software-properties-common jq
            
# Install FEX without a RootFS, RootFS will be installed by installer script
ARG     CPU_FEATURE_OVERRIDE
ENV     CPU_FEATURE_OVERRIDE=$CPU_FEATURE_OVERRIDE
COPY    ./utils/InstallFEX.py /usr/local/bin/InstallFEX.py
RUN     python3 /usr/local/bin/InstallFEX.py \
            && rm -rf /var/lib/apt/lists/*

# Add container user needed for pterodactyl
RUN     useradd -m -d /home/container -s /bin/bash container
USER    container
ENV     USER=container
ENV     HOME=/home/container
ENV     XDG_DATA_HOME=${HOME}
WORKDIR ${HOME}

# Add ENV vars for proton
ENV     STEAMCMD_PATH=${HOME}/Steam
ENV     STEAM_COMPAT_CLIENT_INSTALL_PATH=${STEAMCMD_PATH}
ENV     STEAM_COMPAT_DATA_PATH=${STEAMCMD_PATH}/steamapps/compatdata

# Copy util scripts
COPY    ./utils/IndirectSteamServerStart.sh /usr/local/bin/IndirectSteamServerStart.sh
COPY    ./utils/CheckCPUFeatureVersionMismatch.sh /usr/local/bin/CheckCPUFeatureVersionMismatch.sh
COPY    ./utils/GetCPUFeaturesVersion.py /usr/local/bin/GetCPUFeaturesVersion.py
COPY    ./fex_runner/entrypoint.sh /entrypoint.sh

COPY    ./utils/InstallSteamCMD.sh /usr/local/bin/InstallSteamCMD.sh

CMD     ["/entrypoint.sh"]
