# Harf Yarışı

Flutter ile geliştirilen beyaz-turuncu İsim–Şehir–Hayvan–Bitki–Eşya–Ülke oyunu.

## Özellikler

- Tek oyunculu, aynı telefonda 1–4 kişilik sıra tabanlı oyun
- 60 saniyelik süre ve iki sütunlu kompakt cevap kartları
- Türkçe harf normalizasyonu ve altı kategoriye dağıtılmış kategori bazlı kapsamlı Türkçe sözlük
- Çevrim içi oda kodu, 2–4 oyunculu oda, ortak harf ve süre, sunucuda puanlama
- Oda sahibinin yeni tur başlatması ve oyuncu puan tablosu

## Çevrim içi sunucunun etkinleştirilmesi

> **Güncel durum:** Harf Yarışı için ayrı Supabase projesi oluşturuldu: `dmnhwypfbjlptucfxyky` (eu-central-1). Sunucu tabloları ve 11.413 kayıtlı geniş kategori sözlüğü kuruldu. Uygulamanın yayınlanabilir anahtarı kaynak kodda varsayılan yapılandırma olarak bulunur. **Authentication > Providers > Anonymous Sign-Ins** ayarı panelden mutlaka etkinleştirilmelidir.

1. [Harf Yarışı Supabase projesini](https://supabase.com/dashboard/project/dmnhwypfbjlptucfxyky) açın.
2. **Authentication > Providers > Anonymous Sign-Ins** özelliğini etkinleştirin. Bu ayar olmadan oda oluşturma çalışmaz.
3. SQL veritabanı kurulumu zaten yapıldı. Tekrar çalıştırmak gerekmiyor.
4. GitHub Actions > Android APK AAB üzerinden son derlemeyi kontrol edin; varsayılan URL ve publishable key kodda bulunuyor. İstenirse `HARF_SUPABASE_URL` ve `HARF_SUPABASE_PUBLISHABLE_KEY` Actions secrets ile değiştirilebilir.
5. İki gerçek Android cihazda oda oluşturma, kodla katılma ve tur puanlamasını test edin.

Sunucu tek turda aynı harfi tüm oyunculara verir ve cevapları kategori sözlüğüyle doğrular. Veritabanında **11.413 kayıt** vardır. APK/AAB içinde altı kategoriye ayrılmış **11.353 özgün veri satırı** ve mevcut ek sözcükler bulunur.

### Kelime sözlüğü kaynağı ve lisans

Kelime listeleri [Pulmaca Açık Veri](https://pulmaca.com.tr/veri/) üzerinden, Vikisözlük katkıcılarından türetilen ve düzenlenen **CC BY-SA 4.0** lisanslı kategori listeleridir. Detaylı atıf ve değişiklik açıklaması: `assets/dictionary/ATTRIBUTION.md`. Liste resmî TDK sözlüğü değildir.

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


## V3: Çevrim içi düello ve yeni özellikler

- **Düello:** Tam 2 oyuncu; arkadaş odası: 2–4 oyuncu; oda kodu kopyalama ve paylaşma.
- **Maç uzunluğu:** 3 veya 5 tur, sunucuda tutulan ortak puan tablosu.
- **Harf çarkı:** Yeni turdan önce 3 saniyelik animasyon, harf animasyon bitince görünür.
- **Hız bonusu:** Altı doğru cevap ilk 30 saniyede tamamlanırsa +20 puan.
- **Jokerler:** Maç boyunca bir defa ipucu, bir defa seçili kategoride ×2 puan, bir defa kişisel +10 saniye. Sunucu her hakkı denetler.
- **Sürpriz kategoriler:** Çift sayılı turlarda altıncı kategori; Meslek, Yemek, Spor veya Taşıt olabilir. Bunların başlangıç sözlüğü sınırlıdır; daha sonra genişletilecek.
- **İtiraz:** Reddedilen çevrim içi cevap için itiraz oluşturulabilir. Kullanıcı itirazı kendisi onaylayamaz. Veritabanı yöneticisi inceleme sonrası durumunu onaylarsa kelime kategori sözlüğüne eklenir ve ilgili tur puanı düzeltilir.
- **Görünüm:** Beyaz-turuncu altı kartlı iki sütunlu arayüz.

### Supabase kurulumu
Önce `supabase/harf_online_setup.sql` (temel yapı), ardından `supabase/harf_v3_features.sql`, `supabase/harf_v3_network_grace.sql` ve `supabase/harf_v3_appeal_review.sql` uygulanır. Gerçek Harf Yarışı Supabase projesine bu geçişler **uygulandı**. Anonim giriş açık olmalıdır.

İtirazları güvenli biçimde incelemek için Supabase SQL Editor'da:
```sql
select id,category,answer,status,created_at from public.harf_appeals
where status='pending' order by created_at;
-- Yalnızca doğruluğunu teyit ettiğiniz bir kelime için:
-- update public.harf_appeals set status='approved' where id='<itiraz-uuid>' and status='pending';
-- veya: update public.harf_appeals set status='rejected' where id='<itiraz-uuid>' and status='pending';
```
Kullanıcıların itiraz tablolarını doğrudan değiştirme yetkisi yoktur. Onaylanan kelime otomatik eklenir ve puanı düzeltilir.

Derlemeler `main` dalına gönderilen değişikliklerle GitHub Actions üzerinden tetiklenir; başarılı APK/AAB dosyaları **Artifacts** altında sunulur.
