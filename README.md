# Pterodactyl FEX
## About this repo
This repo contains the docker files and utilities to build a installer and a runner container to run FEX, Proton and SteamCMD on an Pterodactyl Oracle OCI instance. Should work for other ARM64 processors as well. Rebuilding with a different "fex-emu-arm" packge might be needed depending on the processor.

## Images
The built packages are configured to use the "fex-emu-armv8.2" packge to support Oracle OCI instances. Other versiosn are currently not being build automatically. The images are updated automatically twice a month.

## Eggs
Currently there is only one example egg for Enshrouded. But since it uses FEX, Proton and SteamCMD it should be fairly easy to customize it. Changing the server config using variables is not supported. To make config changes, use the Pterodactyl file explorer after the first boot.

## Building manually
```
cd docker

# use autodetection for ARM CPU version
docker build . -f fex_runner/Dockerfile
docker build . -f fex_installer/Dockerfile

# or specify which package to use
docker build . -f fex_runner/Dockerfile --build-arg CPU_FEATURE_OVERRIDE=8.2
docker build . -f fex_installer/Dockerfile --build-arg CPU_FEATURE_OVERRIDE=8.2
```
