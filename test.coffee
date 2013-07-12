util	= require "util"

min_max	= require( "./build/Release/min_max" )

util.log util.inspect min_max.min_max( [ { "x": 412, "y": [ 512 ] } ], 5 )
