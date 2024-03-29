# Webasyst-X-iOS

![webasyst-x-ios-ru-v1-showcase-dev](https://user-images.githubusercontent.com/889083/123943659-0d3f1000-d9a5-11eb-88d2-10eb1aa661cc.jpg)

Simple native boilerplate iOS app that authenticates users via Webasyst ID and enables direct access to all linked Webasyst accounts APIs.

**Creating a new application from scratch**

To create an application based on the Webasyst library, add ``pod webasyst`` to your pod-file and run pod install. After that, run ``pod install`` in the terminal. 

To import it into your application's controller, add ``import Webasyst`` in the controller's import list. 

To configure the library, create a file ``Webasyst.plist``, in the root folder of the project, with the following content:

```
"clientId": String // clientId of your application. Example: "72at75391ea785412a24f4568528ed49"
"host": String     // Webasyst ID auth domain: "www.webasyst.com"
"scope": String    // the scope required by your application (separated by dot). Example: "site.blog.shop"
```

Get your Webasyst ID auth client id here: https://www.webasyst.com/my/waid/apps/

pod Webasyst source code: https://github.com/1312inc/Webasyst-X-iOS-Pod

Webasyst ID API documentation: https://developers.webasyst.com/docs/features/webasyst-id-auth/resources-server-api/

**Running the example app with Xcode**

To run the app project:
1. Clone file `Webasyst X/Webasyst.plist.example.plist` -> `Webasyst X/Webasyst.plist`
2. Obtain your Webasyst ID client Id from Webasyst and save it into this new .plist file.
3. Run `pod install` in the terminal
4. Launch Xcode.
5. Open `WebasystX.xcworkspace`.
6. Launch the app!

**External Dependencies**

The following libraries are required for this application:

```
- pod RxSwift
- pod RxCocoa
- pod Moya
- pod Moya/RxSwift
- pod Webasyst (https://github.com/1312inc/Webasyst-X-iOS-Pod)
```

**Extensions**

The following are methods that are added as extensions to the UIViewController. 

*createLeftNavigationButton* - method for creation of a button to open settings list. It sets either the logo of the user's active installation or if there are no settings - puts a sandwich.

*setupLayoutTableView* - Sets the table with the output results. You must pass a UITableView with cells to work.

*setupEmptyView* - Method to display the View with an empty screen error (in case of empty server response)

*setupServerError* - Displays a server error. Requires error text in String format.

*setupNotConnectionError* - Displaying an error about a missing Internet connection

*setupLoadingView* - Display the loading indicator.

*setupInstallView* - Displays a message about the need to install the module in Webasyst. Requires the *InstallModuleViewDelegate* protocol to be passed to the ViewController comform method.

*setupWithoutInstallsView* - Displays a view with the ability to create a new account and the ability to connect to an existing account using a QR code or login/password.

**Usage**

*Generating code*

The Generamba template (https://github.com/strongself/Generamba) is created in the application.
You can use the terminal command ``generamba gen [Module Name] WebasystModule``.

To fix or edit a code generation template, use the template at the path */Templates/WebasystModule/Code
