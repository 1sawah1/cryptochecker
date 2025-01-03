import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Map<String, String> coin = <String, String>{
    'Bitcoin': 'bitcoin',
    'Ethereum': 'ethereum',
    'Litecoin': 'litecoin',
    'Xrp': 'ripple',
    'Solana': 'solana',
    'Dogecoin': 'dogecoin',
    'Trx': 'tron',
  };

  final Map<String, IconData> coinIcons = <String, IconData>{
    'Bitcoin': Icons.currency_bitcoin,
    'Ethereum': Icons.euro_symbol,
    'Litecoin': Icons.light_mode,
    'Xrp': Icons.water_drop,
    'Solana': Icons.sunny,
    'Dogecoin': Icons.pets,
    'Trx': Icons.trending_up,
  };

  final Map<String, Color> coinColors = {
    'Bitcoin': Colors.orange,
    'Ethereum': Colors.blue,
    'Litecoin': Colors.grey,
    'Xrp': Colors.cyan,
    'Solana': Colors.purple,
    'Dogecoin': Colors.brown,
    'Trx': Colors.green,
  };

  Map<String, double> prices = {};
  List<String> favoriteCoins = [];
  bool isLoading = true;
  String? errorMessage;
  bool isGuestMenuVisible = false;

  @override
  void initState() {
    super.initState();
    fetchPrices();
    fetchFavorites();
  }

  void toggleGuestMenu() {
    setState(() {
      isGuestMenuVisible = !isGuestMenuVisible;
    });
  }

  Future<void> fetchPrices() async {
    final String api = 'https://louay.ct.ws/index.php';
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final response = await http.get(Uri.parse(api));
      if (response.statusCode == 200) {
        setState(() {
          prices = Map<String, double>.from(
            (json.decode(response.body) as List<dynamic>).fold({}, (map, item) {
              map[item['symbol']] = double.parse(item['price']);
              return map;
            }),
          );
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch prices. Please try again.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
        isLoading = false;
      });
    }
  }

  Future<void> fetchFavorites() async {
    final response = await http.get(Uri.parse('https://louay.ct.ws/index.php?action=get_favorites'));
    if (response.statusCode == 200) {
      setState(() {
        favoriteCoins = List<String>.from(json.decode(response.body));
      });
    }
  }

  Future<void> toggleFavorite(String coinId) async {
    if (favoriteCoins.contains(coinId)) {
      await http.post(
        Uri.parse('https://louay.ct.ws/index.php?action=remove_favorite'),
        body: {'coin_id': coinId},
      );
      setState(() {
        favoriteCoins.remove(coinId);
      });
    } else {
      await http.post(
        Uri.parse('https://louay.ct.ws/index.php?action=add_favorite'),
        body: {'coin_id': coinId},
      );
      setState(() {
        favoriteCoins.add(coinId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Sawah',
            style: GoogleFonts.acme(color: Colors.orange,fontSize: 40),
          ),
          backgroundColor: Colors.black,
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                icon: const Icon(Icons.person),
                iconSize: 40.0,
                color: Colors.white,
                onPressed: () {
                  toggleGuestMenu();
                },
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            if (isGuestMenuVisible)
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.black.withOpacity(0.8),
                width: double.infinity,
                child: Row(
                  children: [
                    const Icon(
                      Icons.account_circle,
                      color: Colors.orange,
                      size: 30.0,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Welcome Guest !',
                      style: GoogleFonts.acme(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage != null
                    ? Center(child: Text(errorMessage!))
                    : ListView.builder(
                  itemCount: coin.length,
                  itemBuilder: (context, index) {
                    String coinName = coin.keys.elementAt(index);
                    String coinId = coin.values.elementAt(index);
                    IconData coinIcon = coinIcons[coinName]!;
                    Color coinColor = coinColors[coinName]!;
                    bool isFavorite = favoriteCoins.contains(coinId);

                    return ListTile(
                      leading: Icon(coinIcon, color: coinColor),
                      title: Text(
                        coinName,
                        style: GoogleFonts.acme(
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.star : Icons.star_border,
                          color: Colors.orange,
                        ),
                        onPressed: () => toggleFavorite(coinId),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}