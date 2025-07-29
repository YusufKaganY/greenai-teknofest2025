import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(Uygulamam_a());
}

List<String> tahminler = [];

class Uygulamam_a extends StatefulWidget {
  const Uygulamam_a({super.key});

  @override
  _UygulamamState createState() => _UygulamamState();
}

class _UygulamamState extends State<Uygulamam_a>
    with SingleTickerProviderStateMixin {
  Uint8List? _imageData;
  late AnimationController _controller;
  late Animation<double> _animation;
  Uint8List? _imageBytes;
  final picker = ImagePicker();
  String? _prediction;
  List<dynamic> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      Uint8List bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageData = bytes;
      });
      _predictImage(bytes);
    }
  }

  Future<void> _predictImage(Uint8List imageBytes) async {
    var url = Uri.parse('http://192.168.206.1:5000/predict');
    var request = http.MultipartRequest('POST', url);
    request.files.add(http.MultipartFile.fromBytes('image', imageBytes,
        filename: 'image.jpg'));
    List<String> _predictionList = [];

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = json.decode(await response.stream.bytesToString());
        if (responseData.isNotEmpty) {
          print(responseData);

          List<String> predictions = [];
          for (var i = 0; i < responseData.length; i++) {
            var className = responseData[i]['class_name'];

            switch (className) {
              case "sweat":
                predictions.add("Uzun kollu");
                break;
              case "tshirt":
                predictions.add("Kısa kollu");
                break;
              case "pants":
                predictions.add("Pantolon");
                break;
              case "jacket":
                predictions.add("Ceket");
                break;
              case "shirt":
                predictions.add("Gömlek");
                break;
              case "cardboard":
                predictions.add("Karton");
                break;
              case "dress":
                predictions.add("Elbise");
                break;
              case "glass":
                predictions.add("Cam");
                break;
              case "metal":
                predictions.add("Metal");
                break;
              case "paper":
                predictions.add("Kağıt");
                break;
              case "plastic":
                predictions.add("Plastik");
                break;
              case "shorts":
                predictions.add("Şort");
                break;
              case "skirt":
                predictions.add("Etek");
                break;
              case "suit":
                predictions.add("Takım elbise");
                break;
              case "tie":
                predictions.add("Kravat");
                break;
              default:
                predictions.add("Bilinmeyen Kategori");
            }
          }
          Set<String> predictionSet = predictions.toSet();
          List<String> Predictions = predictionSet.toList();
          tahminler = List.from(Predictions);
          tahminler.insert(0, 'Tümü');

          setState(() {
            _predictionList = Predictions;
            _prediction = _predictionList.isNotEmpty
                ? _predictionList.join(", ")
                : "Bilinmeyen Kategori";
          });

          print(predictions);
          _fetchSuggestions();
        }
      } else {
        print('❌ Prediction API failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error: $e');
    }
  }

  Widget _buildMahalleSection(String title, List<String> locations) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
              fontSize: 14,
            ),
          ),
          ...locations.map(
            (loc) => Text("• $loc"),
          ),
          SizedBox(height: 6),
        ],
      ),
    );
  }

  void _showMapPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.all(16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Geri Dönüşüm Noktaları",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Container(
                height: 500,
                width: 450,
                padding: EdgeInsets.all(10),
                child: InteractiveViewer(
                  boundaryMargin: EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 5.0,
                  child: Stack(
                    children: [
                      SvgPicture.asset(
                        'assets/images/Turkey_location_map.svg',
                        fit: BoxFit.contain,
                        width: 245,
                        height: 400,
                      ),
                      Positioned(
                        left: 345,
                        top: 160,
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Atık Getirme Merkezleri"),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Image.asset(
                                            'assets/gdNoktalar/gdErzurum.png',
                                            width: 400,
                                            height: 400,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          "Mobil Atık Getirme Merkezlerinin bulunduğu alanlar aşağıda listelenmiştir.\n",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        _buildMahalleSection(
                                          "ABDURRAHMAN GAZİ MAHALLESİ",
                                          [
                                            "Erzurum İl Emniyet Müdürlüğü Binası Arkası",
                                          ],
                                        ),
                                        _buildMahalleSection(
                                          "ADNAN MENDERES MAHALLESİ",
                                          [
                                            "Palandöken Belediyesi Hizmet Binası Arkası",
                                            "Marketler Ziraat Bankası Karşısı",
                                            "Adnan Menderes Aile Sağlığı Merkezi Önü",
                                            "Esma Sokak Bölge Eğitim Düzgün Market Yanı",
                                          ],
                                        ),
                                        _buildMahalleSection(
                                          "HÜSEYİN AVNİ ULAŞ MAHALLESİ",
                                          [
                                            "Selimiye Camii Önü",
                                            "77. Sokak Şok Market Yanı",
                                            "TOKİ İlkokulu Önü",
                                            "Prestij Caddesi",
                                            "Yıldızkent Düzgün Market Karşısı",
                                          ],
                                        ),
                                        _buildMahalleSection(
                                          "MÜFTÜ SOLAKZADE MAHALLESİ",
                                          [
                                            "Form AVM Önü",
                                            "Aşık Sümmani Kültür Merkezi Önü",
                                          ],
                                        ),
                                        _buildMahalleSection(
                                          "YUNUS EMRE MAHALLESİ",
                                          [
                                            "Şehitler Parkı Altı",
                                            "Ulaş Caddesi Çamlıca Park Evleri Önü",
                                            "Kayakyolu Düzgün Market Karşısı",
                                            "İbrahim Polat Caddesi Üzeri",
                                            "Yunus Emre Aile Sağlığı Merkezi Önü",
                                            "12 Mart Parkı Karşısı",
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        InkWell(
                                          onTap: () async {
                                            final url = Uri.parse(
                                                "https://www.palandoken.bel.tr/palandoken-rehberi/mobil-atik-merkezleri-16");
                                            if (await canLaunchUrl(url)) {
                                              await launchUrl(url,
                                                  mode: LaunchMode
                                                      .externalApplication);
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        "Bağlantı açılamadı")),
                                              );
                                            }
                                          },
                                          child: Text(
                                            "Kaynak: https://www.palandoken.bel.tr/palandoken-rehberi/mobil-atik-merkezleri-16",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic,
                                              color: const Color.fromARGB(
                                                  255, 71, 77, 116),
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text("Tamam"),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 18,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 70,
                        top: 130,
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Atık Getirme Merkezleri"),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Image.asset(
                                            'assets/gdNoktalar/gdIstanbul.png',
                                            width: 400,
                                            height: 400,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          "Mobil Atık Getirme Merkezlerinin bulunduğu alanlar aşağıda listelenmiştir.\n",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        _buildMahalleSection(
                                          "KADIKÖY BELEDİYESİ 1. SINIF ATIK GETİRME MERKEZİ",
                                          [
                                            "Hasanpaşa Mahallesi Fahrettin Kerim Gökay Caddesi No:2 Belediye Bahçesi",
                                            "0216 542 50 26",
                                            "Kadıköylüler hafta içi 08:30-17:00; Cumartesi günleri ise 09:00-16:00 saatleri arasında evlerindeki atıklarını Kadıköy Belediyesi 1. Sınıf Atık Getirme Merkezi’ne getirebilirler.",
                                          ],
                                        ),
                                        _buildMahalleSection(
                                          "19 MAYIS",
                                          [
                                            "19 Mayıs Mah. Okur Sokak",
                                          ],
                                        ),
                                        _buildMahalleSection(
                                          "ACIBADEM",
                                          [
                                            "Fatih Sokak. Nautilus AVM Otoparkı",
                                          ],
                                        ),
                                        _buildMahalleSection(
                                          "BOSTANCI",
                                          [
                                            "Bostancı Mah. Bağdat Cad. No:543",
                                          ],
                                        ),
                                        _buildMahalleSection(
                                          "CAFERAĞA",
                                          [
                                            "Caferağa Mah. Küçük Moda Burnu-Şair Nefi Sokak Kesişimi",
                                          ],
                                        ),
                                        _buildMahalleSection(
                                          "EĞİTİM",
                                          [
                                            "Feneryolu Mah. Fahrettin Kerim Gökay Cad. 161/3 Önü",
                                          ],
                                        ),
                                        _buildMahalleSection(
                                          "FENERYOLU",
                                          [
                                            "26 Mart Parkı Kızıltoprak İstasyon Cad. Erdoğdu Sok. Kesişimi",
                                          ],
                                        ),
                                        _buildMahalleSection(
                                          "KOZYATAĞI",
                                          [
                                            "Kozzy AVM Arkası otopark girişi.",
                                          ],
                                        ),
                                        _buildMahalleSection(
                                          "SUADİYE",
                                          [
                                            "Suadiye Mah. Kazım Özalp Sokak Karşısı Sahil.",
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        InkWell(
                                          onTap: () async {
                                            final url = Uri.parse(
                                                "https://www.google.com/maps/d/u/0/viewer?mid=181mmqgMadJTtgb4SsRSz07tUHTXU-Agy&ll=40.9588217%2C29.07243440000002&z=14");
                                            if (await canLaunchUrl(url)) {
                                              await launchUrl(url,
                                                  mode: LaunchMode
                                                      .externalApplication);
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        "Bağlantı açılamadı")),
                                              );
                                            }
                                          },
                                          child: Text(
                                            "Kaynak: https://www.google.com/maps/d/u/0/viewer?mid=181mmqgMadJTtgb4SsRSz07tUHTXU-Agy&ll=40.9588217%2C29.07243440000002&z=14",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic,
                                              color: const Color.fromARGB(
                                                  255, 71, 77, 116),
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text("Tamam"),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _fetchSuggestions() async {
    var response =
        await http.get(Uri.parse('http://192.168.206.1:5000/suggestions'));
    if (response.statusCode == 200) {
      setState(() {
        _suggestions = json.decode(response.body);
      });
    } else {
      print('❌ Suggestions API failed: ${response.statusCode}');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: "Nunito"),
      home: FadeTransition(
        opacity: _animation,
        child: Builder(
          builder: (context) => Scaffold(
            body: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/geridonusumsoyut.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'EkoDönüşüm',
                      style: TextStyle(
                          fontSize: 32,
                          color: const Color.fromARGB(255, 255, 255, 255)),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Dönüştür',
                      style: TextStyle(
                          fontSize: 20,
                          color: const Color.fromARGB(255, 255, 255, 255)),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: 300,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: _imageData == null
                            ? Text(
                                'Resim yükleyin',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.black),
                              )
                            : Image.memory(
                                _imageData!,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.camera_alt,
                              color: const Color.fromARGB(255, 238, 246, 246)),
                          onPressed: _pickImage,
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    ElevatedButton.icon(
                      icon: Icon(Icons.map),
                      label: Text("Haritada Göster"),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Bilgilendirme"),
                            content: Text(
                                "Geri dönüştüremiyor musunuz? Doğru yerdesiniz! İşte geri dönüşüm noktaları."),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _showMapPopup(context);
                                },
                                child: Text("Tamam"),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_imageData != null) {
                          _showPredictionPopup(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Önce bir resim yükleyin!')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                      child: Text(
                        'Dönüştür',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPredictionPopup(BuildContext context) async {
    String predictedCategory = _prediction ?? "Unknown";
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text("Tahmin yapılıyor..."),
          ],
        ),
      ),
    );

    await Future.delayed(Duration(seconds: 3));

    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tahmin Edilen Kategoriler '),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tahmin Edilen Kategoriler: $predictedCategory'),
            SizedBox(height: 10),
            Text('Bu kategori doğru mu?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TransformationPage(imageData: _imageData!),
                ),
              );
            },
            child: Text('Evet'),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategorySelectionPage(),
                ),
              );
            },
            child: Text('Hayır'),
          ),
        ],
      ),
    );
  }
}

