# CS310 Project Step 1 Proposal: CampusMarket

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
