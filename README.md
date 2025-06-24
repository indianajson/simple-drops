# Simple Drops
A script to add easily configurable ice tile drops in Open Net Battle servers. 

### How does it work?

> This script is plug-n-play. Once you copy the required scripts to your server (see below) everything else is configured within the Tiled map editor for your server area. You simply add an object to your map with the required parameters and the script does the rest. Currently, this script supports ice drops (sliding off the edge of ice tiles), but down the road it will hopefully include normal drop zones as well. 

### Want to try it out?

> This repository contains a complete test server you can spin up that includes configured examples in all four directions. It will show you how they should be configured and how they function in-game without having to do the setup yourself.

### How do I install this on my ONB server?

> 1. Download the repository.
> 2. Copy `/scripts/simple-drops/` to your server’s script folder.

### How do I add an Ice Drop?
> 1. Open your map in Tiled.
> 2. Select an Object Layer on your map.
> 3. Insert a Point (you can press `I` on your keyboard then click to place it).
> 4. Position the Point near the middle of the tile you want to become a drop zone.
> 5. Set the Class to `Ice Drop`
> 6. Add two string based Custom Properties<br>
> &nbsp; &nbsp; `Drop Edge` determines which side is a drop off ("Down Left", "Down Right", "Up Left", "Up Right")<br>
> &nbsp; &nbsp; `Landing` should be a whole number representing the Z or layer where the player is supposed to land.<br>
> If you want two edges to be drop zones simply set a second Point with the `Drop Edge` as the other edge.

On boot your server log should show the ice drop was added at that location, or an error if it was improperly configured. 

I highly recommend my [Fix Layers](https://github.com/indianajson/fix-layers) Tiled extension as it makes adding new layers a breeze. 

### Doesn't ezwarps from ezlibs do this already?

> The `fall_off_2` animation provided with ezwarps does provide a similar function, however, it is limited to two layer drops only and may not work properly for "Up Left" and "Up Right" drops. 
