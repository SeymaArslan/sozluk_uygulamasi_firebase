class Kelimeler{
  String kelime_id;
  String ingilizce;
  String turkce;

  Kelimeler(this.kelime_id, this.ingilizce, this.turkce);

  factory Kelimeler.fromJson(String key, Map<dynamic, dynamic> json){  // 2 parametre istiyoruz, buradaki json a her satır verisini göndereceğiz
    return Kelimeler(key, json["ingilizce"] as String, json["turkce"] as String); // gelen json verisini nesneye dönüştürüyoruz, daha sonra bu nesneden liste oluşturacağız
  }
}