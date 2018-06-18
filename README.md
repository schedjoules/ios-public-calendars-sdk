# iOS Public Calendars SDK

This is the **Swift** implementation of the iOS Public Calendar SDK.

## Installation

You can install the SDK through **CocoaPods**. 

`pod 'SchedJoulesSDK'`


## Usage

To present the Calendar Store, you first have to initialize it using the API Key we provided you.

Mail us at support@schedjoules.com to request you personal API key if you don't have one yet. Until then you can use the test API key **0443a55244bb2b6224fd48e0416f0d9c**

### Example

If you would like to present our fully-featured Calendar Store, use the `CalendarStoreViewController` class:

```Swift
// Presenting the Calendar Store View Controller
let calendarVC = CalendarStoreViewController(apiKey: "YOUR_API_KEY")
present(calendarVC, animated: true, completion: nil)
```

Optionally, if you would only like to use the Calendar Store to present a single page, use the `CalendarStoreSinglePageViewController` class:

```Swift
let calendarVC = CalendarStoreSinglePageViewController(apiKey: "YOUR_API_KEY", pageIdentifer: "115673", title: "Featured")
present(calendarVC, animated: true, completion: nil)
```
