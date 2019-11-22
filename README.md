# Mixpanel Extension for Defold

This extension wraps Mixpanel SDK for iOS (3.5.0). On other platforms this extension provides stub functions.

# API reference

## mixpanel.init(params)

Call this function before invoking any other functions.

### `params` reference

- `token`, string, required. API key.

### Syntax

```language-lua
mixpanel.init{
	token = 'YOUR TOKEN HERE'
}
```
___
## mixpanel.track_event(params)

Track an event via the SDK.

### `params` reference

- `name`, string, required. Event name.
- `properties`, table, optional. A key-value set of extra event properties. Keys and values must be strings.

### Syntax

```language-lua
mixpanel.track_event{
	name = 'event_name',
	properties = {
		key1 = 'value1',
		key2 = 'value2'
	}
}
```
## mixpanel.add_push_token(token)

Adds a push device token for push notifications.

- `token`, string. Device token.

### Syntax

```language-lua
mixpanel.add_push_token(token)
```
