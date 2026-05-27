import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const EducationalArchiveApp());

class EducationalArchiveApp extends StatelessWidget {
  const EducationalArchiveApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '📚 Educational Archive',
      theme: ThemeData(primarySwatch: Colors.blue, brightness: Brightness.light),
      home: const ArchiveScreen(),
    );
  }
}

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});
  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  final _urlController = TextEditingController();
  String _selectedType = 'video';
  String _status = 'Ready to queue';
  bool _isLoading = false;
  String? _serverIp = '192.168.1.100'; // Change to your backend IP

  Future<void> _submitDownload() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() => _status = '⚠️ Enter a valid URL'); return;
    }
    setState(() { _isLoading = true; _status = '📤 Submitting...'; });
    try {
      final res = await http.post(
        Uri.parse('http://$_serverIp:8000/download'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'url': url, 'media_type': _selectedType}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() => _status = '✅ Queued! ID: ${data['request_id']}');
      } else setState(() => _status = '❌ Server error');
    } catch (e) {
      setState(() => _status = '❌ Network: $e');
    } finally { setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📚 Educational Archive')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(controller: _urlController, decoration: const InputDecoration(labelText: 'URL', border: OutlineInputBorder(), prefixIcon: Icon(Icons.link)), keyboardType: TextInputType.url),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(value: _selectedType, decoration: const InputDecoration(labelText: 'Type'),
              items: const [DropdownMenuItem(value: 'video', child: Text('🎥 Video')), DropdownMenuItem(value: 'audio', child: Text('🎵 Audio'))],
              onChanged: (v) => setState(() => _selectedType = v!),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(onPressed: _isLoading ? null : _submitDownload,
              icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.cloud_download),
              label: Text(_isLoading ? 'Processing...' : 'Queue Download'),
            ),
            const SizedBox(height: 20),
            Card(elevation: 2, child: Padding(padding: const EdgeInsets.all(12), child: Text(_status, style: const TextStyle(fontSize: 15)))),
            const Spacer(),
            const Text('⚖️ Educational Use Only. Respects CC/Public Domain licenses & platform policies.', style: TextStyle(color: Colors.grey, fontSize: 11), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
