import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gemini_langchain/gemini_langchain.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  GeminiClient.initialize(apiKey: 'AIzaSyCLZzYZJZ067E2tDMJSNn5BCF6rVgJyqS0');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gemini + LangChain Demo',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade900,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(color: Colors.grey.shade500),
          labelStyle: const TextStyle(color: Colors.white70),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: const ProductsPage(),
    );
  }
}

class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final double rating;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.rating,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    price: (json['price'] as num).toDouble(),
    rating: (json['rating'] as num).toDouble(),
  );
}

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Product> products = [];
  String? errorMessage;
  bool isLoading = false;

  final TextEditingController _questionController = TextEditingController();

  String aiResponse = '';
  bool isAIloading = false;

  final LangChain _langChain = LangChain(
    template: '''
You are a helpful shopping assistant.

Here are the products:
{product_list}

Answer the following customer question:
{question}
''',
  );

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final response = await http.get(Uri.parse('https://dummyjson.com/products'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List items = data['products'];
        setState(() {
          products = items.map((json) => Product.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> askAI() async {
    if (products.isEmpty || _questionController.text.trim().isEmpty) return;

    final productListStr = products
        .map(
          (p) =>
      '${p.title} (Price: \$${p.price.toStringAsFixed(2)}, Rating: ${p.rating.toStringAsFixed(1)})',
    )
        .join('\n');

    final variables = {
      'product_list': productListStr,
      'question': _questionController.text.trim(),
    };

    setState(() {
      aiResponse = '';
      isAIloading = true;
    });

    try {
      await for (final chunk in _langChain.run(variables)) {
        setState(() {
          aiResponse = chunk;
        });
      }
    } catch (e) {
      setState(() {
        aiResponse = 'Error: $e';
      });
    } finally {
      setState(() {
        isAIloading = false;
      });
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Widget _buildProductItem(Product p) {
    return Card(
      color: Colors.grey.shade900,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(
          p.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            p.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade400),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('\$${p.price.toStringAsFixed(2)}',
                style: const TextStyle(
                    color: Colors.greenAccent, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  p.rating.toStringAsFixed(1),
                  style: const TextStyle(color: Colors.amber),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gemini + LangChain Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? Center(
          child: Text(
            'Error: $errorMessage',
            style: const TextStyle(color: Colors.redAccent),
          ),
        )
            : Column(
          children: [
            Expanded(
              flex: 5,
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return _buildProductItem(products[index]);
                },
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _questionController,
              decoration: const InputDecoration(
                labelText: 'Ask AI about these products',
                hintText: 'Type your question here...',
              ),
              minLines: 1,
              maxLines: 3,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: isAIloading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.question_answer),
              label: Text(isAIloading ? 'Loading...' : 'Ask AI'),
              onPressed: isAIloading ? null : askAI,
            ),
            const SizedBox(height: 16),
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    aiResponse,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
