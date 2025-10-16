# Élure: Beauty Products E-Commerce

> **"Glow with Grace."** A prototype mini-e-commerce application for the Élure skincare brand, demonstrating full CRUD (Create, Read, Update, Delete) functionality using Flutter.

[![Built with Flutter](https://img.shields.io/badge/Flutter-v3.x-blue.svg)](https://flutter.dev/)
[![Core Feature](https://img.shields.io/badge/Feature-Full_CRUD-green)](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete)
[![API Communication](https://img.shields.io/badge/Networking-HTTP_Package-orange)](https://pub.dev/packages/http)

---

## 🌸 Brand & Project Overview

**Élure** (Pronunciation: /ay-loor/) is a modern skincare brand rooted in **minimalist French elegance**. This application serves as a prototype for its online store, designed to be simple, sophisticated, and sensorial—just like the brand itself.

The primary function of the application is to demonstrate robust data management capabilities by allowing an admin user to control the entire product catalogue via API endpoints.

## ⚙️ Core Technical Objectives (CRUD)

This project achieves the full spectrum of CRUD operations, applying them directly to the product catalogue of the Élure store:

| Operation | E-commerce Functionality | HTTP Method | Target Screen/Endpoint |
| :--- | :--- | :--- | :--- |
| **Create** | **Add New Product** | `POST` | Admin Product Creation Form |
| **Read** | **View Catalogue** | `GET` | Main Product Listing Screen |
| **Update** | **Edit Stock/Price** | `PUT` | Product Detail/Edit Form |
| **Delete** | **Remove Product** | `DELETE` | Product Detail/Admin View |

## 🎨 UI/UX Design Focus (Élure Aesthetic)

Adhering to the "Sleek, soft, very French" aesthetic, the application's UI emphasizes clarity, negative space, and elegant typography.

* **Color Palette:** Dominated by soft neutrals (whites, creams, light grays) with subtle, muted accents to reflect the brand's focus on **"effortless radiance."**
* **Typography:** Clean, readable, and modern sans-serif fonts are used for a sophisticated, minimalist feel.
* **Product Presentation:** Product cards feature high-quality imagery and minimal text overlay, allowing the product's "luminous beauty" to be the focal point.
* **Form Design:** CRUD forms are simplified and highly intuitive, reflecting the concept of a **"minimal routine."**

---

## 💻 Technical Stack & Implementation

| Component/Package | Purpose in Élure App |
| :--- | :--- |
| **Framework** | Flutter (Dart) | Building the clean, cross-platform UI. |
| **Networking** | `http` package | Handling all four CRUD API calls (`GET`, `POST`, `PUT`, `DELETE`). |
| **Data Handling** | `FutureBuilder` | Manages the asynchronous loading and rendering of the Product Catalogue (`GET` operation) in the UI. |
| **State Management** | (Inferred) `Provider` | Used for managing the application state, especially for refreshing the product list immediately after a `POST`, `PUT`, or `DELETE` operation to show updated data. |

### Implementation Details

1.  **API Service Layer:** A dedicated service class handles all HTTP requests, ensuring clean separation of business logic from the UI.
2.  **Product Model:** A strongly typed Dart model (`ProductModel`) is implemented to correctly serialize JSON data into usable objects and deserialize outgoing data for `POST` and `PUT` requests.
3.  **Immediate Feedback:** After any modification (`POST`, `PUT`, or `DELETE`), the main Product Listing screen is automatically refreshed (e.g., using a mechanism like `setState` after `await`ing the API call) to immediately display the successful changes to the catalogue.

---

### 🖥️ Project Screenshots
https://github.com/user-attachments/assets/7b995bac-8cd2-40ec-9e90-8b3d201f3afd

---

## 🚀 Installation and Setup

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/FarahAzhari/elure_app
    cd elure_app
    ```
2.  **Install Flutter Dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Run the Application:**
    ```bash
    flutter run
    ```
