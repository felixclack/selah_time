fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios create_app

```sh
[bundle exec] fastlane ios create_app
```

Create the App Store Connect app record

### ios register_screentime

```sh
[bundle exec] fastlane ios register_screentime
```

Enable Screen Time (Family Controls) entitlement on app and extensions

### ios register_app_group

```sh
[bundle exec] fastlane ios register_app_group
```

Create and associate App Group for app + extensions, and enable App Groups capability

### ios tests

```sh
[bundle exec] fastlane ios tests
```

Run unit tests in the simulator (SelahSim target)

### ios testflight

```sh
[bundle exec] fastlane ios testflight
```

Build and upload to TestFlight

### ios metadata

```sh
[bundle exec] fastlane ios metadata
```

Upload metadata/screenshots without uploading a new build

### ios appstore

```sh
[bundle exec] fastlane ios appstore
```

Build and upload to App Store (optionally submit for review)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