class CategorySelectionPage extends StatelessWidget {
  Future<void> _fetchbyselection(BuildContext context, String category) async {
    var url = Uri.parse(
        'http://192.168.206.1:5000/suggestionbyselecting?category=$category');
    var response = await http.get(url);
    print("Request URL: $url");

    if (response.statusCode == 200) {
      var suggestions = json.decode(response.body);
      print(suggestions);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SuggestionsPage(suggestions: suggestions),
        ),
      );
    } else {
      print('❌ Suggestions API failed: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kategori Seç'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Cam'),
            onTap: () => _fetchbyselection(context, 'cam'),
          ),
          ListTile(
            title: Text('Plastik'),
            onTap: () => _fetchbyselection(context, 'plastik'),
          ),
          ListTile(
            title: Text('Metal'),
            onTap: () => _fetchbyselection(context, 'metal'),
          ),
          ListTile(
            title: Text('T-shirt'),
            onTap: () => _fetchbyselection(context, 'KisaKollu'),
          ),
          ListTile(
            title: Text('Gömlek'),
            onTap: () => _fetchbyselection(context, 'Gömlek'),
          ),
          ListTile(
            title: Text('Pantolon'),
            onTap: () => _fetchbyselection(context, 'Pantolon'),
          ),
          // ListTile(
          //   title: Text('Etek'),
          //   onTap: () => _fetchbyselection(context, 'Etek'),
          // ),
          // ListTile(
          //   title: Text('Dış Giyim'),
          //   onTap: () => _fetchbyselection(context, 'Dış Giyim'),
          // ),
          ListTile(
            title: Text('Uzun Kollu'),
            onTap: () => _fetchbyselection(context, 'Uzun Kollu'),
          ),
          // ListTile(
          //   title: Text('Üst'),
          //   onTap: () => _fetchbyselection(context, 'Üst'),
          // ),
        ],
      ),
    );
  }
}

