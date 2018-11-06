# ios-agent

CodeScope agent for iOS (Objective-C and Swift)


## Usage

1. Install via [CocoaPods](https://cocoapods.org), adding the `Codescope` pod to the test target in your `Podfile`. For example:

```
target 'MyAppTests' do
  pod 'Codescope'
end
```

2. Configure your test target and CI build environment variables, depending on your provider:

* [Jenkins](#jenkins)
* [CircleCI](#circleci)

<a name="jenkins"></a>**Jenkins**

Add the following environment variables to your test target ([instructions](https://help.apple.com/xcode/mac/10.1/index.html?localePath=en.lproj#/dev3ec8a1cb4)):

| Key                      | Value                       |
|--------------------------|-----------------------------|
| `CODESCOPE_APIKEY`       | `$(CODESCOPE_APIKEY)`       |
| `CODESCOPE_API_ENDPOINT` | `$(CODESCOPE_API_ENDPOINT)` |
| `CODESCOPE_COMMIT_SHA`   | `$(GIT_COMMIT)`             |
| `CODESCOPE_REPOSITORY`   | `$(GIT_URL)`                |
| `CODESCOPE_SOURCE_ROOT`  | `$(WORKSPACE)`              |

After this, configure your Jenkins build to add the following environment variables:

| Key                      | Value                                           |
|--------------------------|-------------------------------------------------|
| `CODESCOPE_APIKEY`       | The API key generated from the CodeScope UI     |
| `CODESCOPE_API_ENDPOINT` | The API endpoint of your CodeScope installation |


<a name="circleci"></a>**CircleCI**

Add the following environment variables to your test target ([instructions](https://help.apple.com/xcode/mac/10.1/index.html?localePath=en.lproj#/dev3ec8a1cb4)):

| Key                      | Value                         |
|--------------------------|-------------------------------|
| `CODESCOPE_APIKEY`       | `$(CODESCOPE_APIKEY)`         |
| `CODESCOPE_API_ENDPOINT` | `$(CODESCOPE_API_ENDPOINT)`   |
| `CODESCOPE_COMMIT_SHA`   | `$(CIRCLE_SHA1)`              |
| `CODESCOPE_REPOSITORY`   | `$(CIRCLE_REPOSITORY_URL)`    |
| `CODESCOPE_SOURCE_ROOT`  | `$(CIRCLE_WORKING_DIRECTORY)` |

After this, configure your CircleCI project to add the following environment variables ([instructions](https://circleci.com/docs/2.0/env-vars/#setting-an-environment-variable-in-a-project)):

| Key                      | Value                                           |
|--------------------------|-------------------------------------------------|
| `CODESCOPE_APIKEY`       | The API key generated from the CodeScope UI     |
| `CODESCOPE_API_ENDPOINT` | The API endpoint of your CodeScope installation |
