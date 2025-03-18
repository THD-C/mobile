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

In order to use translation provide:

```
  Text(AppLocalizations.of(context).translate('welcome'))
```

where `welcome` is the key from the `json` translation file.

> :warning: `AppLocalizations.of(context).translate('welcome')` will only work inside `Text` widget
