
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:property_list/model/property.dart';
import '../services/notification_service.dart';

class PropertyCard extends StatefulWidget {
  final Property property;
  const PropertyCard({super.key, required this.property});

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  File? _localImage;
  Uint8List? _webImageBytes;
  late DateTime _startTime;

  Future<void> _pickImage() async {
    print("[Analytics] Image picker tapped for property ID: ${widget.property.id}");
    final picker = ImagePicker();

    if (kIsWeb) {
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
          _localImage = null; // clear local image if any
        });

        await NotificationService().showSimple('Upload complete', 'Image uploaded successfully');

      }
    } else {
      // On mobile: pick image from camera
      final picked = await picker.pickImage(source: ImageSource.camera);
      if (picked != null) {
        setState(() {
          _localImage = File(picked.path);
          _webImageBytes = null;
        });
        await NotificationService().showSimple('Upload complete', 'Image uploaded successfully');
      }
    }
  }

  void _logView() {
    print("[Analytics] Viewed property ID: ${widget.property.id}");
  }

  void _logTimeSpent() {
    final duration = DateTime.now().difference(_startTime);
    print("[Analytics] Time spent on property ID ${widget.property.id}: ${duration.inSeconds} seconds");
  }

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _logView();
  }

  @override
  void dispose() {
    _logTimeSpent();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.compactSimpleCurrency(locale: 'en_US');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 120,
              height: 120,
              color: Colors.blue.shade100,
              child: _localImage != null
                  ? Image.file(_localImage!, fit: BoxFit.cover)
                  : _webImageBytes != null
                  ? Image.memory(_webImageBytes!, fit: BoxFit.cover)
                  : const Icon(Icons.camera_alt, color: Colors.blue, size: 50),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '${widget.property.bedrooms} BR · ${widget.property.bathrooms} BA · ${widget.property.areaSqFt.toStringAsFixed(0)} sqft',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(widget.property.location, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                const SizedBox(height: 4),
                Text('Status: ${widget.property.status}',
                    style: TextStyle(
                        fontSize: 14,
                        color: widget.property.status.toLowerCase() == 'available' ? Colors.green : Colors.red)),
                const SizedBox(height: 8),
                Text(fmt.format(widget.property.price),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
