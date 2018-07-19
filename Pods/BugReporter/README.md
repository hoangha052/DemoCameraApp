# Bug Reporter

## What is this?
This tool lets testers create issues (subject, priority, parent tasks, optional description included) and upload to Redmine directly from iOS devices

## Requirements
- iOS 9.0+

## Installation
### CocoaPods ###
```
pod 'BugReporter', :git => 'https://github.com/nextc/bug-reporter.git', :tag => '2.2.5'
```
Note that the tag version must be the [Latest Release](https://github.com/nextc/bug-reporter/releases).

## Usage
### iOS team
**Initialize**
1. Go to *AppDelegate*
2. In *application(_:didFinishLaunchingWithOptions:)*, paste this line
```
MGRedmineManager.setup(projectName: \(projectName), testEnabled: true)
```
Note that the `testEnabled` parameter can be retrieved from `Niche-Info.plist`

3. Make sure `TestMode` key in `Niche-Info.plist` is **YES** in order to activate this tool. 
   Run `sh rollout.sh` command to configure this key.

**Logging**

Where you make an API request, call the function to log the last API info you called
```
MGRedmineLogging.updateAPIInfo(deviceInfo: String, apiURL: String, apiParams: String, responseCode: String, response: String, method: String)
```
Note that in the screen you create issue, there is a switch to control whether the latest API Info is included in the issue's description

### QA team ###

![GIF](https://media.giphy.com/media/26xiwj3qG7kkEIevC/giphy.gif)
