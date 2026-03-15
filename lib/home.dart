import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:wallpaper_app/fullscreen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List images = [];
  int page = 1;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    final res = await http.get(
      Uri.parse('https://api.pexels.com/v1/curated?per_page=60'),
      headers: {
        'Authorization':
            'ZiLGWI8VJyUMZ8jpExcSFm0YxJapnR3Of2XNrqgnk8cGcHDc1yTqKcbW',
      },
    );
    var jsonResponse = convert.jsonDecode(res.body);
    setState(() {
      images = jsonResponse['photos'];
    });
  }

  void laodMore() async {
    setState(() {
      page += 1;
    });

    final res = await http.get(
      Uri.parse('https://api.pexels.com/v1/curated?per_page=60&page=$page'),
      headers: {
        'Authorization':
            'ZiLGWI8VJyUMZ8jpExcSFm0YxJapnR3Of2XNrqgnk8cGcHDc1yTqKcbW',
      },
    );
    var jsonResponse = convert.jsonDecode(res.body);
    setState(() {
      images.addAll(jsonResponse['photos']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          'Wallpapers',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                itemCount: images.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                  childAspectRatio: 2 / 3,
                ),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return Fullscreen(
                              imageUrl: images[index]['src']['large2x'],
                            );
                          },
                        ),
                      );
                    },
                    child: Container(
                      color: const Color.fromARGB(253, 191, 207, 213),
                      child: Image.network(
                        images[index]['src']['tiny'],
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(12),
              height: 60,
              child: SizedBox(
                height: 20,
                child: ElevatedButton(
                  onPressed: laodMore,
                  child: Text('Laod More'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
