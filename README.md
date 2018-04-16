# iOS Public Calendars SDK

This is a **Swift** implementation of the iOS Public Calendar SDK.

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

The Calendar Store View Controller can also be initlaized using a title. This title will show in the navigation bar on the first page.

```Swift
// Presenting the Calendar Store View Controller with a given page
let calendarVC = CalendarStoreViewController(apiKey: "YOUR_API_KEY", pageIdentifer: "115673", title:"Featured")
present(calendarVC, animated: true, completion: nil)
```

You can also set a global `tintColor` for the whole Calendar Store, by setting it's `tintColor` property.

```Swift
// Presenting the Calendar Store View Controller with a given page
let calendarVC = CalendarStoreViewController(apiKey: "YOUR_API_KEY", pageIdentifer: "115673", title:"Featured")
calendarVC.tintColor = .black
present(calendarVC, animated: true, completion: nil)
```
