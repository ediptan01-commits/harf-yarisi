# Harf Yarışı

Flutter ile geliştirilen beyaz-turuncu İsim–Şehir–Hayvan–Bitki–Eşya–Ülke oyunu.

## Özellikler

- Tek oyunculu, aynı telefonda 1–4 kişilik sıra tabanlı oyun
- 60 saniyelik süre ve iki sütunlu kompakt cevap kartları
- Türkçe harf normalizasyonu ve altı kategoriye dağıtılmış 400 örnek kelimelik sözlük
- Çevrim içi oda kodu, 2–4 oyunculu oda, ortak harf ve süre, sunucuda puanlama
- Oda sahibinin yeni tur başlatması ve oyuncu puan tablosu

## Çevrim içi sunucunun etkinleştirilmesi

> **Önemli:** Çevrim içi ekran kodu hazırdır ancak sunucu bilgileri girilmeden oda oluşturma çalışmaz. Veritabanını yanlışlıkla başka bir uygulamanın projesine yüklemeyin.

1. Harf Yarışı için bir Supabase projesi seçin veya oluşturun.
2. Supabase Auth > Providers bölümünden **Anonymous Sign-Ins** özelliğini etkinleştirin.
3. SQL Editor'da `supabase/harf_online_setup.sql` içeriğini çalıştırın.
4. GitHub deposunun **Settings > Secrets and variables > Actions** bölümüne iki repository secret ekleyin:
   - `HARF_SUPABASE_URL`: proje URL'si
   - `HARF_SUPABASE_PUBLISHABLE_KEY`: publishable/anon anahtarı (service_role **değil**)
5. GitHub Actions > Android APK AAB > **Run workflow** ile yeni bir APK/AAB üretin.
6. İki cihazda uygulamayı açarak oda oluşturma, kodla katılma ve 60 saniyelik turu test edin.

Sunucu tek turda aynı harfi tüm oyunculara verir, cevapları veritabanındaki kategori sözlüğüne göre doğrular. Kelime listesi başlangıç sürümünde **400 sözcük** içerir; henüz kapsamlı Türkçe sözlük değildir.

## Derleme

```bash
flutter create --platforms=android --org com.teknolojix .
flutter pub get
flutter test
flutter build apk --release
flutter build appbundle --release
```

GitHub Actions, her `main` güncellemesinde APK ve AAB üretimini dener ve başarılıysa Artifacts bölümüne yükler.

**Google Play uyarısı:** CI üzerinde Flutter'ın varsayılan release imzalama düzeniyle oluşturulan AAB, Play Console'a üretim sürümü olarak yüklenmeden önce mevcut uygulamanın kalıcı yükleme anahtarıyla imzalanmalıdır. Bu depoda henüz üretim keystore yapılandırması yoktur.
