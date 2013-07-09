## Overview

An EDF parser written in coffee-script.

Primarily used for Polysomnographic signals, the EDF file format is multi-channel, supports multiple sampling rates on a per channel basis, and provides for an unlimited number of channels. More information can be found on the [wikipedia article](http://en.wikipedia.org/wiki/European_Data_Format).

## Usage and Examples

#### A simple Example
```CoffeeScript
util    = require "util"
edf             = require "edf"

# Create a new instance of edf.EDFFile.
my_edf = new edf.EDFFile "./path/to/some.edf"

# Get some information about the file.
file_duration   = my_edf.get_file_duration( )
num_signals     = my_edf.get_header_item "num_signals_in_data_record"

util.log "The file is " + file_duration + " seconds in length."
util.log "There are " + num_signals + " signals in this file."

# Get some information about the signals.
for signal_index in [0..num_signals-1]
        signal_label    = my_edf.get_signal_item signal_index, "label"
        sample_rate     = my_edf.get_header_item( "duration_of_data_record" ) / my_edf.get_signal_item( signal_index, "num_samples_in_data_record" )
        min             = my_edf.get_signal_item signal_index, "physical_min"
        max             = my_edf.get_signal_item signal_index, "physical_max"

        util.log signal_label + " has a sampling rate of " + sample_rate + " Hz."
        util.log signal_label + " has a min and max of " + min + ": " + max  + "."
```

#### Available header information

The following items are available in the EDF header and can be accessed by using ``get_header_item``.
 * version
 * patient_id
 * recording_id
 * start_date
 * start_time
 * number_of_bytes
 * reserved
 * num_data_records
 * duration_of_data_record
 * num_signals_in_data_record
 
These items are available using ``get_signal_item``. A signal index must be passed along as the first argument.
 * label
 * transducer_type
 * physical_dimensions
 * physical_min
 * physical_max
 * digital_min
 * digital_max
 * prefiltering
 * num_samples_in_data_record

## License
Three clause BSD. See [LICENSE](LICENSE).

## Thanks
Original work sponsored by [Younes Sleep Technologies](http://younessleeptechnologies.com/).
