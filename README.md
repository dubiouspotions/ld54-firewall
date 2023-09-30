# FIREWALL

A NES game for Ludum Dare 54!

Setup based on [this video](https://www.youtube.com/watch?v=V5uWqdK92i0).

## Setup

* Download and install [CC65](https://github.com/cc65/cc65)
* If you're on Windows, you'll want:
    * bash (probably through git bash)
    * [make](https://gnuwin32.sourceforge.net/packages/make.htm)
    * ... and add them (and cc65) to PATH
* You'll also likely want VSCode and Alchemy65 extension
* For emulator, how about [Mesen](https://www.mesen.ca/)?

## Build and run

```
make all      # will generate build/firewall.nes. now you can open it with mesen
```


## Parse tilemap 
```
cd gamedata
node parser.js level1.tmx
```