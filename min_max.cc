#include <v8.h>
#include <node.h>

using namespace v8;

Handle<Value> min_max( const Arguments& args ){
	HandleScope scope;

	// Force 2 arguments.
	if( args.Length() < 2 ){
		ThrowException( Exception::TypeError( String::New( "Wrong number of arguments" ) ) );
		return scope.Close( Undefined( ) );
	}

	// Make sure that the 1st argument is an array..
	if( !args[0]->IsArray( ) ){
		ThrowException( Exception::TypeError( String::New( "1st argument must be an array." ) ) );
		return scope.Close( Undefined( ) );
	}

	// Make sure the 2nd argument is a number..
	if( !args[1]->IsNumber( ) ){
		ThrowException( Exception::TypeError( String::New( "2nd argument must be a number." ) ) );
		return scope.Close( Undefined( ) );
	}

	Local<Array>		input_array	= Local<Array>::Cast( args[0] );
	Local<Integer>		wanted_samples	= Local<Integer>::Cast( args[1] );

	// Iterate through the array and make sure that the elements stored in the array are themselves arrays.
	for( unsigned int k=0; k<input_array->Length( ); k++ ){
		Local<Object> element_obj = Local<Object>::Cast( input_array->Get( k ) );
		
		// Check if input_array->Get(k) contains x and y..
		if( !element_obj->Has( String::New("x") ) || !element_obj->Has( String::New( "y" ) ) ){
			ThrowException( Exception::TypeError( String::New( "x and y must be specified in each array element." ) ) );
			return scope.Close( Undefined( ) );
		}

		// Make sure x in a number..
		if( !element_obj->Get( String::New( "x" ) )->IsNumber( ) ){
			ThrowException( Exception::TypeError( String::New( "x must be a number." ) ) );
			return scope.Close( Undefined( ) );
		}

		// Check if y is a number..
		if( !element_obj->Get( String::New( "y" ) )->IsNumber( ) ){
			ThrowException( Exception::TypeError( String::New( "y is not a number." ) ) );
			return scope.Close( Undefined( ) );
		}
	}

	// At this point we know the input is valid. Lets start doing the sampling.

	unsigned int block_size = ( input_array->Length( ) / (unsigned int)wanted_samples->Value( ) );
	unsigned int num_blocks	= ( input_array->Length( ) / block_size );

	Local<Array> _r = Local<Array>( );
	
	for( unsigned int i=0; i<num_blocks; i++ ){

		// Get the slice of data
		Local<Array> _data = Local<Array>( );
		for( unsigned p = i*block_size; p<(i*block_size)+block_size; p++ ){
			_data->Set( p, input_array->Get( p ) );
		}

		signed int max = -32766;
		signed int min = 32767;

		// Run through all the values and determine max and min.
		for( unsigned int p=0; p<_data->Length( ); p++ ){
			Local<Object> obj	= Local<Object>::Cast( _data->Get( p ) );
			Local<Integer> y	= Local<Integer>::Cast(obj->Get( String::New( "y" ) ));
			signed int value	= y->Value( );
			if( value > max ){
				max = value;
			}
			if( value < min ){
				min = value;
			}
		}

		// Determine the new x value.. ( use the midpoint ).
		signed int new_x = Local<Integer>::Cast(_data->Get( (unsigned int)(block_size / 2 ) ))->Value( );

		// Define a new object to push to the return.
		Local<Object> _o = Local<Object>( );
		_o->Set( Handle<Value>(String::New( "x" )), Handle<Value>(Integer::New(new_x)) );
		
		// Define the array that contains max and min.
		Local<Array> _array	= Local<Array>( );
		_array->Set( Handle<Value>(Integer::New( 0 ) ), Handle<Value>(Integer::New(max)) );
		_array->Set( Handle<Value>(Integer::New( 1 ) ), Handle<Value>(Integer::New(min)) );

		// Set the y value of the object.
		_o->Set( String::New( "y" ), _array );

		// Push the new object to _r.
		_r->Set( i, _o );
	}
	
	return _r;
}

void Initialize (Handle<Object> target ){

	HandleScope scope;
	
	target->Set( String::New( "min_max" ), FunctionTemplate::New(min_max)->GetFunction( ) );
}

NODE_MODULE( min_max, Initialize )
