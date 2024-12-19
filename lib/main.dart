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
  bool isLoading = true;
  String? errorMessage;


  @override
  void initState() {
    super.initState();
    fetchPrices();
  }

  Future<void> fetchPrices() async {
    final String api =
        'https://api.coingecko.com/api/v3/simple/price?ids=${coin.values.join(',')}&vs_currencies=usd';
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final response = await http.get(Uri.parse(api));
      if (response.statusCode == 200) {
        setState(() {
          prices = Map<String, double>.from(
            (json.decode(response.body) as Map<String, dynamic>).map(
                  (key, value) => MapEntry(key, value['usd'].toDouble()),
            ),
          );
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Sawah',
            style: GoogleFonts.acme(),
          ),
          titleTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 34,
            fontStyle: FontStyle.normal,
            color: Colors.orange,
            backgroundColor: Colors.black,
          ),
          backgroundColor: Colors.black,
          centerTitle: true,
        ),
        body:
        Padding(
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
              Color coinColor= coinColors[coinName]!;
              return ListTile(
               /* leading: Icon(coinIcons[coinName], color: Colors.orange),*/
                leading: Icon(coinIcon,color: coinColor),
                title: Text(
                  coinName,
                  style: GoogleFonts.acme(
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                onTap: () {
                  String price = prices[coinId]?.toStringAsFixed(2) ?? 'Loading...';
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Price checker', style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
                      content: Text('The price of $coinName is $price USD', style: GoogleFonts.inter(),),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('OKAY'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
