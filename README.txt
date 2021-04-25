Environment:
Xcode 12.4
iOS 13+, but Snapshot tests have been recorded with iPhone SE (2nd generation) iOS 14.4.

Application Architecture:
No particular architectural patterns have been used, just a general approach to separation of concerns and testable dependency management. Big emphasis on type safety and testability. 
All services have mock and almost all business logic is tested.

App.swift - application flow coordination. Creates screens and presents them as needed. 

WebService.swift - our main HTTP service. Has mocks, is injected to App.
ImageLoader.swift - image loading service. Has mocks, is injected to App.

UI:
Built completely in code to avoid undesirable explosion of Optional properties that comes with
Interface Builder approach. All View Controller dependencies are passed to inits, which significantly improves type safety and testability.


Breeds List is a simple table view.
Breed Photos is a pretty advanced Instagram style collection view. Uses diffable data source.

Dependencies:
Snapshot testing library - https://github.com/pointfreeco/swift-snapshot-testing.git