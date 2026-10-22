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
* **Student Authentication:** Registration and sign-in restricted to `@sabanciuniv.edu` email accounts.
* **Item Listing & Management:** Sellers can post photos, titles, prices, descriptions, categories, and item conditions. They can also edit or delete listings.
* **Search & Category Filters:** Buyers can search for items by keywords and filter by price or category.
* **In-App Direct Chat:** Real-time messaging between buyers and sellers to arrange local meetups safely.
* **Home Feed:** Visual list showing active listings with photos and prices.

### Optional Features (Stretch Goals)
* **Boosted Listings:** Highlight or pin posts to the top of category feeds.
* **Payment Simulation:** A simple UI demo for secure payments.
* **User Ratings:** Allow buyers and sellers to rate each other after trades.

---

## 3. Data Requirements & Backend

* **User Data:** Name, Sabancı email, student ID status, and profile image.
* **Listing Data:** Title, price, description, images, category, condition, status (Active/Sold), and date.
* **Chat Data:** Messages, sender/receiver IDs, and timestamps.
* **Backend Services:**
  * **Firebase Cloud Firestore:** Database for listings, user profiles, and chat messages.
  * **Firebase Storage:** Cloud storage for uploaded product photos.
  * **Firebase Auth:** User login and authentication.

---

## 4. Potential Technical Challenges

* **Real-Time Messaging:** Setting up live chat streams in Flutter using Firebase without performance delays.
* **Image Optimization:** Compressing high-resolution photos taken on mobile phones before uploading to conserve bandwidth.
* **State Management:** Managing login state and search filters smoothly across different Flutter screens.

---

