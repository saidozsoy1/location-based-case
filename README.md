# Location Based Case

An iOS application that tracks user location and displays their route on a map. The app utilizes protocol-based dependency injection and follows MVVM architecture.

## Features

- Tracks user location in both foreground and background
- Adds markers to the map every 100 meters of location change
- Displays address information when tapping on a marker
- Allows users to start/stop location tracking
- Preserves route data between app sessions
- Supports route reset functionality
- Available in multiple languages (English, Turkish)

## Architecture

### MVVM with Protocol-Based Dependency Injection

This project demonstrates the use of protocol-based dependency injection to create a highly testable and maintainable codebase.

- **Protocols**: Define clear interfaces for all services
- **Dependencies**: Injected through constructors rather than created within components
- **Testability**: Easy replacement of real implementations with mocks

### Key Components

- **AppDependencyContainer**: Central hub for creating and managing dependencies
- **Managers**: Protocol-based service implementations (Location, Data, Core Data, etc.)
- **ViewModels**: Business logic layer that coordinates between views and services
- **Coordinators**: Handle navigation flow and screen transitions

## Data Storage

The app supports multiple storage strategies:

- **CoreData**: For complex data storage requirements (default)
- **UserDefaults**: For simpler persistence needs

Storage strategy can be easily switched by changing the `storageType` parameter in the `AppDependencyContainer`.

## Location Tracking

Location tracking is implemented using CoreLocation with:

- Foreground tracking with high accuracy
- Background tracking for extended periods
- Significant location change monitoring to optimize battery usage
- Automatic storage of location data

## Getting Started

### Prerequisites

- Xcode 14.0+
- iOS 14.0+
- Swift 5.0+

### Installation

1. Clone the repository
```
git clone https://github.com/yourusername/location-based-case.git
```

2. Open `Location Based Case.xcodeproj` in Xcode

3. Select your target device or simulator

4. Build and run the application

## Usage

1. Grant location permissions when prompted
2. Use the start/stop button to control location tracking
3. View your route on the map with markers at 100-meter intervals
4. Tap markers to see address information
5. Use the reset button to clear your route history

## Testing

The project includes unit tests for the core functionality:

- Protocol-based injection makes it easy to mock dependencies
- Test coverage for ViewModels and Managers

Run tests using Xcode's Test Navigator or via Command+U.
