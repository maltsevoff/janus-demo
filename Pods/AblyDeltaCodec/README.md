# AblyDeltaCodec

<a href="https://github.com/ably/delta-codec-cocoa/actions">
  <img src="https://github.com/ably/delta-codec-cocoa/workflows/Build/badge.svg" />
</a>

Cocoa **VCDiff decoder**.

Uses [Xdelta version 3](https://github.com/ably-forks/xdelta/tree/xdelta-cocoa), a C library - forked by Ably - for delta compression using VCDIFF/[RFC 3284](https://tools.ietf.org/html/rfc3284) streams.

## Objective-C example

```objc
@import AblyDeltaCodec;

NSError *error;
ARTDeltaCodec *codec = [[ARTDeltaCodec alloc] init];
[codec setBase:baseData withId:@"m1"];
NSData *outputData = [codec applyDelta:deltaData deltaId:@"m2" baseId:@"m1" error:&error];

// Output data is an utf-8 string:
NSString *output = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
```

## Swift example

```swift
import AblyDeltaCodec

let codec = ARTDeltaCodec()
codec.setBase(baseData, withId: "m1")

do {
    let outputData = try codec.applyDelta(deltaData, deltaId: "m2", baseId: "m1")
    // Output data is an utf-8 string:
    let output = String(data: outputData, encoding: .utf8)
}
catch {
    print(error)
}
```

# API Reference

- [class `isDelta`](#class-isdelta)
- [class `applyDelta`](#class-applydelta)
- [`setBase`](#setbase)
- [`applyDelta`](#applydelta)

## Stateless

### class isDelta

> ###### DECLARATION
>
> **Objective-C**
>
> +(BOOL)isDelta:delta;
>
> **Swift**
>
> class func isDelta(_ delta: Data) -> Bool

**Arguments**:

* `delta`: `NSData`/`Data` (is a binary encoded as **vcdiff**, as specified in RFC 3284.)

**Return Value**:

Returns a `BOOL`/`Boolean` telling if it's a valid delta or not.

### class applyDelta

> ###### DECLARATION
>
> **Objective-C**
>
> +(NSData *)applyDelta:current previous:previous error:error;
>
> **Swift**
>
> class func applyDelta(_ current: Data, previous: Data) -> Data (throws)

**Arguments**:

* `current`: `NSData`/`Data` (is the binary encoding of the information needed to transform the source to the target. It is encoded as vcdiff, as specified in RFC 3284.)
* `previous`: `NSData`/`Data` (is the group of bytes to transform into the target.)
* `error`: `NSError` (Objective-C only) (is the error object when something goes wrong. It's nullable so it's optional.)

**Return Value**:

Returns a `NSData`/`Data` object of the target. It can return `nil`.

## Stateful

### setBase

> ###### DECLARATION
>
> **Objective-C**
>
> -(void)setBase:base withId:baseId;
>
> **Swift**
>
> func setBase(_ base: Data, withId baseId: Data)

**Arguments**:

* `base`: `NSData`/`Data` (is the group of bytes to transform into the target. This is probably an old, cached version.)
* `baseId`: `NSString`/`String` (is an identifier of the base.)

**Return Value**:

Returns nothing.

### applyDelta

> ###### DECLARATION
>
> **Objective-C**
>
> -(NSData *)applyDelta:delta deltaId:deltaId baseId:baseId error:error;
>
> **Swift**
>
> func applyDelta(_ delta: Data, deltaId deltaId: String, baseId baseId: String) -> Data (throws)

**Arguments**:

* `delta`: `NSData`/`Data` (is the binary encoding of the information needed to transform the source to the target. It is encoded as vcdiff, as specified in RFC 3284.)
* `deltaId`: `NSString`/`String` (is an identifier of the delta.)
* `baseId `: `NSString`/`String` (is an identifier of the base used to verify if it matches with the current assigned base.)
* `error`: `NSError` (Objective-C only) (is the error object when something goes wrong. It's nullable so it's optional.)

**Return Value**:

Returns a `NSData` object of the target. It can return `nil`.

**Acknowledgments**:

The `delta` will be the new `base`.

## We use both `Xcodeproj` and `Package.swift`

We currently have both these files, each contain their own build configuration/ settings. This means one build may succeed whereas the other may fail. This is required because Carthage and Cocoapods use `Xcodeproj` but SPM uses the `Package.swift`.

## Release Process

For each release, the following needs to be done:

* Create a new branch release/x.x.x (where x.x.x is the new version number) from the main branch
* Bump the version numbers in `AblyDeltaCodec.podspec` and in the Xcode project. Commit this.
* Run [`github_changelog_generator`](https://github.com/github-changelog-generator/github-changelog-generator) to automate the update of the [CHANGELOG](./CHANGELOG.md). This may require some manual intervention, both in terms of how the command is run and how the change log file is modified. Your mileage may vary:
    * The command you will need to run will look something like this: `github_changelog_generator -u ably -p ably-cocoa --since-tag 1.2.5 --output delta.md`
    * Using the command above, `--output delta.md` writes changes made after `--since-tag` to a new file
    * The contents of that new file (`delta.md`) then need to be manually inserted at the top of the `CHANGELOG.md`, changing the "Unreleased" heading and linking with the current version numbers
    * Also ensure that the "Full Changelog" link points to the new version tag instead of the `HEAD`
    * Commit this change: `git add CHANGELOG.md && git commit -m "Update change log."`
* Push both commits to origin: `git push -u origin release/x.x.x`
* Make a pull request against `main` and await approval of reviewer(s)
* Once approved and/or any additional commits have been added, merge the PR
* Steps to perform *before* pushing a release tag up:
  * Build the Swift Package locally: Run `swift build` or `open Package.swift` and build the library with Xcode. This ensures this library will build for applications using Swift Package Manafer.
  * Build the Xcode Project: `open DeltaCodec.xcodeproj` and build the library with Xcode. This ensures the library will build for applications using Carthage.
  * Run `pod lib lint` to validate the Podspec and ensure the library will build for Cocoapods.
  * Warning: Currently, there are 14 warnings related to the `xdelta3` submodule. We run `pod lib lint --allow-warnings` instead.
  * Test the library integration in projects: SPM (in an Xcode project), Cocoapods (in a podfile) and Carthage (in a cartfile).
* If any fixes are needed (e.g. the lint fails with warnings) then either commit them to `main` branch now if they are simple warning fixes or perhaps consider raising a new PR if they are complex or likely to need review.
* Create a tag for this version number using `git tag x.x.x`
* Push the tag using `git push origin x.x.x`
* Release an update for CocoaPods using `pod trunk push AblyDeltaCodec.podspec --allow-warnings`. Details on this command, as well as instructions for adding other contributors as maintainers, are at [Getting setup with Trunk](https://guides.cocoapods.org/making/getting-setup-with-trunk.html) in the [CocoaPods Guides](https://guides.cocoapods.org/)
* Add to [releases](https://github.com/ably/delta-codec-cocoa/releases)
  * refer to previous releases for release notes format
* Test the integration of the library in a Xcode project using Carthage and CocoaPods using the [installation guide](https://github.com/ably/ably-cocoa#installation-guide)