# Lockpick Atlas

<img src="assets/lockpick-atlas-logo.png" alt="Lockpick Atlas brass compass logo" width="96">

A rogue lockpicking guide for **World of Warcraft: Forever**. Find reported footlocker spots on the world map and minimap, save your own pins, and get a warning when you've reached your current skill cap.

## Install

Copy the [`LockpickAtlas`](LockpickAtlas) folder to your Forever client's `Interface/AddOns` folder, then enable **Lockpick Atlas** in the AddOn List. Right-click the compass beside the minimap to add coordinates, toggle markers, or open Settings.

See the [addon guide](LockpickAtlas/README.md) for commands, how to carry over pins from Lockpick Assist, and the sources for the built-in routes.

## Build and release

Run `pwsh -File scripts/Build-Addon.ps1` to build `dist/LockpickAtlas-vX.Y.Z.zip`. The version comes from the addon's TOC.

For a release, commit the TOC version, then create and push a matching tag such as `v0.2.7`. GitHub Actions builds and publishes the addon ZIP as a [release asset](https://github.com/cfau214037/lockpick-atlas/releases). Download that ZIP to upload it to CurseForge.
