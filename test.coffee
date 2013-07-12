util	= require "util"

min_max	= require( "./build/Release/min_max" )

data = [ ]
for i in [0...10]
	data.push { "x": i, "y": i }

for i in [0...10]
	util.log "In " + i + " chunks.."
	util.log util.inspect min_max.min_max data, i
