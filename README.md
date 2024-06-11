# [Ubuntu-Hyprland](https://github.com/katabame/Ubuntu-Hyprland)

(hopefully) minimal script for build [hyprwm/hyprland](https://github.com/hyprwm/hyprland) on Ubuntu noble

## Usage
```bash
# using wget
wget -O - https://hypr.kataba.me/build.sh | bash

# using curl
curl https://hypr.kataba.me/build.sh | bash
```

<details>
<summary>Advanced usage</summary>

  ```bash
  # Stable build
  
  # using wget
  # same as:
  # wget -O - https://hypr.kataba.me/build.sh | bash
  wget -O - https://hypr.kataba.me/build.sh | bash -s -- stable
  
  # using curl
  # same as:
  # curl https://hypr.kataba.me/build.sh | bash
  curl https://hypr.kataba.me/build.sh | bash -s -- stable
  ```

  ```bash
  # Canary build
  
  # using wget
  wget -O - https://hypr.kataba.me/build.sh | bash -s -- canary
  
  # using curl
  curl https://hypr.kataba.me/build.sh | bash -s -- canary
  ```

  ```bash
  # Nightly build
  
  # using wget
  wget -O - https://hypr.kataba.me/build.sh | bash -s -- nightly
  
  # using curl
  curl https://hypr.kataba.me/build.sh | bash -s -- nightly
  ```

</details>

|Channel / Status|Description|Update Timing|
|-----|-----|-----|
|[![Stable build](https://github.com/katabame/Ubuntu-Hyprland/actions/workflows/stable.yaml/badge.svg)](https://github.com/katabame/Ubuntu-Hyprland/actions/workflows/stable.yaml)|Build with pre-defined tags for repositories.<br>Should build success everytime.|manually|
|[![Canary build](https://github.com/katabame/Ubuntu-Hyprland/actions/workflows/canary.yaml/badge.svg)](https://github.com/katabame/Ubuntu-Hyprland/actions/workflows/canary.yaml)|Build with latest tags for repositories.<br>Possibly build success after new hyprwm/hyprland tag released.|daily|
|[![Nightly build](https://github.com/katabame/Ubuntu-Hyprland/actions/workflows/nightly.yaml/badge.svg)](https://github.com/katabame/Ubuntu-Hyprland/actions/workflows/nightly.yaml)|Build with latest commits for repositories.<br>Mostly build fails.|daily|

# Contribute
if you find any improvement or issue, please open [pullrequest](https://github.com/katabame/Ubuntu-Hyprland/pulls) or [issue](https://github.com/katabame/Ubuntu-Hyprland/issues)
