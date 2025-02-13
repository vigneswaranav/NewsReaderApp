# NewsReader

A SwiftUI application demonstrating a **Clean Architecture + MVVM** approach to fetching news articles from a remote API (e.g., New York Times), storing them in Core Data, and presenting them in a reactive list. The app includes a detail view, a custom Core Data FRC observer, and a unified approach for mapping API responses to Core Data entities and domain models.

---

## Table of Contents

1. [Demo](#demo)
2. [Architecture Overview](#architecture-overview)  
3. [Core Data Stack](#core-data-stack)  
4. [Data Flow](#data-flow)  
5. [Requirements](#requirements)  
6. [Setup and Configuration](#setup-and-configuration)  
7. [Build and Run](#build-and-run)  
8. [Test Cases](#test-cases) 

---

## Demo

Below is a quick demonstration of the NewsReader app in action.
This GIF shows how tapping the refresh button fetches new articles, populates the list, and updates the detail view seamlessly.

![NewsReader_Demo](https://github.com/user-attachments/assets/40a68449-79d2-48de-865e-516df54da404)

## Architecture Overview

This app follows **Clean Architecture** principles with an **MVVM** presentation layer:

- **Domain Layer**  
  Defines the core business rules (use cases, domain entities) and abstracts the repository interfaces.
  
- **Data Layer (Repository and Core Data)**  
  Implements data fetching, Core Data persistence, and entity → model mapping.  
  - **Core Data**: Houses entity definitions, the `PersistenceController`, and the `FetchResultControllerObserver` for reactive updates.
  - **Repository Implementation**: Conforms the repository protocol, fetching from network APIs and saving/fetching in Core Data.

- **Presentation Layer**  
  Uses MVVM with a `NewsListViewModel` for business logic and state updates, and SwiftUI views (`NewsArticleView`, `NewsArticleListRow`, `NewsArticleDetailView`) for UI rendering. Observes data changes via `FetchedResultsObserver` class.

---

## Core Data Stack

- **PersistenceController**:  
  Manages the `NSPersistentContainer` and database initialisation and ensures that persistent stores are created and loaded.  
  Provides a main (UI) context and optional background contexts for writes.
  
- **FetchResultControllerObserver**:  
  A generic observer wrapping `NSFetchedResultsController`, publishing entity updates to SwiftUI views (allowing real-time list updates without manual reloads).

- **Handlers & Mappers**:
  - **EntityModelMapperProtocol** defines how to map entities to domain models and vice-versa.  
  - **DatabaseHandler** & sync handlers define how to perform CRUD operation on entities and conforms to **EntityModelMapperProtocol**.

---

## Data Flow

1. **Network Request**:  
   `APIManager` uses a specific endpoint from `API Endpoints` to fetch JSON data from the NYTimes API.

2. **Response Parsing & Mapping**:  
   API response model objects (`NewsArticleModel`, `NewsArticleMediaModel`) are parsed, then mapped to domain models (`NewsArticleItem`, `NewsArticleMediaItem`).

3. **Repository**:  
   - **NewsArticleRepositoryImpl** decides whether to fetch from remote API datasource or local datasource(Core Data).  
   - If it is from remote API, it parses the response and maps to domain model objects and saves the entities into Core Data.  
   - Returns domain models to the **Use Case**.

4. **Use Case**:  
   - **FetchNewsArticleUseCase** orchestrates fetching/saving logic, returning domain entities to the ViewModel.

5. **ViewModel**:  
   - **NewsListViewModel** triggers the use case, manages loading/error states, and provides data to the UI.  
   - Changes in Core Data are observed via `FetchResultControllerObserver`, updating SwiftUI views in real-time.

6. **UI**:  
   - SwiftUI views observe published properties and the observer’s output, rendering a list of articles and a detail view.

---

## Requirements

- **Swift 5+**  
- **Xcode 14+** (recommended for modern SwiftUI features)  
- **iOS 15+**

No external third-party libraries. Only native Swift, SwiftUI, and Core Data.

---

## Setup and Configuration

1. **Clone the Repository**  
   ```bash
   git clone https://github.com/vigneswaranav/NewsReaderApp.git
   ```
2.	Open the Project
    1.	cd NewsReader
    2.	open NewsReader.xcodeproj

---

## Build and Run

1.	**Open Xcode** and select your target.
2.	**Build:** Press Cmd + B or click the Build button.
3.	**Run:** Press Cmd + R or click the Run button (choose iOS Simulator or a physical device).
4.	**Observe:** The app should fetch or display locally cached articles and update the UI automatically.

---

## Test Cases

This project includes both **Unit Tests** and **UI Tests**, located in the **NewsReaderTests** and **NewsReaderUITests** folders, respectively. These tests help ensure the code remains robust, covering core functionality (use cases, repositories, etc.) and end-to-end user interactions.

### Unit Tests

1. **Purpose**  
   - Verify the correctness of use cases, domain logic, repositories, and mappers.  
   - Ensure that fetching, saving, and mapping logic behave as expected, including error handling and edge cases.

2. **Location**  
   - Files are located under the `NewsReaderTests/` folder.
   - Common filenames might include `UseCaseTests.swift`, `RepositoryTests.swift`, etc.

3. **Examples**  
   - **Use Case Tests**: Confirm that `FetchNewsArticleUseCase` retrieves local articles (if available) or fetches remote data when needed, and handles errors properly.  
   - **Repository Tests**: Mock the network layer to simulate various API responses and verify that Core Data integration works correctly (often using an in-memory store for isolation).

4. **How to Run**  
   - In Xcode, select **Product > Test** or press **Cmd + U**.  
   - Alternatively, open the Test Navigator (⌘ + 6) and run individual tests by clicking the diamond icon next to each test or test class.

### UI Tests

1. **Purpose**  
   - Validate end-to-end user interactions, such as:  
     - Tapping the refresh button to load new data.  
     - Selecting an article to view details.  
     - Handling error states or empty data scenarios.

2. **Location**  
   - Files are located under the `NewsReaderUITests/` folder.
   - A typical test file might be `NewsReaderAppUITests.swift`.

3. **Examples**  
   - **Refresh Flow**: Launch the app, tap the refresh button, wait for the list to populate, and confirm at least one article cell appears.  
   - **Detail Flow**: Tap an article row, verify that the detail screen displays the correct title, abstract, and other metadata.

4. **How to Run**  
   - In Xcode, select **Product > Test** or press **Cmd + U**, ensuring that UI tests are included in your current scheme.  
   - Alternatively, run individual UI tests in the Test Navigator by clicking the diamond next to each test method or class.  
   - The iOS Simulator (or a physical device) will launch and perform the scripted UI interactions automatically.

### Code Coverage

To view coverage for tests:

1. **Enable Code Coverage**  
   - In Xcode, go to **Product > Scheme > Edit Scheme...**  
   - Select the **Test** action in the left sidebar, then expand the **Options** tab.  
   - Check the **Gather coverage for** checkbox and ensure your test target(s) are selected.

2. **Run Tests with Coverage**  
   - Press **Cmd + U** or **Product > Test**.  
   - Xcode will now collect code coverage data for the selected targets during testing.

3. **View Coverage**  
   - After the tests are completed, open the **Report Navigator** (⌘ + 9) in Xcode.  
   - Select the most recent test run, then choose the **Coverage** tab in the center pane.  
   - Expand modules and files to see coverage percentages and which lines of code are covered.
