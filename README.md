# FIREWALL

![poster](https://static.jam.host/raw/f9d/04/z/5cae1.png)

**You and your favorite nemesis are hanging out in your usual oil-field, when suddenly fires
spark to life. As the raging fires close in on the two of you from all sides, you have to
fight to be the last one to burn!**

A NES game for Ludum Dare 54! See our [game page at ldjam](https://ldjam.com/events/ludum-dare/54/firewall), or
[play it in your browser now](https://dubiouspotions.github.io/ld54-firewall/) :)

[![screenshot](https://static.jam.host/raw/f9d/04/z/5cb5b.jpg)](https://dubiouspotions.github.io/ld54-firewall/)


## Development environment

The dev setup based on [this video](https://www.youtube.com/watch?v=V5uWqdK92i0).

* Download and install [CC65](https://github.com/cc65/cc65)
* If you're on Windows, you'll want:
    * bash (probably through git bash)
    * [make](https://gnuwin32.sourceforge.net/packages/make.htm)
    * ... and add them (and cc65) to PATH
* You'll also likely want VSCode and Alchemy65 extension
* For emulator, how about [Mesen](https://www.mesen.ca/)?

## Build and run

```bash
make all      # will generate build/firewall.nes. now you can open it with mesen
```


## Parse tilemap 
```bash
cd gamedata
node parser.js level1.tmx
# or 
python generate_tilemap.py
```

.. and mash the result into cart.s