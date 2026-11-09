# Harf Yarışı

Flutter ile geliştirilen beyaz-turuncu İsim–Şehir–Hayvan–Bitki–Eşya–Ülke oyunu.

## Özellikler

- Tek oyunculu, aynı telefonda 1–4 kişilik sıra tabanlı oyun
- 60 saniyelik süre ve iki sütunlu kompakt cevap kartları
- Türkçe harf normalizasyonu ve altı kategoriye dağıtılmış 400 örnek kelimelik sözlük
- Çevrim içi oda kodu, 2–4 oyunculu oda, ortak harf ve süre, sunucuda puanlama
- Oda sahibinin yeni tur başlatması ve oyuncu puan tablosu

## Çevrim içi sunucunun etkinleştirilmesi

> **Güncel durum:** Harf Yarışı için ayrı Supabase projesi oluşturuldu: `dmnhwypfbjlptucfxyky` (eu-central-1). Sunucu tabloları ve 400 kelimelik sözlük kuruldu. Uygulamanın yayınlanabilir anahtarı kaynak kodda varsayılan yapılandırma olarak bulunur. **Authentication > Providers > Anonymous Sign-Ins** ayarı panelden mutlaka etkinleştirilmelidir.

1. [Harf Yarışı Supabase projesini](https://supabase.com/dashboard/project/dmnhwypfbjlptucfxyky) açın.
2. **Authentication > Providers > Anonymous Sign-Ins** özelliğini etkinleştirin. Bu ayar olmadan oda oluşturma çalışmaz.
3. SQL veritabanı kurulumu zaten yapıldı. Tekrar çalıştırmak gerekmiyor.
4. GitHub Actions > Android APK AAB üzerinden son derlemeyi kontrol edin; varsayılan URL ve publishable key kodda bulunuyor. İstenirse `HARF_SUPABASE_URL` ve `HARF_SUPABASE_PUBLISHABLE_KEY` Actions secrets ile değiştirilebilir.
5. İki gerçek Android cihazda oda oluşturma, kodla katılma ve tur puanlamasını test edin.

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
