# CampusMarket | CS310 Group 14

## Step 2.2 Flutter interface

CampusMarket implements the approved marketplace screens from Step 2.1. The demo uses example accounts, listings and messages in memory. Signing out or restarting the app resets the demo session. Firebase integration is planned for Step 3.

### Run the app

Use **Flutter 3.47.9 stable** with **Dart 3.13.7**. Start an Android emulator or iOS simulator, then run these commands from the repository folder.

```sh
flutter pub get
flutter devices
flutter run
```

If multiple devices are available, use `flutter run -d <device-id>`. For a browser preview, use `flutter run -d chrome`.

### Try the main flows

1. Sign in with `student@sabanciuniv.edu` and a sample password such as `campus123`. Use `unverified@sabanciuniv.edu` to try the verification screen from login, or follow **Create an account**.
2. Open a listing, try **Search listings & filters**, or open a conversation and send an example message.
3. Use **+ Sell** to enter a listing. Choose at least one sample photo and fill out the required fields. The form shows field errors and asks for confirmation when the values are valid.
4. In **My listings**, edit an item, mark it as sold or delete it. Sold items stay in My listings and leave the active feed and search results.

### Code and checks

- `lib/screens/` contains the account, listing, search and conversation screens. They use `Navigator`, `MaterialPageRoute` and `setState`.
- `lib/models/listing.dart` defines the listing model and the example data. The feed lazily renders records with `SliverList.builder` and reusable listing cards.
- `lib/theme.dart` and `lib/widgets/market_ui.dart` hold the shared colors, typography, spacing and widgets. The form uses `Form` and `TextFormField`.
- Run `flutter analyze` and `flutter test` for static analysis and the widget checks, including portrait sizes of 320 × 568 and 430 × 932.

The interface uses [Sabancı University's official color guide](https://www.sabanciuniv.edu/sites/default/files/2026-01/kurumsal-iletisim-kilavuzu-2025.pdf), a bundled [Roboto font](assets/fonts/OFL-Roboto.txt), and locally bundled synthetic demo listing photos. The headphones gallery also demonstrates an online image by C D-X, with a local photo available if the network image fails. [Photo credit](https://unsplash.com/photos/flatlay-photography-of-wireless-headphones-PDX_a_82obo)

<details>
<summary>Demo photo assets</summary>

The four `*-photo.jpg` files in `assets/images/` were created with the built-in image generator. The shared prompt asked for realistic editorial resale photos, tactile surfaces, soft side light, a university blue and neutral palette, a centered product in a 4:3 frame, and no people, logos, text, or watermarks.

- `textbook-photo.jpg`: a worn indigo calculus hardcover with an ivory page block and a faint geometry diagram on a pale blue table.
- `desk-lamp-photo.jpg`: a used navy anglepoise lamp, lit gently on a sandstone desktop with a cream wall.
- `dorm-chair-photo.jpg`: a compact used chair with a bent birch seat and navy legs on pale concrete.
- `headphones-photo.jpg`: a pair of matte navy wireless headphones on a pale smoky blue surface.

</details>

## Step 1 proposal

**Course:** CS310 Mobile Application Development  
**Project Title:** CampusMarket – Sabancı University Second-Hand Marketplace  
**Group Number:** Group 14 
**GitHub Repository Link:** https://github.com/ulasalpandiner/CS310_Project  

---

### Group Members
* **Ulas Alpandiner** (Student ID: 33831)
* **Ramazan Yucel** (Student ID: 34056)
* **Alper Kaan Gozubuyuk** (Student ID: 26625 )


---

## 1. Project Overview

### What the App Does
**CampusMarket** is a mobile application built using Flutter. It helps Sabancı University students buy and sell second-hand items (textbooks, electronics, dorm items, clothing) easily and safely on campus.

### Problem Addressed
Sabancı University students currently use the old "MySU" marketplace interface or informal WhatsApp and Telegram groups.
* **Outdated UI:** MySU is hard to navigate and search.
* **No Direct Messaging:** Communicating on MySU is slow.
* **Privacy Concerns:** Social media groups require sharing personal phone numbers.

### Intended Users
Sabancı University undergraduate and graduate students living on or commuting to the campus.

---

## 2. Features & Scope

### Core Features (Main MVP)
* **Student Authentication:** Registration and sign-in using verified @sabanciuniv.edu email addresses.
* **In-App Messaging:** Buyers and sellers exchange messages to arrange on-campus meetups. Messages are stored in the database and loaded when a conversation is opened or manually refreshed.
* **Item Listing & Management:** Sellers can post photos, titles, prices, descriptions, categories, and item conditions. They can also edit or delete listings.
* **Search & Category Filters:** Buyers can search for items by keywords and filter by price or category.
* **Home Feed:** Visual list showing active listings with photos and prices.

### Optional Features (Stretch Goals)
* **Boosted Listings:** Highlight or pin posts to the top of category feeds.
* **User Ratings:** Allow buyers and sellers to rate each other after trades.

---

## 3. Data Requirements & Backend

* **User Data:** Name, Sabancı email, student ID status, and profile image.
* **Listing Data:** Title, price, description, images, category, condition, status (Active/Sold), and date.
* **Chat Data:** Messages, sender/receiver IDs, and timestamps.
* **Backend Services:**
  * **Firebase Cloud Firestore:** Database for listings, user profiles, and chat messages.
  * **Firebase Storage:** Cloud storage for uploaded product photos.
  * **Firebase Authentication:** For account registration, email verification, and sign-in.

---

## 4. Potential Technical Challenges

* **Messaging and Error Handling:** Saving and retrieving messages in the correct order, and handling connection failures without losing user input.
* **Image Optimization:** Compressing high-resolution photos taken on mobile phones before uploading to conserve bandwidth.
* **State Management:** Managing login state and search filters smoothly across different Flutter screens.

---

## 5. Team Coordination and Contributions

**Step 1 Coordinator:** Ulaş Alpandiner

| Member | Step 1 tasks | Planned development responsibilities |
| :--- | :--- | :--- |
| **Ulaş Alpandiner** | Set up the repository, add collaborators, prepare the README and Flutter .gitignore, and coordinate Step 1. | Develop authentication and listing management; review code changes and resolve integration issues. |
| **Ramazan Yücel** | Describe data requirements, Firebase services, and potential technical challenges. | Implement database operations and messaging; check error handling and debug backend-related issues. |
| **Alper Kaan Gözübüyük** | Prepare the app overview, target users, and feature scope; prepare and format the proposal PDF. | Develop the home feed and search/filter screens; test user flows, identify bugs, and check UI consistency. |

*Shared responsibilities: All members will contribute to coding, review each other's work, test the application, and review each submission. Development assignments are preliminary and may be adjusted as the project progresses.*
