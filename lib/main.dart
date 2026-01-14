// ignore_for_file: use_build_context_synchronously

import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:html' as html; // Web only

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SvgEditorScreen(),
    );
  }
}

class SvgEditorScreen extends StatefulWidget {
  const SvgEditorScreen({super.key});

  @override
  State<SvgEditorScreen> createState() => _SvgEditorScreenState();
}

class _SvgEditorScreenState extends State<SvgEditorScreen> {
  final TextEditingController _controller = TextEditingController();
  String? svgCode;

  @override
  void initState() {
    super.initState();
    svgCode = '''
<svg width="200" height="100" viewBox="0 0 200 100" xmlns="http://www.w3.org/2000/svg">
  <text x="10" y="70" font-family="Arial" font-size="60" fill="#000">I</text>
  <path d="M100 50 
           C100 20, 140 20, 140 50
           C140 80, 100 95, 100 70
           C100 95, 60 80, 60 50
           C60 20, 100 20, 100 50 Z"
        fill="red" />
  <text x="150" y="70" font-family="Arial" font-size="60" fill="#000">U</text>
</svg>
''';
    _controller.text = svgCode!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SVG Preview & Download"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextField(
              controller: _controller,
              hintText: "Paste your SVG code here",
              onChanged: (value) {
                setState(() {
                  svgCode = value;
                });
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: svgCode != null && svgCode!.isNotEmpty
                    ? SvgPicture.string(
                        svgCode!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.contain,
                        placeholderBuilder: (context) =>
                            const Center(child: CircularProgressIndicator()),
                      )
                    : const Center(child: Text("SVG Preview")),
              ),
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: "Download SVG",
              onTap: () {
                if (svgCode != null && svgCode!.isNotEmpty) {
                  downloadSvg(svgCode!, "i_love_u.svg");
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> downloadSvg(String svg, String fileName) async {
    try {
      if (kIsWeb) {
        // Web download
        final bytes = html.Blob([svg], 'image/svg+xml');
        final url = html.Url.createObjectUrlFromBlob(bytes);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        // Mobile download (Android/iOS)
        final directory = await getApplicationDocumentsDirectory();
        final file = File(
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}_$fileName',
        );
        await file.writeAsString(svg);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('SVG saved at: ${file.path}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving SVG: $e')));
    }
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 6,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const CustomButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.blue.shade600,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade200.withOpacity(0.5),
              offset: const Offset(0, 4),
              blurRadius: 6,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
