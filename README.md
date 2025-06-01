# Mesob Recipes

A cross-platform Flutter app for discovering, planning, and learning about traditional recipes.  
Features user authentication, meal planning, favorites, and cultural context for each dish.

## Features

- User Authentication: Sign up and log in with Firebase Auth (persistent sessions).
- Recipe List & Detail: Browse recipes by category, view details, ingredients, instructions, and cultural context.
- Meal Planner: Plan meals on a calendar and persist your plans locally.
- Favorites: Mark recipes as favorites (saved to your account).
- Offline Images: Uses local asset images for select recipes and as fallbacks.
- Responsive UI: Works on mobile and web.

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Firebase Project](https://firebase.google.com/)
- (Optional) [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/)

### Installation

1. Clone the repository:
        git clone https://github.com/yourusername/mesob_recipes.git
    cd mesob_recipes
    

2. Install dependencies:
        flutter pub get
    

3. Configure Firebase:
    - Add your google-services.json (Android) and/or GoogleService-Info.plist (iOS) to the respective folders.
    - Enable Email/Password authentication in Firebase Console.

4. Add assets:
    - Ensure your images are in assets/images/ and declared in pubspec.yaml:
            flutter:
        assets:
          - assets/images/
      

5. Run the app:
        flutter run
    
    Or for web:
        flutter run -d chrome
    
## Project Structure

lib/
  models/                # Data models (e.g., Recipe)
  screens/               # UI screens (Home, Login, Meal Planner, etc.)
  services/              # Firebase and local storage services
  widgets/               # Reusable widgets (BottomNavBar, IngredientList, etc.)
assets/
  images/                # Recipe and placeholder images
pubspec.yaml

## Customization

- Add new recipes: Update your Firestore database or local JSON.
- Add new images: Place them in assets/images/ and update pubspec.yaml.
- Change theme: Edit ThemeData in main.dart.


## Credits

- Built with [Flutter](https://flutter.dev/)
- Uses [Firebase](https://firebase.google.com/) for authentication and data storage

  
## Demo Video

You can watch a demo of the app here: [Mesob Recipes App Demo]( https://youtu.be/Cl0kt8HzLp4
)
## **Project Status** 
**This project is currently under active development.** Features may be incomplete, and images might not be loaded correctly. We appreciate your patience as we continue to build and improve!
---


Enjoy cooking with Mesob Recipes!
