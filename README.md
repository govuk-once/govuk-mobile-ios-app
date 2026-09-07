# GOV.UK - iOS mobile application

## Getting started:

### Install Xcode
The application will run on several Xcode versions. The working version of the project can be found [here](.xcode-version)

### Resolve packages
Before the app will build, you will need to navigate to `File -> Packages -> Resolve Package Versions` to install required dependencies.

### Run
<kbd>cmd</kbd> + <kbd>R</kbd> <be>

>[!Note]
>You will need to have an Apple developer account to run the project on a physical device, but it can run on a simulator.

## Unit tests and Snapshot tests
The application has several unit tests and snapshot tests.  
Unit tests do not depend on a specific simulator, but the snapshot tests do.

### Snapshot test requirements

To successfully run snapshot tests:
- [git-lfs](https://git-lfs.com/) must be installed
- the snapshot tests must be run on a specific simulator

The current device requirement can be found [here](/Fastlane/.build.yml) under `[scan][devices]`

## Linting

### SwiftLint

The application uses SwiftLint for linting swift code. Rules can be found [here](.swiftlint.yml)
If you want swiftlint to highlight issues in Xcode, make sure you have it installed. You can do this using [Homebrew](https://brew.sh/)

`brew install swiftlint`
