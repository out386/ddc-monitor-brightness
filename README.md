# DDCBR

DDCBR is just a shell wrapper around [ddcutil](https://github.com/rockowitz/ddcutil). It can be used to easily increment or decrement the brightness of a monitor.

### Installation

Install [ddcutil](https://github.com/rockowitz/ddcutil) and clone this repo.  
Follow [ddccontrol's instructions](http://ddccontrol.sourceforge.net/doc/latest/ch02s04.html).  
Run `ddcutil detect`. Find your monitor in the list, and note the number after `/dev/i2c-`. Put this number in the `BUS` variable of ddcbr.sh.  
Set the `BASE_DIR` variable to point to this repository.

### Usage

Increase brightness by 10%:  
`./ddcbr.sh i`

Decrease brightness by 10%:  
```./ddcbr.sh d```

Keyboard shortcuts can be added to the window manager to call this script quickly.
