import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:wallpaper_app/home.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class Fullscreen extends StatefulWidget {
  const Fullscreen({super.key, required this.imageUrl});
  final String imageUrl;

  @override
  State<Fullscreen> createState() => _FullscreenState();
}

class _FullscreenState extends State<Fullscreen> {
  Uint8List? image;
  Uint8List? _croppedData;

  final _controller = CropController();
  @override
  void initState() {
    super.initState();
    if (mounted) {
      networkImageToUint8List(widget.imageUrl);
    }
  }

  Future<void> setWallpaper() async {
    int location = WallpaperManagerFlutter.homeScreen;
    var file = await DefaultCacheManager().getSingleFile(widget.imageUrl);
    WallpaperManagerFlutter().setWallpaper(file, location);
  }

  Future<void> networkImageToUint8List(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));

    if (response.statusCode == 200) {
      setState(() {
        image = response.bodyBytes;
      });
    } else {
      throw Exception('Failed to load image');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (image == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Crop(
        baseColor: Colors.transparent,
        initialRectBuilder: InitialRectBuilder.withBuilder((
          viewportRect,
          imageRect,
        ) {
          return Rect.fromCenter(
            center: viewportRect.center,
            width: viewportRect.width * 0.8,
            height: viewportRect.height * 0.8,
          );
        }),
        interactive: true,
        image: image!,
        controller: _controller,
        aspectRatio:
            MediaQuery.of(context).size.width /
            MediaQuery.of(context).size.height,
        onCropped: (result) async {
          switch (result) {
            case CropSuccess(:final croppedImage):
              final file = await DefaultCacheManager().putFile(
                'cropped_wallpaper',
                croppedImage,
                fileExtension: 'jpg',
              );

              await WallpaperManagerFlutter().setWallpaper(
                file,
                WallpaperManagerFlutter.homeScreen,
              );

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Home()),
              );

            case CropFailure(:final cause):
              return;
          }
        },
      ),

      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.all(15),
        child: Container(
          child: ElevatedButton(
            onPressed: () {
              _controller.crop();
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.blue),
              foregroundColor: WidgetStateProperty.all(Colors.white),
            ),
            child: Text('Set Wallpaper'),
          ),
        ),
      ),
    );
  }
}
