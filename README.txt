### Environment:
Xcode 12.4
iOS 13+, but Snapshot tests have been recorded with iPhone SE (2nd generation) iOS 14.4.

### Application Architecture:
No particular architectural patterns have been used, just a general approach to separation of concerns and testable dependency management. Big emphasis on type safety and testability. 
All services have mocks and almost all business logic is tested.

`App.swift` - application's flow coordination. Creates screens and presents them as needed. 

`WebService.swift` - our main HTTP service. Has mocks, is injected to `App`.

`ImageLoader.swift` - image loading service. Has mocks, is injected to `App`.

### UI:
Built completely in code to avoid undesirable explosion of Optional properties that comes with
Interface Builder approach. All View Controller dependencies are passed to inits, which significantly improves type safety and testability.

"Breeds List" is a simple table view.
"Breed Photos" is a pretty advanced Instagram-style collection view. Uses diffable data source.

### Loading indication: 
Implemented with shimmering placeholder, Facebook-style. 

Go to `WebService.swift `line 35, to simulate longer request times to better see shimmering.
Or use network conditioner tool.

### Accessibility: 
UI supports Dynamic Fonts. Navigate to Setting/Accessibility/Display & Text Size/Larger Text to test.
Shimmers also respect Dynamic Font Size.

### 3rd-party Dependencies:
Snapshot testing library - [https://github.com/pointfreeco/swift-snapshot-testing.git](https://github.com/pointfreeco/swift-snapshot-testing.git)

### Error Handling:
Both screens have error states and support Retry functionality.
Refer to file `Network Conditioner Test.mov` for demonstration.