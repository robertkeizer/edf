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

	Local<Array> input_array = Local<Array>::Cast( args[0] );

	// Iterate through the array and make sure that the elements stored in the array are themselves arrays.
	for( unsigned int k=0; k<input_array->Length( ); k++ ){
		Local<Object> element_obj = Local<Object>::Cast( input_array->Get( k ) );
		
		// Check if input_array->Get(k) contains x and y..
		if( !element_obj->Has( String::New("x") ) || !element_obj->Has( String::New( "y" ) ) ){
			ThrowException( Exception::TypeError( String::New( "x and y must be specified in each array element." ) ) );
			return scope.Close( Undefined( ) );
		}

		// Check if y is an array.
		if( !element_obj->Get( String::New( "y" ) )->IsArray( ) ){
			ThrowException( Exception::TypeError( String::New( "y is not an array." ) ) );
			return scope.Close( Undefined( ) );
		}

		// Make sure that all the elements of y are numbers..
		Local<Array> y_array = Local<Array>::Cast( element_obj->Get( String::New( "y" ) ) );
		for( unsigned int m=0; m<y_array->Length(); m++ ){
			if( !y_array->Get( m )->IsNumber( ) ){
				ThrowException( Exception::TypeError( String::New( "values of y must be numbers." ) ) );
				return scope.Close( Undefined( ) );
			}
		}
	}

	// At this point we know the input is valid.
	
	
	return String::New( "Foobar" );
}

void Initialize (Handle<Object> target ){

	HandleScope scope;
	
	target->Set( String::New( "min_max" ), FunctionTemplate::New(min_max)->GetFunction( ) );
}

NODE_MODULE( min_max, Initialize )
