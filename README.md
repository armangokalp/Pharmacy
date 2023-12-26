# Pharmacy App

## Overview
Pharmacy Locator App is an iOS application designed to help users find and track pharmacies and on-duty pharmacies in their vicinity. Utilizing modern Swift programming techniques and several key APIs, pharmacy app offers a range of features from displaying nearby pharmacies on a map, searching for specific locations, tracking the nearest pharmacies, and managing user-specific medicine lists.

## Features
- **Map View**: Shows pharmacies as interactive annotations on a map.
- **Search Functionality**: Allows users to search for specific locations or pharmacies.
- **Nearby Pharmacy Tracking**: Lists pharmacies in the vicinity of the user's location.
- **Medicine Tracker**: Personalized feature for users to track their medicines.
- **Settings and Customization**: Offers customizable settings for users.

## Technical Details

### Front-End
- **SwiftUI Views**: The app employs a tab view structure, delivering a clean and navigable user interface. Views include `LocationView`, `SearchView`, `NearestPharmaciesView`, `MedicineTrackerView`, and `SettingsView`.
- **MapKit Integration**: Utilizes Apple’s MapKit for displaying and interacting with maps, enhanced with custom annotations for pharmacies.
- **SwiftUI and User Interaction**: Rich user interaction patterns are implemented using SwiftUI, including gestures and animations.

### Back-End

#### Location Services
- **Core Location**: Core Location framework is used for accessing the user's current location and updating the map region accordingly.

#### Data Handling
- **Google Places API**: The app interfaces with the Google Places API to fetch information about pharmacies, including names, addresses, phone numbers, and coordinates.
- **Data Parsing and Management**: Custom logic is in place to parse and manage data fetched from external APIs, ensuring the app displays accurate and up-to-date information.

#### Additional Functionalities
- **Web Scraping for On-Duty Pharmacies**: The app scrapes a specific webpage to gather information about on-duty pharmacies, integrating this data seamlessly into the app's interface.

### APIs and Libraries
- **MapKit**: For rendering and managing the map view.
- **Core Location**: To access and track the user’s geographical location.
- **Google Places API**: Used for fetching details about pharmacies.
- **SwiftSoup**: Employed for parsing HTML content, primarily used in scraping on-duty pharmacy data.
- **WebKit**: Used in conjunction with SwiftSoup for loading and handling web content.

### Architecture and Design
The app adopts an MVVM (Model-View-ViewModel) architecture, promoting a clean separation of concerns, which enhances maintainability and scalability. Reactive programming paradigms are followed, with `@Published` properties and SwiftUI’s state management features to ensure a responsive and dynamic user experience.

### Security and Privacy
- **API Key Management**: The app’s API keys are managed securely to prevent unauthorized access and misuse.
- **User Privacy**: User location data is handled with strict privacy controls, ensuring compliance with data protection regulations.

## Setup and Configuration
- **Dependencies**: Ensure to install all the necessary dependencies.
- **API Keys**: Replace the placeholder API keys with your valid keys from respective service providers.
