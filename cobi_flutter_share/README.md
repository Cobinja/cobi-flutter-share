This plugin makes the Android the share feature available to Flutter for incoming shares.
## Features
- general shares
- specific share targets
## Usage
To use this plugin you need to add the following to the main activity in your manifest.xml on Android.
The activity needs:
```xml
    android:exported="true"
```
and 
```xml
<intent-filter>
	<action android:name="android.intent.action.SEND" />
	<category android:name="android.intent.category.DEFAULT" />
	<data android:mimeType="*/*" />
</intent-filter>
```
To receive multiple files in one go, add the following:
```xml
<intent-filter>
	<action android:name="android.intent.action.SEND_MULTPILE" />
	<category android:name="android.intent.category.DEFAULT" />
	<data android:mimeType="*/*" />
</intent-filter>
```
You need one ```intent-filter``` filter per ```mimeType``` filter.

### Share targets

For share targets (e.g. for specific contacts) you need to create an xml file in your resource folder, e.g. like this one:
```xml
<?xml version="1.0" encoding="utf-8"?>
<shortcuts xmlns:android="http://schemas.android.com/apk/res/android">
	<share-target  android:targetClass="de.cobinja.example.MainActivity">
		<data android:mimeType="text/plain" />
		<category android:name="de.cobinja.CATEGORY_ONE" />
	</share-target>
</shortcuts>
```
This xml file has to be referenced for the activity in your Manifest.xml:
```xml
<meta-data
  android:name="android.app.shortcuts"
  android:resource="@xml/shortcuts" />
```

For more information on how to compose these shortcut xml files please see [Android's documentation](https://developer.android.com/training/sharing/receive#declare-share-target)

**Please also see the included example.**
## Additional information
This is a federated plugin, so implementations for platforms other than Android are welcome. Due to my lack of Apple hardware I cannot implement it for their products myself.
