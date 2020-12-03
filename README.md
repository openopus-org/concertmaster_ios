# concertmaster_ios

[Concertmaster](https://getconcertmaster.com) is a classical music front-end for Spotify.

It's splitted in several projects. **This one provides only the iOS app.** (There's a [web player](https://github.com/openopus-org/concertmaster_player) as well!) All data comes from an API which, in its turn, uses the Spotify API. Spotify doesn't allow multiple apps using the same API key, so you can't fork only the app and use the Concertmaster API - you have to fork both.

## Usage

It's an iOS app. When it's ready, it'll be available on the App Store.

The player itself is full of features, so there is a [wiki](https://getconcertmaster.com/help) explaining them all.

## How to build

Concertmaster uses SwiftUI, so you'll need MacOS Catalina and XCode 11 to build it (and iOS 13 to test it on a device).

## Contributing with code
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## Contributing with data
Concertmaster composers and works information come from [Open Opus](https://openopus.org), a free, wiki-style, open source database of classical music metadata. You can review existing info or add new entries to the database - any help will be appreciated!

## Contributing with money
Concertmaster is free to use but it runs on web servers that cost us money. You can help us by supporting us on [Patreon](https://www.patreon.com/openopus) - any amount is more than welcome!

## License
[GPL v3.0](https://choosealicense.com/licenses/gpl-3.0/)
