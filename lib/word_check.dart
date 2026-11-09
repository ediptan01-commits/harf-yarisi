class WordCheck {
  static const entries = <String, List<String>>{
    'İsim': ['Ahmet','Ali','Ayşe','Aslı','Burak','Buse','Can','Cem','Cansu','Çağla','Çetin','Çiğdem','Deniz','Derya','Davut','Elif','Emre','Ece','Fatma','Ferhat','Fırat','Gamze','Gökhan','Gül','Hasan','Hilal','Hakan','İbrahim','İrem','İpek','Kemal','Kerem','Kübra','Leyla','Levent','Lale','Mert','Murat','Melek','Naz','Nihat','Nehir','Onur','Okan','Oya','Pelin','Pınar','Polat','Rana','Recep','Rıza','Selin','Seda','Serkan','Tuğba','Tolga','Tuna','Umut','Ufuk','Uğur','Yusuf','Yağmur','Yasemin','Zeynep','Zafer','Zehra'],
    'Şehir': ['Ankara','Adana','Antalya','Aydın','Artvin','Amasya','Bursa','Bolu','Balıkesir','Bartın','Bilecik','Ceyhan','Cizre','Çorum','Çanakkale','Çankırı','Denizli','Diyarbakır','Düzce','Edirne','Erzurum','Eskişehir','Elazığ','Erzincan','Fatsa','Floransa','Frankfurt','Gaziantep','Giresun','Gümüşhane','Hatay','Hakkari','Hamburg','İstanbul','İzmir','İzmit','Konya','Kayseri','Kars','Kocaeli','Kırşehir','Londra','Lizbon','Lüleburgaz','Manisa','Mardin','Muğla','Mersin','Nevşehir','Niğde','New York','Ordu','Oslo','Ottawa','Paris','Prag','Polatlı','Rize','Roma','Rotterdam','Samsun','Sinop','Sivas','Sakarya','Trabzon','Tokat','Tekirdağ','Uşak','Urfa','Utrecht','Yalova','Yozgat','Yüksekova','Zonguldak','Zürih','Zara'],
    'Hayvan': ['Aslan','At','Ayı','Arı','Balık','Baykuş','Boğa','Ceylan','Civciv','Çakal','Çekirge','Çita','Deve','Domuz','Delfin','Eşek','Engerek','Emu','Fare','Fil','Fok','Geyik','Güvercin','Gergedan','Horoz','Hindi','Hamster','İnek','İguana','İpek böceği','Kedi','Köpek','Kartal','Kaplan','Kurt','Leylek','Lama','Leopar','Maymun','Martı','Manda','Narval','Nandu','Orka','Orangutan','Panda','Papağan','Penguen','Rakun','Ren geyiği','Serçe','Sincap','Sırtlan','Tavşan','Timsah','Tilki','Uğur böceği','Uskumru','Yılan','Yunus','Yarasa','Zebra','Zürafa'],
    'Bitki': ['Armut','Akasya','Ayçiçeği','Aloe vera','Bambu','Begonya','Buğday','Ceviz','Civanperçemi','Çam','Çilek','Çınar','Defne','Dereotu','Dut','Elma','Erik','Ebegümeci','Fesleğen','Fındık','Fasulye','Gül','Gelincik','Gürgen','Havuç','Hurma','Hibiskus','İncir','İğde','İris','Karanfil','Kavak','Kiraz','Kekik','Lale','Limon','Lavanta','Muz','Menekşe','Mısır','Nane','Nar','Nergis','Orkide','Okaliptüs','Papatya','Pırasa','Patates','Reyhan','Roka','Rezene','Söğüt','Sarımsak','Salatalık','Turp','Tarçın','Tütün','Unutma beni','Uçkun','Yasemin','Yonca','Yulaf','Zambak','Zeytin','Zencefil'],
    'Eşya': ['Ayna','Anahtar','Araba','Bardak','Bıçak','Bavul','Ceket','Cetvel','Cüzdan','Çanta','Çatal','Çekiç','Dolap','Defter','Düdük','Eldiven','Etek','Elek','Fener','Fırça','Fincan','Gözlük','Gitar','Gazete','Halı','Havlu','Hesap makinesi','İğne','İp','İbrik','Koltuk','Kalem','Kitap','Kamera','Lamba','Laptop','Leğen','Masa','Makas','Minder','Nal','Nevresim','Ocak','Oyuncak','Oklava','Perde','Pencere','Pil','Radyo','Raf','Rende','Saat','Sandalye','Süpürge','Telefon','Tabak','Tarak','Uçurtma','Uydu','Ustura','Yastık','Yatak','Yorgan','Zil','Zımba','Zarf'],
    'Ülke': ['Almanya','Arjantin','Avustralya','Arnavutluk','Belçika','Brezilya','Bulgaristan','Cezayir','Cibuti','Çad','Çekya','Çin','Danimarka','Dominika','Estonya','Endonezya','Ekvador','Fransa','Finlandiya','Fas','Gana','Gürcistan','Gabon','Hindistan','Hollanda','Hırvatistan','İtalya','İspanya','İran','Irak','Kanada','Kenya','Kazakistan','Letonya','Litvanya','Lübnan','Mısır','Meksika','Macaristan','Norveç','Nijerya','Nepal','Umman','Orta Afrika Cumhuriyeti','Polonya','Portekiz','Pakistan','Romanya','Rusya','Ruanda','Sırbistan','Singapur','Sudan','Türkiye','Tunus','Tayland','Uganda','Ukrayna','Uruguay','Yunanistan','Yeni Zelanda','Yemen','Zambiya','Zimbabve']
  };
  static String normalize(String value) {
    final symbols = <String,String>{
      'i':'İ','ı':'I','ğ':'Ğ','ü':'Ü','ş':'Ş','ö':'Ö','ç':'Ç',
    };
    return value.trim().replaceAll(RegExp(r'\s+'), ' ').split('').map(
      (c) => symbols[c] ?? c.toUpperCase(),
    ).join();
  }
  static bool check(String category, String letter, String answer) {
    final normalized = normalize(answer);
    if (normalized.isEmpty || !normalized.startsWith(normalize(letter))) return false;
    return (entries[category] ?? const <String>[]).any((word) => normalize(word) == normalized);
  }
}
