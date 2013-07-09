## Overview

An EDF parser written in coffee-script.

Primarily used for Polysomnographic signals, the EDF file format is multi-channel, supports multiple sampling rates on a per channel basis, and provides for an unlimited number of channels. More information can be found on the [wikipedia article](http://en.wikipedia.org/wiki/European_Data_Format).

## Usage and Examples

```CoffeeScript
edf = require "edf"

my_edf = new edf.EDFFile "./path/to/file.edf"

my_edf.get_file_duration( )
```

## License
See [LICENSE](LICENSE).

## Thanks
Original work sponsored by Younes Sleep Technologies.
http://younessleeptechnologies.com/
