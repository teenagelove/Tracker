# Tracker

### 📱 iOS
![iOS](https://img.shields.io/badge/iOS-13%2B-000000?logo=apple&logoColor=white)
![UIKit](https://img.shields.io/badge/UIKit-007AFF?logo=apple&logoColor=white)
![UITableView](https://img.shields.io/badge/UITableView-0A84FF?logo=apple&logoColor=white)
![UICollectionView](https://img.shields.io/badge/UICollectionView-FF9500?logo=apple&logoColor=white)
![UIPageViewController](https://img.shields.io/badge/UIPageViewController-5856D6?logo=apple&logoColor=white)
![UIDatePicker](https://img.shields.io/badge/UIDatePicker-0A84FF?logo=apple&logoColor=white)

### 🌐 Features & Libraries
![Core Data](https://img.shields.io/badge/Core_Data-FFD60A?logo=apple&logoColor=black)
![Localization](https://img.shields.io/badge/Localization-5AC8FA?logo=googletranslate&logoColor=white)
![AppMetrica](https://img.shields.io/badge/AppMetrica-FFCC00?logo=yandex&logoColor=black)
![Cocoapods](https://img.shields.io/badge/CocoaPods-FA7343?logo=cocoapods&logoColor=white)

### 🧪 Tests & Workflow
![MVVM](https://img.shields.io/badge/MVVM-FF6B6B?logo=swift&logoColor=white)
![Snapshot Tests](https://img.shields.io/badge/Snapshot_Tests-FF2D55?logo=xcode&logoColor=white)
![Conventional Commits](https://img.shields.io/badge/Conventional_Commits-FF69B4?logo=git&logoColor=white)

---

## 📖 Description  
The app helps users form healthy habits and track their completion. Users can create tracker cards for habits or irregular events, organize them by category, view progress in a calendar, and track statistics for their achievements.


<p align="center">
  <img src="Assets/Preview.gif" alt="App Preview" width="300"/>
</p>

# Purpose and Goals of the Application

The app helps users form healthy habits and track their completion.

Goals of the application:

- Track habits by day of the week;
- View progress for each habit;

# Brief Description of the Application

- The app consists of tracker cards that the user creates. Users can specify a title, category, and set a schedule. They can also choose an emoji and color to distinguish cards from each other.
- Cards are organized by category. Users can search for them and apply filters.
- Users can view their scheduled habits for a specific day using a calendar.
- The app includes statistics that reflect users’ success, progress, and averages.

# Functional Requirements

## Onboarding

Upon first opening the app, the user sees the onboarding screen.

**The onboarding screen contains:**

1. Splash screen;
2. Title and subtitle;
3. Page controls;
4. "Let’s Go!" button.

**Algorithms and available actions:**

1. Users can swipe left or right to switch between pages. Page controls update accordingly.
2. Clicking the "Let’s Go!" button navigates to the main screen.

## Creating a Habit Tracker Card

On the main screen, the user can create a tracker for a habit or an irregular event. A habit is an event that repeats with a certain frequency. An irregular event is not tied to specific days.

**Habit tracker creation screen contains:**

1. Screen title;
2. Field for tracker name;
3. Category section;
4. Schedule section;
5. Emoji selection section;
6. Tracker color selection;
7. "Cancel" button;
8. "Create" button.

**Irregular event tracker creation screen contains:**

1. Screen title;
2. Field for tracker name;
3. Category section;
4. Emoji selection section;
5. Tracker color selection;
6. "Cancel" button;
7. "Create" button.

**Algorithms and available actions:**

1. Users can create a tracker for a habit or irregular event. The creation flow is similar, but the irregular event has no schedule section.
2. Users can enter the tracker name:
    1. After typing one character, a clear icon appears. Clicking it deletes the text;
    2. Maximum characters: 38;
    3. Exceeding the limit shows an error message;
3. Clicking the "Category" section opens the category selection screen:
    1. If no categories exist, a placeholder is shown;
    2. The last selected category is marked with a blue check;
    3. Clicking "Add Category" opens a screen with a name input field. The "Done" button is inactive until at least 1 character is entered. Clicking "Done" returns to the category selection screen. The new category appears in the list but is not automatically selected;
    4. Selecting a category marks it with a blue check and returns to the habit creation screen. The chosen category is displayed below the "Category" title as secondary text;
4. The "Schedule" section is available when creating habits. Clicking it opens a screen to select days of the week. Users toggle switches to choose repetition days. Clicking "Done" returns to the habit creation screen, showing selected days as secondary text:
    1. If all days are selected, it displays "Every day";
5. Users can select an emoji; the selected emoji gets a background highlight;
6. Users can select a tracker color; the selected color gets a border;
7. Clicking "Cancel" stops the creation process;
8. "Create" button is inactive until all required fields are filled. Clicking it returns to the main screen, and the new habit appears in the corresponding category.

## Viewing the Main Screen

On the main screen, users can view all trackers for a selected date, edit them, and see statistics.

**Main screen contains:**

1. "+" button to add a habit;
2. "Trackers" title;
3. Current date;
4. Search field for trackers;
5. Tracker cards organized by category. Each card includes:
    1. Emoji;
    2. Tracker name;
    3. Number of completed days;
    4. Completion button;
6. "Filter" button;
7. Tab bar.

**Algorithms and available actions:**

1. Clicking "+" shows options to create a habit or irregular event;
2. Clicking the date opens the calendar. Users can switch between months. Selecting a day shows trackers for that date;
3. Users can search trackers by name;
    1. If no results, a placeholder is displayed;
4. Clicking "Filters" opens a filter sheet:
    1. Filter button is inactive if no trackers exist for the selected day;
    2. "All trackers" shows all trackers for the day;
    3. "Today’s trackers" sets the current date and shows trackers for that day;
    4. "Completed" shows completed habits for the day;
    5. "Incomplete" shows uncompleted trackers;
    6. Current filter is marked with a blue check;
    7. Clicking a filter closes the sheet and shows relevant trackers;
        1. If no trackers exist, a placeholder is shown;
5. Users can scroll up and down through the feed;
    1. If card images haven’t loaded yet, a system loader is shown;
6. Clicking a tracker card blurs the background and opens a modal window:
    1. Users can pin the card. It moves to the "Pinned" category at the top;
        1. Clicking again unpins it; if no pinned cards exist, the category disappears;
    2. Users can edit the card via a modal, similar to the creation flow;
    3. Clicking "Delete" opens an action sheet:
        1. Users confirm deletion; all data is removed;
        2. Users can cancel and return to the main screen;
7. Tab bar allows switching between "Trackers" and "Statistics" tabs.

## Editing and Deleting Categories

During tracker creation, users can edit or delete categories.

**Algorithms and available actions:**

1. Long press on a category blurs the background and opens a modal:
    1. Clicking "Edit" allows editing the category name. Clicking "Done" returns to the category list;
    2. Clicking "Delete" opens an action sheet:
        1. Confirming deletion removes the category and all associated data;
        2. Cancel returns to the list;

## Viewing Statistics

In the statistics tab, users can view success metrics, progress, and averages.

**Statistics screen contains:**

1. "Statistics" title;
2. List of metrics, each with:
    1. Number value;
    2. Secondary text with the metric name;
3. Tab bar.

**Algorithms and available actions:**

1. If no data exists, a placeholder is displayed;
2. If data exists for at least one metric, statistics are displayed. Metrics without data show zero;
3. Users can view the following metrics:
    1. "Best streak" — max consecutive days without missing any trackers;
    2. "Perfect days" — days when all scheduled habits were completed;
    3. "Trackers completed" — total number of completed habits;
    4. "Average" — average number of habits completed per day.

## Dark Mode

The app supports dark mode, which follows the device system settings.

# Non-Functional Requirements

1. The app supports iPhone X and newer, and is adapted for iPhone SE. Minimum iOS version: 13.4;
2. Uses standard iOS font: SF Pro;
3. Habit data is stored using Core Data.
