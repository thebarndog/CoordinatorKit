# CoordinatorKit

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](#carthage) [![CocoaPods compatible](https://img.shields.io/cocoapods/v/Feathers.svg)](#cocoapods) [![GitHub release](https://img.shields.io/github/release/startupthekid/CoordinatorKit.svg)](https://github.com/startupthekid/CoordinatorKit/releases) ![Swift 3.0.x](https://img.shields.io/badge/Swift-3.0.x-orange.svg) ![platforms](https://img.shields.io/badge/platform-iOS-lightgrey.svg) [![Build Status](https://travis-ci.org/startupthekid/CoordinatorKit.svg?branch=master)](https://travis-ci.org/startupthekid/CoordinatorKit)

## Installation

### Cocoapods
```
pod `CoordinatorKitSwift`
```

### Carthage

Add the following line to your Cartfile:

```
github "startupthekid/CoordinatorKit"
```

## What is CoordinatorKit?

CoordinatorKit is an iOS architecture framework written in Swift that provides an alternative design pattern (the coordinator pattern) for building your applications. Simple, robust and extensible, CoordinatorKit allows you to streamline your application's architecture.

## Coordinators

Coordinators are PONSOs (Plain Old NSObjects), no different than any other object. Think of coordinators has view controllers without the views. Coordinators are true controller objects (sometimes referred to as Directors) and can take over the myriad of responsibilities of `UIViewController` which we can now treat as part of the view layer.

What does a coordinator look like exactly?

```swift
class AppDelegate {
  let coordinator = AppCoordinator()

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
  coordinator.start()
  }
}

class AppCoordinator: Coordinator {

  public override func start() {
    super.start()
    if session.isUserLoggedIn {
      start(coordinator: MainExperienceCoordinator())
    } else {
      start(coordinator: LoginCoordinator())
    }
  }

}

```

Think of each coordinator as encapsulating an experience or multiple. At the root of every application sits the `AppCoordinator` which is retained by the `AppDelegate`. The application coordinator can then spawn off child coordinators (`LoginCoordinator` and `MainExperienceCoordinator`) based on the state of the user. Notice we haven't touched any view code yet, coordinators just contain pure business logic. This is a key advantage of using coordinators; they let you separate your views from everything else.
Interestingly, coordinators are not limited to having only one active child. A `UISplitViewController` analogous coordinator class might have several children active at once, each which might be managing their own children and view controllers. In the end, you're left with a tree of coordinators, with `ApplicationCoordinator` at the root of it all and children spawning out from there.

### Children

To add and remove children from a coordinator, a set of convenience methods have been provided:

```swift
// MARK: - Child Coordinators

    /// Start a child coordinator.
    ///
    /// This method should *always* be used rather than calling `coordinator.start()`
    /// directly. Starting a child coordinator has two important side-effects:
    /// 1) The parent coordinator adds itself as a delegate of the child.
    /// 2) The coordinator gets inserted into the set of children.
    ///
    /// - Parameter coordinator: Coordinator to start.
    public final func start<C: Coordinator>(coordinator: C) {
        guard !hasChild(coordinator) else { return }
        coordinator.delegate += self
        children.insert(coordinator)
        coordinator.start()
    }

    /// Stops the given child coordinator.
    ///
    /// This method *must* be used instead of calling `coordinator.stop()` directly.
    /// Stopping a child coordinator has two important side-effects:
    /// 1) The parent removes itself as a delegate.
    /// 2) The coordinator is removed from the list of children.
    ///
    /// - Parameter coordinator: Coordinator to stop.
    public final func stop<C: Coordinator>(coordinator: C) {
        guard hasChild(coordinator) else { return }
        coordinator.delegate -= self
        children.remove(coordinator)
        coordinator.stop()
    }

    /// Pauses the given child coordinator.
    ///
    /// This method is a wrapper function for convenience and consistency.
    ///
    /// - Parameter coordinator: Coordinator to pause.
    public final func pause<C: Coordinator>(coordinator: C) {
        guard hasChild(coordinator) else { return }
        guard !coordinator.isPaused else { return }
        coordinator.pause()
    }

    /// Resumes the given child coordinator.
    ///
    /// This method is a wrapper function for convenience and consistency.
    ///
    /// - Parameter coordinator: Coordinator to resume.
    public final func resume<C: Coordinator>(coordinator: C) {
        guard hasChild(coordinator) else { return }
        guard coordinator.isPaused else { return }
        coordinator.resume()
    }

```

It is crucial to use these methods to add and remove children and to not call `coordinator.start()` or any of the other methods directly. The only coordinator on which you call them directly on is the `AppCoordinator` object.

### State

Coordinators have three states, `inactive`, `paused`, and `active`. Coordinator state can be manipulated by using one of four methods:
- `start` - Start the coordinator and begin any work
- `stop` - Stop the coordinator and stop all work.
- `pause` - Pause the coordinator and throttle any active work.
- `resume` - Resume and continue work.

Each of these four methods is subclassable and provides hooks into the coordinator lifecycle for performing work and taking any necessary actions. For example, the `LoginCoordinator` from our example above might look like this:

```swift
class LoginCoordinator: Coordinator {
  public override func start() {
    super.start()
    if session.hasCachedEmail {
      viewController.loginTextField.text = session.cachedEmail
    }
  }
}
```

**Note:** You must always call super first in every overriden method i.e. `super.start()`.

### Scene Coordinators

Scene coordinators are a specialized subclass of `Coordinator`. A scene coordinator represents a single screen or view in your application. They maintain a 1:1 relationship with a view controller.

Scene coordinators look like:

```swift
open class SceneCoordinator<Controller: UIViewController>: Coordinator {

  public var rootViewController: Controller

  required public init() {
    rootViewController = Controller()
    super.init()
  }

}
```

Scene coordinators will be the majority of use-cases throughout your applications. Remember the `LoginCoordinator` from before? A more correct implementation would look like:

```swift
class LoginCoordinator: SceneCoordinator<LoginViewController> {
  public override func start() {
    super.start()
    if session.hasCachedEmail {
      rootViewController.loginTextField.text = session.cachedEmail
    }
  }
}
```

Now the login coordinator automatically has a reference to `LoginViewController` and because of the generic constraint in `SceneCoordinator`, `rootViewController` has the type of `LoginViewController`, not `UIViewController` meaning in each specialized subclass, autocompletion works as expected.

### Communication

You may be wondering, if I haven't lost you yet, about how children communicate with their parents. The parent -> child relationship is clear, parents spin up child-coordinators based on internal business logic but the reverse is a bit more blurry. How would the login coordinator tell the app coordinator there was a successful login so it can be dismissed and the main experience presented? The answer: delegation.

Coordinators come with a `delegate` property that can be used to shuttle messages throughout the system.

```swift
/// Coordinator delegate protocol. Used to notify listeners
/// of state changes in the coordinator.
public protocol CoordinatorDelegate: class {

    /// Notifies the delegate that the coordinator has been started.
    ///
    /// - Parameter coordinator: Coordinator that was started.
    func coordinatorDidStart(_ coordinator: Coordinator)

    /// Notifies the delegate that the coordinator has been stopped.
    ///
    /// - Parameter coordinator: Coordinator that was stopped.
    func coordinatorDidStop(_ coordinator: Coordinator)

    /// Notifies the delegate that the coordinator has been paused.
    ///
    /// - Parameter coordinator: Coordinator that was paused.
    func coordinatorDidPause(_ coordinator: Coordinator)

    /// Notifies the delegate that the coordinator has been resumed.
    ///
    /// - Parameter coordinator: Coordinator that was resumed.
    func coordinatorDidResume(_ coordinator: Coordinator)

}
```

The `Coordinator` base class automatically conforms to this protocol and provides empty implementations that you can override and listen for events. `SceneCoordinator`s also have a delegate, `SceneCoordinatorDelegate`.

```swift
/// Delegate protocol for SceneCoordinators. It extends the `CoordinatorDelegate` protocol.
public protocol SceneCoordinatorDelegate: CoordinatorDelegate {

    /// Notifies the delegate that the given coordinator is requesting to be dismissed.
    ///
    /// - Parameter coordinator: Coordinator that's requesting dismissal.
    func coordinatorDidRequestDismissal<C: UIViewController>(_ coordinator: SceneCoordinator<C>)

}
```

Notice here how `SceneCoordinatorDelegate` conforms to `CoordinatorDelegate`. That means anything that conforms to `SceneCoordinatorDelegate` (which is all scene coordinators by default), also conforms to `CoordinatorDelegate`. This simple but powerful distinction means that the `delegate` property can be extended and specialized all without the need for extra properties.

Confusing? You bet. Here's an example that might help clear things up. Remember our old friend `LoginCoordinator`? Here's how it might communicate with its parent.

```swift
public protocol LoginCoordinatorDelegate: SceneCoordinatorDelegate {

  func coordinatorDidLoginSuccessfully()

  func coordinatorDidFailToLogin(error: Error)

}
```

`AppCoordinator` would then add itself as a delegate and implement those methods to listen to know when to present an error modal or the main experience. Fortunately, every time a coordinator starts a child using `start(coordinator: coordinator)`, it automatically adds itself as the child's delegate.

Also worth noting, coordinators do not use a typically 1:1 delegate relationship. Instead, delegates are wrapped in the `MulticastDelegate` struct which allows for multiple listeners. Let that sink in for a minute. That means, each coordinator can have from 0 to n observers which immediately makes the entire system far more flexible. One coordinator can listen and log events while another coordinator presents and dismisses views.

To add yourself as a delegate:

```swift
let coordinator = MyFunCoordinator()
coordinator.delegate += self
```

To remove:

```swift
coordinator.delegate -= self
```

When you need to invoke a method on the delegates to notify all the listeners, use the `=>` operator to provide a custom closure to execute on all the delegates.

```swift
  delegate => { $0.coordinatorDidLoginSuccessfully() }
```

## Where to go from here

Coordinators, while a hard concept to grasp after doing MVC, is a surprisingly simple and extensible architecture. There's some great articles on the web that I recommend reading to flesh out your understanding of how coordinators work.
- [The Coordinator](http://khanlou.com/2015/01/the-coordinator/)
- [Coordinator Redux](http://khanlou.com/2015/10/coordinators-redux/)
- [An iOS Coordinator Pattern](https://will.townsend.io/2016/an-ios-coordinator-pattern)

Additionally there's a [fantastic video from NSSpain](https://vimeo.com/144116310) where the guy behind the recent push for coordinators, Soroush Khanlou, talks about how he uses them in his application.

## Contributing

Have an issue? Open an issue! Have an idea? Open a pull request!

If you like the library, please :star: it!

Cheers :beers:
