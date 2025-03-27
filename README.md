# mobile

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Start app

> :caution: Android Studio must be installed!

Run in order to get added/updated/deleted dependencies:

```
flutter pub get
```

To start the application launch emulator:

```
flutter emulators --launch <emulator_ID>
```

for example:

```
flutter emulators --launch Pixel_7
```

### Translations

In [assets/lang](/assets/lang) are stored languages in `json` format.
If you have new label then manually add translation in `en/pl.json` file:

```json
{
  "welcome": "Witamy ponownie"
}
```

and the equivalent in other languages ie `pl`:

```json
{
  "welcome": "Welcome back"
}
```

where the `key` will be used to retrieve the translation.
After that **you must restart the app via** `flutter run` command.

In order to use translation provide:

```
  Text(AppLocalizations.of(context).translate('welcome'))
```

where `welcome` is the key from the `json` translation file.

> :warning: `AppLocalizations.of(context).translate('welcome')` will only work inside `Text` widget

Recommended key naming convention:

```json
{
  "<component|widget|page|view>_<in_snake_case_name_whatever_you_want>"
}
```

After adding new translations the application must be restarted.
