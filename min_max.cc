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
	
	return String::New( "Foobar" );
}

void Initialize (Handle<Object> target ){

	HandleScope scope;
	
	target->Set( String::New( "min_max" ), FunctionTemplate::New(min_max)->GetFunction( ) );
}

NODE_MODULE( min_max, Initialize )
