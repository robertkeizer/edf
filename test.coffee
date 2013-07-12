util	= require "util"

min_max	= require( "./build/Release/min_max" )

util.log util.inspect min_max.min_max( [ { "x": 412, "y": [ 512 ] }, { "x": 12, "y": [ 12, 42 ] } ], 1 )
