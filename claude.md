# Project Context

## Response style
- Minimal explanation. Code-first responses.
- Skip obvious commentary ("this creates a button...")
- Only explain non-standard patterns or gotchas
- Don't apologize or hedge ("I cannot be certain but...")
- Don't suggest "you might want to consider" - just show the better approach
- Skip safety disclaimers for standard iOS dev tasks
- If my code has issues, point them out directly

## Tech Stack
- SwiftUI + Swift 6
- iOS 17+ deployment target
- MVVM architecture

## Code Style
- Prefer composition over inheritance
- Use `@Observable` over `@StateObject`/`@ObservableObject`
- Async/await for concurrency, avoid completion handlers
- Value types (structs) for views and models
- Protocol-oriented design where appropriate (e.g. services)
- no comments
- conformance to protocols must be separate extensions
- use async let whenever possible then await multiple tasks at the same time
- if you make dummy service it must have parameters -- delay TimeInterval, and fail Bool that would just return error
- service namings: 'Default' for real service, 'Mock' for mock, no preffix/suffix for protocol
- if there are any auxiliary types put them after the main one of the file
- don't make any whitespace changes

## SwiftUI
- No styling unless I specify
- in SwiftUI views everything must be broken down into private var subviews
- Navigation via navigationDestination that takes binding to child ViewModels -- navigationdestination(item:)
- the screen views must accept viewmodel and only that, no custom inits
- if there's a list, rows/cells must be separate views
- don't show 'cancelled' errors
- if button's callback has no arguments it must be passed like this: Button(name: "...", action: action)
- instead of horizontal spacer try to use frame(maxWidth: .infinity)
- never hardcode font sizes, only use things like 'title', 'body', 'caption'
- both separate views and screens must have preview
- avoid onChange in swiftUI views
- in SwiftUI views there must be no complex logic. if there's a piece of code that needs to be called then all the underlying logic must be in a ViewModel method. If there's a complex bool condition then it must be in ViewModel

## Project Structure
/Screens - screens containing pairs of view + view model in subdirectories. Each Screen (view + view model must be separate subdirectory)
/Views - aux views
/Models - Data models
/Services - API/data layer
/Extensions - Type extensions
/Resources - Assets, localizations

## Key Patterns
- Dependency injection via passing a service to a view model
- ViewModifiers for reusable styling
- PreferenceKeys for child-to-parent communication

## Testing
- XCTest for unit tests
- Mock services via protocols
