## Overview

An EDF parser written in coffee-script.

Primarily used for Polysomnographic signals, the EDF file format is multi-channel, supports multiple sampling rates on a per channel basis, and provides for an unlimited number of channels. More information can be found on the [wikipedia article](http://en.wikipedia.org/wiki/European_Data_Format).

## Usage and Examples

```CoffeeScript
util	= require "util"
edf	= require "edf"

my_edf = new edf.EDFFile "./path/to/file.edf"
util.log "The file is " + my_edf.get_file_duration( ) + " seconds in length."

num_signals = k.get_header_item "num_signals_in_data_record"
util.log "There are " + num_signals + " in this file."

for signal_index in [0...num_signals]
	signal_label = k.get_signal_item signal_index, "label"
	util.log "Signal Index " + signal_index + " is : " + signal_label
```

## License
See [LICENSE](LICENSE).

## Thanks
Original work sponsored by Younes Sleep Technologies.
http://younessleeptechnologies.com/
