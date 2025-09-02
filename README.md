# Pokemon App
![PokemonApp](https://github.com/19193-IbrohimHusain/PokemonApp/blob/main/Application%20Screen.png)

Experiment App. Built with Swift & UIKit

## Table of Contents
- [Tech Stack](#tech-stack)
- [Features](#features)
- [Installation](#installation)
  - [CocoaPods](#cocoapods)
- [Folder Structure](#folder-structure)

## Tech Stack

- Swift 5
- MVVM + Clean Architecture
- Combine – reactive programming for async handling
- Alamofire – networking layer
- Kingfisher – fast image downloading & caching
- MBProgressHUD – elegant loading indicators
- XLPagerTabStrip – tab-based navigation with swipeable pages
- Couchbase Lite – local persistence & offline-first support

## Features

- 🔍 Discover Pokémon – Browse a list of Pokémon, view their details (abilities, stats, types, species info), and learn trivia like height, weight, and weaknesses.
- ⭐ Save Favorites – Mark your favorite Pokémon and access them anytime, even offline.
- 👤 Manage Your Profile – Create an account, log in securely, and keep a personalized list of favorites tied to your user profile.

## Installation

Follow these steps to install and set up the project.

### CocoaPods

This project relies on various third-party libraries for enhanced functionality. Ensure you have CocoaPods installed, then run the following command:

```bash
pod install
```

This will install the required dependencies specified in the `Podfile`.

## Folder Structure

This project's folder structure is designed for modularity and separation of concerns, enhancing maintainability and organization.

### App

- **AppDelegate**: Manages the application's lifecycle events.
  
- **SceneDelegate**: Handles the setup of the app's user interface upon launching.

### Resource

- **Assets**: Stores general assets used in the application.

- **Info.plist**: Stores configuration settings and metadata for the app.

### Common

- **Extension**: Contains Swift extensions for extending functionality of built-in classes.

- **Component**: Houses reusable UI components used across multiple modules.

- **Utilities**: Includes files for storing constants, base class and helper used throughout the app.

### Data

- **Datasource**: Protocol definitions that abstract database and repository behavior.
  
- **Repository**: Provides networking, and local database implementations.

### Domain

- **Entity**: Core business entities represented as simple Swift structs.
  
- **UseCase**: Encapsulates application-specific business logic.

### Presentation

- **Authentication**: Contains files specific to the authentication feature.

- **DetailPokemon**: Contains files specific to the detail pokemon feature.

- **Profile**: Contains files specific to the profile feature.

- **Home**: Contains files specific to the home feature.

- **FavoritePokemon**: Contains files specific to the favorite pokemon feature.

- **SearchPokemon**: Contains files specific to the search pokemon feature.

- **Tab**: Includes files related to the tab feature.

---
