import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sozluk_uygulamasi_firabase/DetaySayfa.dart';
import 'package:sozluk_uygulamasi_firabase/Kelimeler.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});



  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  /*
  Firebase veritabanındaki keyi id olarak göstereceğiz tabloda id bilgisi boş
  * */

  bool aramaYapiliyorMu = false;
  String aramaKelimesi = "";

  var refKelimeler = FirebaseDatabase.instance.ref().child("kelimeler"); // veriyi alacağımız referans noktasını oluşturduk.


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: aramaYapiliyorMu
            ? TextField(
          decoration: InputDecoration(
              hintText: "Arama için bir şey yazın"),
          onChanged: (aramaSonucu){
            print("Arama sonucu : $aramaSonucu");
            setState(() {
              aramaKelimesi = aramaSonucu;
            });
          },
        )
            : Text("SÖZLÜK UYGULAMASI") ,
        actions:[
          aramaYapiliyorMu
              ? IconButton(
            onPressed: (){
              setState(() {
                aramaYapiliyorMu = false;
                aramaKelimesi = "";
              });
            },
            icon: Icon(Icons.cancel),
          )
              : IconButton(
            onPressed: (){
              setState(() {
                aramaYapiliyorMu = true;
              });
            },
            icon: Icon(Icons.search),
          ),
        ],
      ),
      body: StreamBuilder<DatabaseEvent>( // referans noktasını kullanacağımız yapı, StreamBuilder firebase e özel bir yapıdır.
        stream: refKelimeler.onValue, // referans noktasına eriştik
        //future: aramaYapiliyorMu ? aramaYap(aramaKelimesi) : tumKelimeleriGoster(), // aramaYapılıyorMu false ise normal arayüz görünecek, true ise girdiğimiz harfi içeren kelimeleri göstereecek
        builder: (context, event){
          if(event.hasData){  // veri var mı yok mu kontrolü
            //var kelimelerListesi = <Kelimeler>[];
            List<Kelimeler> kelimelerListesi = [];

            var gelenDegerler = event.data!.snapshot.value as dynamic;

            if(gelenDegerler != null){
              gelenDegerler.forEach((key, nesne) {  // verileri key ve nesne olarak tek tek aldık

                var gelenKelime = Kelimeler.fromJson(key, nesne); // önce kelime nesnesimi alacağız

                // arama yapma kontrolü yapıyoruz içerisinde harf içerenleri listeleyecek şekilde
                if(aramaYapiliyorMu){ // true ise burası çalışacak
                  if(gelenKelime.ingilizce.contains(aramaKelimesi)){  // diyelim ki arama kelimesinde en son a varsa, gelen kelime içerisinde ingilizce alanında a ya eşitmi içerisinde var mı yok mu diye arama yapacak
                    kelimelerListesi.add(gelenKelime);  // eğer eşleşme varsa liste içerisine aktaracağız
                  }

                } else{ // arama yapılmıyorsa  bütün kelimeleri gösterecek şekilde çalışacağız
                  kelimelerListesi.add(gelenKelime);
                }

              });
            }
            return ListView.builder(
              itemCount: kelimelerListesi!.length,
              itemBuilder: (context,indeks){
                var kelime = kelimelerListesi[indeks];
                return GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => DetaySayfa(kelime: kelime)));
                  },
                  child: SizedBox( height: 50,
                    child: Card(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(kelime.ingilizce, style: TextStyle(fontWeight: FontWeight.bold),),
                          Text(kelime.turkce),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else  {
            return Center();
          }
        },
      ),
    );
  }
}