class SuggestionsPage extends StatelessWidget {
  final List<dynamic> suggestions;

  SuggestionsPage({required this.suggestions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fikirler'),
      ),
      body: suggestions.isEmpty
          ? Center(child: Text('Herhangi bir öneri bulunamadı.'))
          : ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = suggestions[index];
                return Card(
                  elevation: 4,
                  child: ListTile(
                    leading: suggestion['resimUrl'] != null &&
                            suggestion['resimUrl'].isNotEmpty
                        ? (suggestion['resimUrl'].startsWith('assets/')
                            ? Image.asset(
                                suggestion['resimUrl'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                suggestion['resimUrl'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ))
                        : Image.asset(
                            'assets/default_image.png',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                    title: Text(suggestion['baslik']),
                    subtitle: Text(
                      'Zorluk: ${suggestion['zorlukDerecesi']} • Süre: ${suggestion['sure']}',
                      style: TextStyle(fontSize: 12),
                    ),
                    onTap: () => _showDetailsDialog(
                      context,
                      suggestion['baslik'],
                      suggestion['aciklama'],
                      suggestion['resimUrl'],
                      suggestion['adimlar'],
                      suggestion['malzemeler'],
                      suggestion['zorlukDerecesi'],
                      suggestion['sure'],
                      suggestion['kaynak'],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showDetailsDialog(
    BuildContext context,
    String baslik,
    String aciklama,
    String resimUrl,
    String adimlar,
    String malzemeler,
    String zorlukDerecesi,
    String sure,
    String kaynak,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(resimUrl, fit: BoxFit.cover),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              baslik,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 16),
                                SizedBox(width: 4),
                                Text(sure),
                                SizedBox(width: 16),
                                Icon(Icons.assignment, size: 16),
                                SizedBox(width: 4),
                                Text(zorlukDerecesi),
                              ],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Açıklama:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(aciklama),
                            SizedBox(height: 16),
                            Text(
                              'Kaynak:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                final Uri url = Uri.parse(kaynak);
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url,
                                      mode: LaunchMode.externalApplication);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('URL açılamadı!')),
                                  );
                                }
                              },
                              child: Text(
                                kaynak,
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Malzemeler:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(malzemeler),
                            SizedBox(height: 16),
                            Text(
                              'Yapılış Adımları:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(adimlar),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Kapat'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TransformationPage extends StatefulWidget {
  final Uint8List imageData;

  const TransformationPage({Key? key, required this.imageData})
      : super(key: key);

  @override
  _TransformationPageState createState() => _TransformationPageState();
}

class _TransformationPageState extends State<TransformationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<dynamic>> _suggestions;
  String selectedTab = 'Tümü';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tahminler.length, vsync: this);
    _suggestions = _fetchSuggestions(selectedTab);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {
        selectedTab = tahminler[_tabController.index];
        _suggestions = _fetchSuggestions(selectedTab);
      });
    });
  }

  Future<List<dynamic>> _fetchSuggestions(String category) async {
    String apiUrl;
    if (category == 'Tümü') {
      apiUrl = 'http://192.168.206.1:5000/suggestions';
    } else {
      apiUrl =
          'http://192.168.206.1:5000/suggestionbyselecting?category=$category';
    }
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('API hata kodu: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API çağrısı başarısız: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fikirler'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: tahminler.map((tahmin) => Tab(text: tahmin)).toList(),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        key: ValueKey(selectedTab),
        future: _suggestions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Herhangi bir öneri bulunamadı.'));
          } else {
            List<dynamic> suggestions = snapshot.data!;

            return ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = suggestions[index];
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: SizedBox(
                      width: 50,
                      height: 50,
                      child: suggestion['resimUrl'].startsWith('assets/')
                          ? Image.asset(suggestion['resimUrl'],
                              fit: BoxFit.cover)
                          : Image.network(suggestion['resimUrl'],
                              fit: BoxFit.cover),
                    ),
                    title: Text(suggestion['baslik']),
                    subtitle: Text(
                      'Zorluk: ${suggestion['zorlukDerecesi']}',
                      style: TextStyle(fontSize: 12),
                    ),
                    onTap: () => _showDetailsDialog(
                      context,
                      suggestion['baslik'],
                      suggestion['aciklama'],
                      suggestion['resimUrl'],
                      suggestion['adimlar'],
                      suggestion['malzemeler'],
                      suggestion['zorlukDerecesi'],
                      suggestion['sure'],
                      suggestion['kaynak'],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  void _showDetailsDialog(
    BuildContext context,
    String baslik,
    String aciklama,
    String resimUrl,
    String adimlar,
    String malzemeler,
    String zorlukDerecesi,
    String sure,
    String kaynak,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(resimUrl, fit: BoxFit.cover),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              baslik,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 16),
                                SizedBox(width: 4),
                                Text(sure),
                                SizedBox(width: 16),
                                Icon(Icons.assignment, size: 16),
                                SizedBox(width: 4),
                                Text(zorlukDerecesi),
                              ],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Açıklama:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(aciklama),
                            SizedBox(height: 16),
                            Text(
                              'Kaynak:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                final Uri url = Uri.parse(kaynak);
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url,
                                      mode: LaunchMode.externalApplication);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('URL açılamadı!')),
                                  );
                                }
                              },
                              child: Text(
                                kaynak,
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Malzemeler:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(malzemeler),
                            SizedBox(height: 16),
                            Text(
                              'Yapılış Adımları:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(adimlar),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Kapat'),
                  style: TextButton.styleFrom(
                    minimumSize: Size(double.infinity, 36),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
