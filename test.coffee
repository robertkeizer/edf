util	= require "util"

min_max	= require( "./build/Release/min_max" )

data = [ ]
for i in [1...10]
	data.push { "x": i, "y": i }

util.log util.inspect data
util.log util.inspect min_max.min_max data, 2
