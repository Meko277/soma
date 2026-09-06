# Bible data setup

This package contains the generator and Flutter integration files.

## 1. Put `setup_bible_data.py` in the Flutter project root

## 2. Run

python setup_bible_data.py

The script downloads:
- Arabic Smith-Van Dyck (SVD), public-domain
- English King James Version (KJV), public-domain

and creates 132 files:
- 66 Arabic books
- 66 English books

## 3. Replace

`lib/core/bible/bible_content_repository.dart`
with the supplied version.

`lib/core/bible/bible_content_loader.dart`
with the supplied version.

Do NOT recreate `bible_chapter.dart`.

## 4. pubspec.yaml

Use:

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/fonts/
    - assets/bible/ar/
    - assets/bible/en/

Then run:

flutter pub get
flutter clean
flutter run

Source:
https://github.com/midvash/bible-data
