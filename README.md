# SIPPA (Sistem Informasi Pertumbuhan dan Perkembangan Anak)

SIPPA is a mobile platform that helps teachers and parents track, document, and support young children’s growth and learning development in line with Indonesia’s Merdeka Curriculum. It is designed for early childhood education institutions such as RA and PAUD to provide accurate and integrated information on children’s learning achievements and development. The application supports four types of users: Super Admin, School Admin/Principal, Teachers, and Parents/Students.

## ✨ Features

- 📖 Anecdotal Notes (Catatan Anekdot)
- 🎯 Learning Outcomes (Capaian Pembelajaran)
- 🖼️ Children’s Work Documentation (Dokumentasi Hasil Karya)
- 📝 Rubrics (Rubrik)
- 📊 Child Growth Records (Catatan Pertumbuhan Anak)
- 👶 Student Management (manajemen Murid)
- 👩‍🏫 Teacher Management (manajemen Guru)
- 🏫 Admin Management (manajemen Admin)

## 🛠️ Tech Stack

- [Flutter](https://flutter.dev/) v3.32.8
- [Dart](https://dart.dev/) v3.8.1
- [Appwrite](https://appwrite.io/) (Backend as a Service)

## 🚀 Getting Started

Clone the repository:

```bash
git clone https://github.com/lukman-hakim-123/SIPPA.git
```

Install dependencies:

```bash
flutter pub get
```

Copy the example environment file and configure your credentials:

```bash
cp .env.example .env
```

Fill in your .env with your Appwrite project settings:

- APPWRITE_ENDPOINT
- APPWRITE_PROJECT_ID
- APPWRITE_DATABASE_ID

Generate required files:

```bash
dart run build_runner build
```

Run the app:

```bash
flutter run
```
