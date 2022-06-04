# cobi_flutter_share_platform_interface

A common platform interface for the [`cobi_flutter_share`][1] plugin.

This interface allows platform-specific implementations of the `cobi_flutter_share`
plugin, as well as the plugin itself, to ensure they are supporting the
same interface.

# Usage

To implement a new platform-specific implementation of `cobi_flutter_share`, extend
[`CobiFlutterSharePlatform`][2] with an implementation that performs the
platform-specific behavior, and when you register your plugin, set the default
`CobiFlutterSharePlatform` by calling
`CobiFlutterSharePlatform.instance = CobiFlutterShareMyPlatform()`.

# Note on breaking changes

Strongly prefer non-breaking changes (such as adding a method to the interface)
over breaking changes for this package.

See https://flutter.dev/go/platform-interface-breaking-changes for a discussion
on why a less-clean interface is preferable to a breaking change.

[1]: ../cobi_flutter_share
[2]: lib/src/cobi_flutter_share_platform_interface.dart