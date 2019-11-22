#if defined(DM_PLATFORM_IOS)

#import <Mixpanel/Mixpanel.h>
#include "extension.h"

#import "ios/utils.h"

#define ExtensionInterface FUNCTION_NAME_EXPANDED(EXTENSION_NAME, ExtensionInterface)

// Using proper Objective-C object for main extension entity.
@interface ExtensionInterface : NSObject
@end

@implementation ExtensionInterface {
	bool is_initialized;
}

static ExtensionInterface *extension_instance;
int EXTENSION_INIT(lua_State *L) {return [extension_instance init_:L];}
int EXTENSION_TRACK_EVENT(lua_State *L) {return [extension_instance track_event:L];}
int EXTENSION_ADD_PUSH_TOKEN(lua_State *L) {return [extension_instance add_push_token:L];}

-(id)init:(lua_State*)L {
	self = [super init];

	is_initialized = false;

	return self;
}

-(bool)check_is_initialized {
	if (is_initialized) {
		return true;
	} else {
		dmLogInfo("The extension is not initialized.");
		return false;
	}
}

# pragma mark - Lua functions -

-(int)init_:(lua_State*)L {
	[Utils check_arg_count:L count:1];
	if (is_initialized) {
		dmLogInfo("The extension is already initialized.");
		return 0;
	}

	Scheme *scheme = [[Scheme alloc] init];
	[scheme string:@"token"];

	Table *params = [[Table alloc] init:L index:1];
	[params parse:scheme];

	NSString *token = [params get_string_not_null:@"token"];

	Mixpanel *mixpanel = [Mixpanel sharedInstanceWithToken:token];
	[mixpanel identify:mixpanel.distinctId];

	is_initialized = true;

	return 0;
}

-(int)track_event:(lua_State*)L {
	[Utils check_arg_count:L count:1];
	if (![self check_is_initialized]) {
		return 0;
	}

	Scheme *scheme = [[Scheme alloc] init];
	[scheme string:@"name"];
	[scheme table:@"properties"];
	[scheme string:@"properties.#"];

	Table *params = [[Table alloc] init:L index:1];
	[params parse:scheme];

	NSString *name = [params get_string_not_null:@"name"];
	NSDictionary *properties = [params get_table:@"properties"];

	if (properties) {
		[[Mixpanel sharedInstance] track:name properties:properties];
	} else {
		[[Mixpanel sharedInstance] track:name];
	}

	return 0;
}

-(int)add_push_token:(lua_State*)L {
	[Utils check_arg_count:L count:1];
	if (![self check_is_initialized]) {
		return 0;
	}

	if (lua_isstring(L, 1)) {
		size_t token_length;
		const char *token = luaL_checklstring(L, 1, &token_length);
		NSData *token_data = [NSData dataWithBytes:(const void *)token length:token_length];
		Mixpanel *mixpanel = [Mixpanel sharedInstance];
		[mixpanel.people addPushDeviceToken:token_data];
	}
	return 0;
}

@end

#pragma mark - Defold lifecycle -

void EXTENSION_INITIALIZE(lua_State *L) {
	extension_instance = [[ExtensionInterface alloc] init:L];
}

void EXTENSION_UPDATE(lua_State *L) {
	[Utils execute_tasks:L];
}

void EXTENSION_APP_ACTIVATE(lua_State *L) {
}

void EXTENSION_APP_DEACTIVATE(lua_State *L) {
}

void EXTENSION_FINALIZE(lua_State *L) {
    extension_instance = nil;
}

#endif
