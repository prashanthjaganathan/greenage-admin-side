# Greenage Admin Side

**Greenage Admin Side** is a part of the Greenage Waste Management project—a smart, efficient, and incentivized waste management solution designed for urban India. This Flutter-based application provides the administrative interface for managing and monitoring waste collection, segregation, and recycling efforts within the Greenage ecosystem.

The application allows administrators to track real-time data, monitor waste collection progress, manage users, and interact with various smart systems (like bins and sensors) integrated within the waste management system.

---

## Project Overview

**Greenage Waste Management** is a collaborative initiative between the **Information Science & Engineering** and **Chemical Engineering** departments of **BMSCE**. The overall solution integrates mobile apps, IoT-enabled smart bins, and deep learning technologies to ensure effective waste management across urban India.

This project is designed to:

- **Optimize waste collection**, segregation, and recycling processes.
- **Empower communities** by incentivizing waste management through rewards and tracking.
- **Eradicate plastic waste** with targeted solutions.
- **Leverage smart technology** for real-time monitoring and data collection.

The admin side of the Greenage system provides a powerful interface for managing and overseeing these processes, ensuring smooth operations and effective community involvement.

---

## Features

- **Admin Dashboard**: Real-time monitoring of waste collection, recycling stats, and overall waste management.
- **User Management**: View and manage registered users, their activity, and engagement.
- **Smart Bin Integration**: Track the status of smart bins and their usage, including data like bin fill levels.
- **Waste Analytics**: Visualize and analyze waste collection data and performance trends.
- **Multi-platform Support**: Built with Flutter for cross-platform compatibility (Android, iOS, Web, etc.).

---

## Technologies Used

- **Flutter**: Cross-platform mobile app development framework.
- **Dart**: Programming language for the Flutter framework.
- **Firebase**: Backend as a service for user authentication, real-time data syncing, and notifications.
- **REST APIs**: For communication with the backend server and data retrieval.
- **Google Maps API**: To display waste collection areas and monitor routes for efficient waste collection.

---

## Project Status

- The **Greenage Waste Management** project is under review for a **patent**.
- Currently in the **prototype phase**, focusing on testing and refining the admin-side functionalities.

---

## Setup Instructions

Follow these steps to set up and run the Greenage Admin Side on your local machine:

### Prerequisites

1. **Flutter**: Ensure you have Flutter installed. If not, follow the [Flutter installation guide](https://flutter.dev/docs/get-started/install).
2. **Android Studio** or **Xcode**: Required for building the project on Android or iOS devices.
3. **Firebase**: Set up Firebase for the project to enable real-time data syncing and authentication.

### Clone the Repository

Clone the repository to your local machine:

```bash
git clone https://github.com/prashanthjaganathan/greenage-admin-side.git
```

### Install Dependencies
Navigate to the project directory and run:
`flutter pub get`

### Run the App
To run the application:

- Android:
  `flutter run`
  
- iOS (macOS only):
  `flutter run --target=ios`

- Web:
  `flutter run -d chrome`

---

## Project Structure

Here’s a breakdown of the key folders and files in the project:
```bash
/greenage-admin-side
    ├── android              # Android platform-specific code
    ├── ios                  # iOS platform-specific code
    ├── lib                  # Dart code (UI, logic, etc.)
    ├── assets               # Images, icons, and other resources
    ├── test                 # Unit and widget tests
    ├── pubspec.yaml         # Flutter dependencies
    ├── pubspec.lock         # Lock file for dependencies
    ├── analysis_options.yaml # Linting and code analysis configuration
    └── README.md            # This file
```
---

## Acknowledgements

- Centre for Innovation Incubation and Entrepreneurship (CIIE) at BMSCE for funding the implementation of this project within the college.
- BMSCE’s Information Science & Engineering and Chemical Engineering departments for their collaborative efforts in creating this solution.
