# [Ubuntu-Hyprland](https://github.com/katabame/Ubuntu-Hyprland)

(hopefully) minimal script for build [hyprwm/hyprland](https://github.com/hyprwm/hyprland) on [Ubuntu oracular](https://cdimage.ubuntu.com/daily-live/current/)

>[!NOTE]
>`hyprland` is now can be installed via apt [[source]](https://wiki.hyprland.org/Getting-Started/Installation/)  
>`sudo add-apt-repository universe && sudo apt-get update && sudo apt-get install -y hyprland`

>[!IMPORTANT]
>`hyprwm/Hyprland` v0.42.0 requires new dependency `hyprwm/aquamarine`,  
>but some dependencies (including dependency to build `hyprwm/aquamarine`) at apt is old on noble.  
>I hightly recommends use oracular instead!

## Usage on Ubuntu oracular
```bash
## Canary
# using wget
wget -O - https://hypr.kataba.me/oracular.sh | bash
# using curl
curl https://hypr.kataba.me/oracular.sh | bash

## Nightly
# using wget
wget -O - https://hypr.kataba.me/oracular.sh | bash -s -- nightly 
# using curl
curl https://hypr.kataba.me/oracular.sh | bash -s -- nightly
```

## Usage on Ubuntu noble (⚠ discontinued - help needed)
```bash
## Canary
# using wget
wget -O - https://hypr.kataba.me/noble.sh | bash
# using curl
curl https://hypr.kataba.me/noble.sh | bash

## Nightly
# using wget
wget -O - https://hypr.kataba.me/noble.sh | bash -s -- nightly
# using curl
curl https://hypr.kataba.me/noble.sh | bash -s -- nightly
```


# Contribute
if you find any improvement or issue, please open [pullrequest](https://github.com/katabame/Ubuntu-Hyprland/pulls) or [issue](https://github.com/katabame/Ubuntu-Hyprland/issues)
