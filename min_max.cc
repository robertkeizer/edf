#include <v8.h>
#include <node.h>
#include <node_version.h>

using namespace node;
using namespace v8;

static Handle<Value> min_max( const Arguments& args ){
	HandleScope scope;
	
	return String::New( "what?" );
}

void Initialize (Handle<Object> target ){

	HandleScope scope;
	
	target->Set( String::New( "min_max" ), FunctionTemplate::New(min_max)->GetFunction( ) );
}

NODE_MODULE( min_max, Initialize );
