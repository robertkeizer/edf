util	= require "util"
fs	= require "fs"

class EDFFile

	_header_spec = [ { "name": "version", "length": 8 },
			 { "name": "patient_id", "length": 80 },
			 { "name": "recording_id", "length": 80 },
			 { "name": "start_date", "length": 8 },
			 { "name": "start_time", "length": 8 },
			 { "name": "number_of_bytes", "length": 8 },
			 { "name": "reserved", "length": 44 },
			 { "name": "num_data_records", "length": 8 },
			 { "name": "duration_of_data_record", "length": 8 },
			 { "name": "num_signals_in_data_record", "length": 4 } ]

	_signal_spec = [ { "name": "label", "length": 16 },
			 { "name": "transducer_type", "length": 80 },
			 { "name": "physical_dimensions", "length": 8 },
			 { "name": "physical_min", "length": 8 },
			 { "name": "physical_max", "length": 8 },
			 { "name": "digital_min", "length": 8 },
			 { "name": "digital_max", "length": 8 },
			 { "name": "prefiltering", "length": 80 },
			 { "name": "num_samples_in_data_record", "length": 8 } ]

	_signals	= [ ]

	constructor: ( @edf_path ) ->
		if not fs.existsSync @edf_path
			throw Error( "Invalid path specified: " + @edf_path )

		# Open a handle.
		@_handle	= fs.openSync @edf_path, "r"

		@_header_item	= { }
		@_signal_item	= { }

		# Run through and populate _signals using the specs.
		for i in [0..parseInt(@get_header_item( "num_signals_in_data_record"))]

			_specs = { }
			
			# Grab all the particular specs from the signal header..
			for spec in _signal_spec
				_specs[spec.name] = @get_signal_item i, spec.name

			_signals.push _specs

	get_header_offset: ( ) ->
		# 256 + ( number of signals  * 256 )
		256 + ( @get_header_item( "num_signals_in_data_record" ) * 256 )

	get_file_duration: ( ) ->
		@get_header_item( "duration_of_data_record" ) * @get_header_item( "num_data_records" )

	_get_header_spec: ( name ) ->

		position = 0

		# Iterate over all the spec objects.
		for x in _header_spec

			# Match found. Figure out the position of it, return.
			if x.name is name
				_o		= x
				_o["position"]	= position

				return _o

			# Not found, increment the position counter with the length
			# of the current spec.
			else
				position += x.length

	_get_signal_spec: ( signal_index, name ) ->

		# Start with a 256 offset since that is the length of the file header - signal header parts.
		position = 256

		for x in _signal_spec
			if x.name is name
				_o		= x

				# Add the position of the header..
				_o["position"]	= position + ( x.length * signal_index )

				return _o
			else
				# Since the total length of the header specification for the signal will depend on the 
				# number of signals, multiply accordingly.
				position += ( @get_header_item( "num_signals_in_data_record" ) * x.length )

	_get_signal_obj: ( signal_index ) ->
		# Get a signal spec object with gain and offset defined.
		_o		= _signals[signal_index]

		_o["gain"]		= ( parseFloat( _o.physical_max ) - parseFloat( _o.physical_min ) ) / ( parseFloat( _o.digital_max ) - parseFloat( _o.digital_min ) )
		_o["offset"]		= ( _o.physical_max / _o.gain ) - _o.digital_max
		_o["sample_rate"]	= _o.num_samples_in_data_record / @get_header_item "duration_of_data_record" 
		_o

	_get_buffer_slice: ( length, position ) ->
		# Returns a buffer of given length, filled with the 
		# data from the file at given position.

		k = new Buffer length
		fs.readSync @_handle, k, 0, length, position
		k

	get_header_item: ( name ) ->

		# If we already have a cached copy of it, return it.
		if @_header_item[name]?
			return @_header_item[name]

		# Get the spec for the given header item.
		spec = @_get_header_spec name

		# Set the instance wide cache to be the slice.. 
		@_header_item[name] = @_get_buffer_slice( spec.length, spec.position ).toString( ).trim( )

		# Return the now cached item.
		@_header_item[name]

	get_signal_item: ( signal_index, name ) ->

		# Simple mashing of the signal and name.
		_i = name + "_" + signal_index

		# If we have the cached item, simply return it.
		if @_signal_item[_i]?
			return @_signal_item[_i]
		
		# Gets the spec object.
		spec		= @_get_signal_spec signal_index, name

		# Gets the actual item. caches it, returns it.
		@_signal_item[_i]	= @_get_buffer_slice( spec.length, spec.position ).toString( ).trim( )
		@_signal_item[_i]

	get_signal_data: ( signal_index, start, end ) ->

		# If an array is passed in, recurse and return.
		if Array.isArray signal_index
			_r = [ ]
			for _signal_index in signal_index
				_r.push @get_signal_data _signal_index, start, end
			return _r

		# Force valid signal index..
		if not _signals[signal_index]?
			throw new Error "Invalid Signal index specified."

		# Get the block size in bytes.
		block_size = 0
		for _signal in _signals
			block_size += _signal.num_samples_in_data_record * @get_header_item( "duration_of_data_record" ) * 2
		
		# Figre out how many blocks we're going to need to read.
		total_seconds	= ( end - start )

		# Note that this will yield more data at the end if half a block is specified.
		blocks_to_read	= Math.ceil( total_seconds / @get_header_item( "duration_of_data_record" )  )

		# Figure out how far through the a data block we need to seek.
		# Since each particular channel can be a different length in bytes in each record.
		channel_seek = 0
		for _signal_index in [0...signal_index]
			channel_seek += @get_signal_item( _signal_index, "num_samples_in_data_record" ) * 2

		# The size each channel block we want. ( Collection of samples ).
		channel_size = @get_signal_item( _signal_index, "num_samples_in_data_record" ) * 2

		# Figure out how many records to skip based on what start time was specified.
		records_to_skip = start * @get_header_item( "duration_of_data_record" )

		# Helper variable that is the base offset for seeking..
		base_offset = ( records_to_skip * block_size ) + @get_header_offset( )

		# Get the signal object. This contains gain and offset.
		_signal = @_get_signal_obj signal_index

		_samples = [ ]
		# Iterate through all the blocks to read.
		for i in [0...blocks_to_read]

			# Get the channel block data by slicing through. 
			# Position is:
			#	base offset ( header+(records_to_skip*block_size) ) + (the current iteration * the size of each block) + how far into the block our channel is
			# Length is:
			#	the channel size.. ie number of samples in the data block for our channel multiplied by 2
			channel_block = @_get_buffer_slice channel_size, base_offset + (i*block_size) + channel_seek

			# This gets the time level of detail down to seconds..
			block_time	= ( records_to_skip + i ) * @get_header_item( "duration_of_data_record" )
			
			# Get all the samples out the channel block we just grabbed
			p = 0
			while p < channel_block.length

				# Get the raw data
				raw = channel_block.readInt16LE p

				# Normalize the data against the digital min / digital max.
				normal = ( raw + _signal.offset ) * _signal.gain

				# Use _signal.sample_rate, p, and block_time to determine the exact time for this sample.
				exact_time = block_time + (p/2)/_signal.sample_rate

				# Shove into samples
				_samples.push { "time": exact_time, "data": normal }

				# We just read 2 bytes, so increment our counter by 2.
				p += 2
			
		return _samples
		
exports.EDFFile = EDFFile
