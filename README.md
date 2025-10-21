# 🍼 BabyShopHub — Flutter E-Commerce App

A modern mobile e-commerce application built with **Flutter** and **Supabase**, designed for a baby products store.  
It includes features for product browsing, shopping cart management, order placement, tracking, and user profile management.

---

## 🚀 Features

### 🛍️ User Features
- **Browse Products** – View available baby products by category.
- **Search Functionality** – Search by product name or category.
- **Product Details Page** – View detailed information, images, price, and reviews.
- **Add to Cart** – Add, remove, or update product quantities in the cart.
- **Checkout Process** – Choose shipping address and payment method.
- **Order Tracking** – Track order progress and status.
- **Order History** – View previously placed orders.
- **Profile Page** – View and edit user profile (name, phone number).
- **Persistent Bottom Navigation** – Navigate easily between core sections (Shop, Search, Cart, Orders, Profile).

### 🧑‍💼 Admin Features
- Dedicated **Admin Dashboard** to manage products, categories, and orders (only accessible to admin users).

<<<<<<< Updated upstream
---

## 🧩 Tech Stack

| Layer | Technology |
|-------|-------------|
| **Frontend** | Flutter (Dart) |
| **Backend** | Supabase (PostgreSQL + Auth + Storage) |
| **State Management** | setState / FutureBuilder |
| **Authentication** | Supabase Auth |
| **Database** | Supabase Tables |
| **Hosting** | Local or Supabase-hosted backend |

---

## 📸 Screens Overview

| Screen | Description |
|---------|-------------|
| **Auth Page** | User login & registration |
| **Shop Page** | Home screen with bottom navigation |
| **Products Page** | Displays products and categories |
| **Product Detail Page** | Shows product info, ratings, and reviews |
| **Cart Page** | Displays user’s cart and allows item quantity changes |
| **Checkout Page** | Address selection, payment method, and order summary |
| **Order History Page** | Shows all past orders |
| **Track Order Page** | Displays order tracking timeline |
| **Profile Page** | User information and logout |
| **Edit Profile Page** | Allows editing name and phone number |
| **Admin Home Page** | Dashboard for managing products and orders |

---
## Mock-Up
<img width="1920" height="1440" alt="BabyShots" src="https://github.com/user-attachments/assets/b811ad61-abf1-4ee1-9d2e-e03739428277" />


## ⚙️ Project Setup

Follow these steps to get started locally:

### 1️⃣ Clone the Repository
```bash
git clone https://github.com/JKanaiya/FlutterBabyShopHub_eProject.git
cd FlutterBabyShopHub_eProject
````

### 2️⃣ Install Dependencies

```bash
flutter pub get
```

### 3️⃣ Configure Supabase

* Create a [Supabase project](https://supabase.io/).
* Copy your **Project URL** and **Anon Key**.
* In `main.dart`, replace:

  ```dart
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
  ```
* Ensure you have these Supabase tables:

    * `profiles` (id, email, name, phone, is_admin)
    * `products` (id, name, description, price, image_url, category)
    * `cart_items`
    * `orders`
    * `order_items`
    * `addresses`
    * (Optionally: `reviews`)

### 4️⃣ Run the App

```bash
flutter run
```

---

## 📂 Project Structure

```
lib/
│
├── main.dart                 # App entry point
├── theme.dart                # Custom theme setup
├── util.dart                 # Utility helpers
│
├── screens/
│   ├── auth_page.dart
│   ├── products_page.dart
│   ├── shop/
│   │   ├── shop_page.dart
│   │   ├── cart_page.dart
│   │   ├── checkout_page.dart
│   │   ├── search_page.dart
│   │   ├── navigation.dart
│   ├── orders/
│   │   ├── order_summary_page.dart
│   │   ├── order_history_page.dart
│   │   ├── track_order_page.dart
│   ├── profile/
│   │   ├── profile_page.dart
│   │   ├── edit_profile_page.dart
│   ├── admin/
│       ├── admin_home.dart
│
└── assets/
    └── images/               # App icons, logos, payment method images
```

---

## 💳 Supported Payment Methods (Dummy)

* PayPal 🅿️
* M-Pesa 🇰🇪
* Apple Pay 🍎
* Google Pay 💳

*(For demo only — no real payment integration yet.)*

---

## 👨‍💻 Contributors

| Name                                                | Role      |
|-----------------------------------------------------|-----------|
| [**Jonathan Kanaiya**](https://github.com/JKanaiya) | Developer |
| [**Peter Njuguna**](https://github.com/peterboro)   | Developer |
| [**Robert Mzungu**](https://github.com/msungu1)     | Developer |
| [**John Prince**](https://github.com/jaydola)       | Developer |
| [**Peter Irungu**](https://github.com/toshpp)       | Developer |

---

## 🧠 Future Improvements

* Real payment gateway integration (Stripe, M-Pesa API)
* Product recommendations (AI-based)
* Push notifications
* Dark mode
* Cloud image optimization

---

## 🏁 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

> Built with ❤️ using **Flutter** + **Supabase**
> for a smoother baby shopping experience 🍼

```
=======
For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
# FlutterBabyShopHub_eProject


