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
  final Map<String, String> coin = {
    'Bitcoin': 'bitcoin',
    'Ethereum': 'ethereum',
    'Litecoin': 'litecoin',
    'Xrp': 'ripple',
    'Solana': 'solana',
    'Dogecoin': 'dogecoin',
    'Trx': 'tron',
  };

  final Map<String, IconData> coinIcons = {
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
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchPrices();
  }

  Future<void> fetchPrices() async {
    final String api =
        'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum,litecoin,ripple,solana,dogecoin,tron&vs_currencies=usd';

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse(api));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          prices = {
            'Bitcoin': data['bitcoin']['usd'].toDouble(),
            'Ethereum': data['ethereum']['usd'].toDouble(),
            'Litecoin': data['litecoin']['usd'].toDouble(),
            'Xrp': data['ripple']['usd'].toDouble(),
            'Solana': data['solana']['usd'].toDouble(),
            'Dogecoin': data['dogecoin']['usd'].toDouble(),
            'Trx': data['tron']['usd'].toDouble(),
          };
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Sawah',
            style: GoogleFonts.acme(color: Colors.orange, fontSize: 40),
          ),
          backgroundColor: Colors.white,
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (errorMessage != null)
                Center(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 18),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: coin.length,
                    itemBuilder: (context, index) {
                      String coinName = coin.keys.elementAt(index);
                      IconData coinIcon = coinIcons[coinName]!;
                      Color coinColor = coinColors[coinName]!;
                      String priceText = "Loading...";

                      if (prices.containsKey(coinName)) {
                        priceText = '\$${prices[coinName]!.toStringAsFixed(2)}';
                      }

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
                        subtitle: Text(
                          priceText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}
