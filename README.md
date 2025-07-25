# Lunneettez - Aplikasi Penjualan Aksesoris

Aplikasi Flutter untuk penjualan aksesoris yang terhubung dengan backend Laravel menggunakan API Sanctum.

## Fitur

- ✅ Halaman login dengan validasi form
- ✅ Integrasi dengan API Laravel Sanctum
- ✅ Penyimpanan token menggunakan SharedPreferences
- ✅ Loading state saat proses login
- ✅ Error handling untuk response API
- ✅ Navigasi otomatis berdasarkan status login
- ✅ UI modern dan responsif
- ✅ Splash screen dengan pengecekan status login

## Struktur Proyek

```
lib/
├── main.dart                 # Entry point aplikasi
├── models/
│   ├── user_model.dart       # Model untuk data user
│   └── login_response.dart   # Model untuk response login
├── screens/
│   ├── splash_screen.dart    # Splash screen
│   ├── login_screen.dart     # Halaman login
│   └── home_screen.dart      # Halaman utama
└── services/
    └── auth_service.dart     # Service untuk autentikasi
```

## Dependencies

- `http: ^1.1.0` - Untuk HTTP requests
- `shared_preferences: ^2.2.2` - Untuk penyimpanan token

## Konfigurasi API

Endpoint API diatur di `lib/services/auth_service.dart`:

```dart
static const String baseUrl = 'http://192.168.1.14/Project_Akhir_Kelompok/public/api';
```

## Response API

### Response Sukses
```json
{
  "status": true,
  "message": "Login berhasil",
  "data": {
    "user": {
      "id": 5,
      "nama": "Pelanggan 1",
      "email": "pelanggan1@example.com",
      "peran": "pelanggan"
    },
    "token": "1|xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  }
}
```

### Response Gagal
```json
{
  "status": false,
  "message": "Email atau password salah"
}
```

## Cara Menjalankan

1. Pastikan Flutter sudah terinstall
2. Clone repository ini
3. Jalankan `flutter pub get` untuk menginstall dependencies
4. Pastikan backend Laravel sudah berjalan di `http://192.168.1.14/Project_Akhir_Kelompok/public`
5. Jalankan aplikasi dengan `flutter run`