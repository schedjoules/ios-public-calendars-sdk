# iOS Public Calendars SDK

This is the **Swift** implementation of the iOS Public Calendar SDK.

## Installation

You can install the SDK through `CocoaPods`. Add this line to your `.podfile`:

`pod 'SchedJoulesSDK'`


## Usage

To present the Calendar Store, you first have to initialize it using the API Key we provided you.

Mail us at support@schedjoules.com to request you personal API key if you don't have any yet. Until then you can use the test API key **0443a55244bb2b6224fd48e0416f0d9c**

### Example

```Swift
// Presenting the Calendar Store View Controller
let calendarVC = CalendarStoreViewController(apiKey: "YOUR_API_KEY")
present(calendarVC, animated: true, completion: nil)
```

Optionally, you can also pass a `pageIdentifier` to start directly from a page rather than the home.

```Swift
// Presenting the Calendar Store View Controller with a given page
let calendarVC = CalendarStoreViewController(apiKey: "YOUR_API_KEY", pageIdentifer: "115673")
present(calendarVC, animated: true, completion: nil)
```

### Customization options

The default initializer for the Calendar Store includes parameters for customization. 
```Swift
init(apiClient: SchedJoulesApi, pageIdentifier: String?, title: String?, largeTitle: Bool = true, tintColor: UIColor = ColorPalette.red)
```
Please refer to the [inline code documentation](https://github.com/schedjoules/ios-public-calendars-sdk/blob/master/SDK/CalendarStoreViewController.swift#L68) for further details.

