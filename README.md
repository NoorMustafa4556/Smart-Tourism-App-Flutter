# 🌍 Smart Tourism - Premium VIP Travel Ecosystem

**Smart Tourism** is a high-end, cross-platform travel solution built with **Flutter** and **Firebase**. Designed with a "Lavish" aesthetic, it provides a VIP experience for travelers and a robust management system for admins.

---

## 🌟 Key Features

### 📱 1. Traveler Experience
- **Premium UI/UX:** Deep navy gradients, gold accents, and elegant Google Fonts (Poppins & Montserrat).
- **Smart Discovery:** Explore destinations via circular categories, real-time search, and a beautiful grid layout.
- **Dynamic Bookings:** 
    - Real-time cost calculation based on persons and stay duration.
    - Nearby Hotel selection integrated directly into the booking flow.
    - Secure payment proof upload (Screenshot).
- **Trip Planning:** Create custom itineraries and add your favorite spots.
- **Real-time History:** Track booking status (Pending/Approved/Rejected) with admin feedback.
- **Push Notifications:** Stay updated on your booking status and travel alerts.
- **VIP Security:** Password-protected identity re-verification for profile updates.

### 🔐 2. Robust Firebase Integration
- **Authentication:** Secure Email/Password login with session persistence.
- **Firestore Database:** Real-time synchronization for users, places, hotels, reviews, and bookings.
- **Cloud Storage:** High-performance storage for profile pics and payment receipts.
- **Web CORS Support:** Built-in proxy handling for web-compatible network images.

### 🛠️ 3. Advanced Admin Panel
- **Comprehensive Dashboard:** Manage the entire ecosystem from a single interface.
- **Booking Management:** Review, Approve, or Reject bookings with custom remarks.
- **Content Management:** Add, edit, or delete Places and Hotels with real-time updates.
- **Financial Control:** Manage payment methods (JazzCash, EasyPaisa, etc.) for the app.
- **Analytics:** At-a-glance status counts for total bookings and active spots.

---

## 🚀 Tech Stack

- **Frontend:** Flutter (Dart)
- **Backend:** Firebase (Auth, Firestore, Storage, Messaging)
- **State Management:** Provider
- **Design:** Material 3, Google Fonts, Custom VIP Gradients
- **Key Plugins:** `cached_network_image`, `image_picker`, `intl`, `firebase_messaging`, `intl_phone_field`.

---

## 📂 Professional Project Structure

```text
lib/
├── Admin/          # Admin Dashboard, Manage Places, Hotels, & Payments
├── Auth/           # Login, SignUp, Welcome, Profile Setup, Splash
├── Models/         # Data Models (Place, Hotel, Booking, Review, etc.)
├── Providers/      # State Management (AuthProvider)
├── Screens/        # Home, Place Details, Booking Forms, My Bookings, Trip Plans
├── Services/       # Firebase, Notifications, Database Logic
├── Widgets/        # Reusable UI Components
└── main.dart       # Entry Point & Theme Configuration
```

---

## 🎨 Design System

- **Primary Colors:** VIP Navy (`#000428`) and Deep Blue (`#004E92`).
- **Accents:** Luxury Amber (`#FFB300`) for premium highlights.
- **Typography:** `Poppins` and `Montserrat` for a sleek, modern look.
- **Vibe:** Lavish, Clean, and Professional.

---

## 📸 App Screenshots – Mobile Application

<p align="center">
  <img src="https://github.com/NoorMustafa4556/Smart-Tourism-App-Flutter/blob/main/assets/images/1.png?raw=true" width="30%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Tourism-App-Flutter/blob/main/assets/images/2.png?raw=true" width="30%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Tourism-App-Flutter/blob/main/assets/images/3.png?raw=true" width="30%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Tourism-App-Flutter/blob/main/assets/images/4.png?raw=true" width="30%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Tourism-App-Flutter/blob/main/assets/images/5.png?raw=true" width="30%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Tourism-App-Flutter/blob/main/assets/images/6.png?raw=true" width="30%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Tourism-App-Flutter/blob/main/assets/images/7.png?raw=true" width="30%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Tourism-App-Flutter/blob/main/assets/images/8.png?raw=true" width="30%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Tourism-App-Flutter/blob/main/assets/images/9.png?raw=true" width="30%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Tourism-App-Flutter/blob/main/assets/images/10.png?raw=true" width="30%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Tourism-App-Flutter/blob/main/assets/images/11.png?raw=true" width="30%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Tourism-App-Flutter/blob/main/assets/images/12.png?raw=true" width="30%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Tourism-App-Flutter/blob/main/assets/images/13.png?raw=true" width="30%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Tourism-App-Flutter/blob/main/assets/images/14.png?raw=true" width="30%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Tourism-App-Flutter/blob/main/assets/images/15.png?raw=true" width="30%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Tourism-App-Flutter/blob/main/assets/images/16.png?raw=true" width="30%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Tourism-App-Flutter/blob/main/assets/images/17.png?raw=true" width="30%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Tourism-App-Flutter/blob/main/assets/images/18.png?raw=true" width="30%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Tourism-App-Flutter/blob/main/assets/images/19.png?raw=true" width="30%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Tourism-App-Flutter/blob/main/assets/images/20.png?raw=true" width="30%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Tourism-App-Flutter/blob/main/assets/images/21.png?raw=true" width="30%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Tourism-App-Flutter/blob/main/assets/images/22.png?raw=true" width="30%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Tourism-App-Flutter/blob/main/assets/images/23.png?raw=true" width="30%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Tourism-App-Flutter/blob/main/assets/images/24.png?raw=true" width="30%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Tourism-App-Flutter/blob/main/assets/images/25.png?raw=true" width="30%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Tourism-App-Flutter/blob/main/assets/images/26.png?raw=true" width="30%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Tourism-App-Flutter/blob/main/assets/images/27.png?raw=true" width="30%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Tourism-App-Flutter/blob/main/assets/images/28.png?raw=true" width="30%"/>
  <img src="https://github.com/NoorMustafa4556/Smart-Tourism-App-Flutter/blob/main/assets/images/29.png?raw=true" width="30%"/>
</p>

---

## 🛠️ Setup Instructions

1. **Firebase Config:** 
   - Create a project on Firebase Console.
   - Enable Auth, Firestore, Storage, and Messaging.
   - Run `flutterfire configure` to link your app.
2. **Security Rules:** 
   - Ensure Firestore and Storage rules allow authenticated reads/writes.
3. **Run App:**
   ```bash
   flutter pub get
   flutter run
   ```

---

# 👋🏻 Hi, I'm Noor Mustafa

A passionate and results-driven **Flutter Developer** from **Bahawalpur, Pakistan**, specializing in building elegant, scalable, and high-performance cross-platform mobile applications.

With a strong focus on **UI/UX Excellence** and **Full-Stack Firebase Integration**, I aim to deliver "VIP-level" applications that wow users at first sight.

---

## 🚀 My Expertise

- 🧑🏻‍💻 **VIP Flutter UI** – Crafted with precision and modern design trends.
- 🔗 **Firebase Expert** – Real-time databases, auth systems, and cloud functions.
- 🎨 **User-Centric Design** – Focusing on smooth transitions and lavish aesthetics.
- ⚙️ **State Management** – Scalable architecture using Provider.

> 🎯 Explore my world of widgets: [github.com/NoorMustafa4556](https://github.com/NoorMustafa4556)

---

- 📍 *Location:* Bahawalpur, Punjab, Pakistan
- 📱 *WhatsApp:* [+92 308 7655076](https://wa.me/923087655076)

---

> “Every line of code is a step towards a more beautiful digital world.”
