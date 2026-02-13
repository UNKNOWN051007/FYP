# mobile_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


### Step 1: Configure API Connection

In **ALL** Dart files, update these lines:

```dart
api = MalaysianEmploymentAPI(
  baseUrl: 'http://YOUR_SERVER_IP:8000',  // Change this!
  apiKey: 'mea_YOUR_API_KEY',              // Change this!
);
```

**How to find your server IP:**

**Windows:**
```cmd
ipconfig
```
Look for "IPv4 Address"

**Mac/Linux:**
```bash
ifconfig | grep "inet "
```

**Important:** Your phone and computer must be on the **same WiFi network**!

### Step 5: Configure Permissions

#### Android (Required)

Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Add this line -->
    <uses-permission android:name="android.permission.INTERNET" />
    
    <application ...>
        ...
    </application>
</manifest>
```

#### iOS (Required)

Edit `ios/Runner/Info.plist`:

```xml
<dict>
    <!-- Add these lines -->
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
    
    <!-- Existing keys... -->
</dict>
```

### Step 6: Run the App

```bash
# Make sure a device/emulator is connected
flutter devices

# Run the app
flutter run
```

---

## 📁 Final File Structure

After setup, your structure should be:

```
mobile_app/
├── android/                          # Android native files
├── ios/                              # iOS native files
├── lib/
│   ├── services/
│   │   └── malaysian_employment_api.dart
│   ├── screens/
│   │   ├── chat_screen.dart
│   │   └── salary_calculator_screen.dart
│   └── main.dart
├── test/
├── pubspec.yaml
└── README.md
```

---

## ⚙️ Configuration Checklist

Before running the app:

- [ ] Backend server is running (`python backend/start_server.py`)
- [ ] You have generated an API key
- [ ] Updated `baseUrl` in all Dart files
- [ ] Updated `apiKey` in all Dart files
- [ ] Phone and computer on same WiFi
- [ ] Internet permission added (Android)
- [ ] ATS configuration added (iOS)
- [ ] Run `flutter pub get`

---

## 🧪 Testing

### Test 1: Check Server Connection

```bash
# From your phone's browser, visit:
http://YOUR_SERVER_IP:8000/health

# Should show:
{"status":"healthy","model_loaded":true,"timestamp":"..."}
```

### Test 2: Test API from Command Line

```bash
curl -X POST http://YOUR_SERVER_IP:8000/api/chat \
  -H "Content-Type: application/json" \
  -H "X-API-Key: YOUR_API_KEY" \
  -d '{"message": "What is minimum wage?"}'
```

### Test 3: Run Flutter App

```bash
flutter run
```

Try:
1. Open chat screen
2. Send a message
3. Check salary calculator

---

## 🐛 Troubleshooting

### "Connection refused" or "Failed to connect"

**Solutions:**
1. Check server is running on your computer
2. Verify phone and computer on same WiFi
3. Check firewall settings (allow port 8000)
4. Use `http://` not `https://`
5. Try server IP, not `localhost`

### "Invalid API Key" Error

**Solutions:**
1. Check API key is correct (no spaces)
2. Generate new key: `http://YOUR_IP:8000/docs` → `/admin/generate-key`
3. Make sure key is active in `api_keys.json`

### "SocketException: OS Error: Network is unreachable"

**Solutions:**
1. Check WiFi connection
2. Restart WiFi on both devices
3. Check firewall/antivirus blocking port 8000

### Flutter Build Errors

**Solutions:**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

---

## 📊 Performance Tips

1. **Use release mode** for better performance:
   ```bash
   flutter run --release
   ```

2. **Enable caching** in API service (add later)

3. **Add loading indicators** for better UX

---

## 🔒 Security Notes

**For Development:**
- Using `http://` is fine
- API key in code is acceptable

**For Production:**
- Use `https://` with SSL certificate
- Store API key in secure storage (flutter_secure_storage)
- Add user authentication
- Implement refresh tokens

---

## 📚 Additional Features to Add

- [ ] Offline mode with local caching
- [ ] Push notifications
- [ ] User accounts
- [ ] Chat history persistence
- [ ] Dark mode
- [ ] Multiple languages (Malay, Chinese)
- [ ] Voice input
- [ ] Share results feature

---

## 🔗 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [HTTP Package](https://pub.dev/packages/http)
- [Malaysian Employment Act 1955](https://www.ilo.org/dyn/natlex/natlex4.detail?p_lang=en&p_isn=42055)

---

## 💡 Quick Commands Reference

```bash
# Create project
flutter create mobile_app

# Add dependencies
flutter pub get

# Run app
flutter run

# Build APK (Android)
flutter build apk

# Build for iOS
flutter build ios

# Clean build
flutter clean

# Check devices
flutter devices

# Run tests
flutter test
```

---

## 📞 Need Help?

1. Check backend server logs
2. Check Flutter console for errors
3. Visit API docs: `http://YOUR_IP:8000/docs`
4. Test API with Postman/curl first

---

**Ready to start?** Run `flutter create mobile_app` and follow the steps above! 🚀