# NewsReader

A SwiftUI application demonstrating a **Clean Architecture + MVVM** approach to fetching news articles from a remote API (e.g., New York Times), storing them in Core Data, and presenting them in a reactive list. The app includes a detail view, a custom Core Data FRC observer, and a unified approach for mapping API responses to Core Data entities and domain models.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)  
2. [Core Data Stack](#core-data-stack)  
3. [Data Flow](#data-flow)  
4. [Requirements](#requirements)  
5. [Setup and Configuration](#setup-and-configuration)  
6. [Build and Run](#build-and-run)  
7. [Test Cases](#test-cases)  

---

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
  Manages the `NSPersistentContainer`, ensuring persistent stores are loaded.  
  Provides a main (UI) context and optional background contexts for writes.
  
- **FetchResultControllerObserver**:  
  A generic observer wrapping `NSFetchedResultsController`, publishing entity updates to SwiftUI (allowing real-time list updates without manual reloads).

- **Handlers & Mappers**:
  - **EntityModelMapperProtocol** defines how to map entities to domain models and back.  
  - **DatabaseHandler** & sync handlers define how to perform CRUD operation on entities and conforms to **EntityModelMapperProtocol**.

---

## Data Flow

1. **Network Request**:  
   `APIManager` uses a specific endpoint from `API Endpoints` to fetch JSON data from the NYTimes API.

2. **Response Parsing & Mapping**:  
   API response model objects (`NewsArticleModel`, `NewsArticleMediaModel`) are parsed, then mapped into domain models (`NewsArticleItem`, `NewsArticleMediaItem`).

3. **Repository**:  
   - **NewsArticleRepositoryImpl** decides whether to fetch from remote or local.  
   - If from remote, it parses/maps and saves into Core Data.  
   - Returns domain models to the **Use Case**.

4. **Use Case**:  
   - **FetchNewsArticleUseCase** orchestrates fetching/saving logic, returning domain entities to the ViewModel.

5. **ViewModel**:  
   - **NewsListViewModel** triggers the use case, manages loading/error states, and provides data to the UI.  
   - Changes in Core Data are observed via `FetchResultControllerObserver`, updating SwiftUI views in real-time.

6. **UI**:  
   - SwiftUI views observe published properties or the observer’s output, rendering a list of articles and a detail view.

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
