import 'package:babyshophub/main.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditSection extends StatefulWidget {
  final int section;
  final String text;
  const EditSection({super.key, required this.section, required this.text});

  @override
  State<EditSection> createState() => _EditSectionState();
}

class _EditSectionState extends State<EditSection> {
  File? _imageFile;
  final textController = TextEditingController();

  Future pickImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future uploadData() async {
    if (_imageFile == null && textController.text == widget.text) return;

    if (_imageFile != null) {
      await supabase.storage
          .from('product-images')
          .update("Splash Screen/splashscreen${widget.section}", _imageFile!)
          .then(
            (value) => {
              if (mounted)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Image updated successfully!")),
                ),
            },
          );
    }

    if (textController.text != widget.text) {
      await supabase
          .from('app_data_upserts')
          .update({'sectionText': textController.text})
          .eq("section", widget.section);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Section")),
      body: Column(
        children: [
          Text("Update Section ${widget.section} image"),
          _imageFile != null
              ? Image.file(_imageFile!)
              : const Text("No image selected ..."),
          ElevatedButton(onPressed: pickImage, child: const Text("Pick Image")),
          Text("Update Section ${widget.section} text"),
          TextField(
            decoration: InputDecoration(hintText: widget.text),
            controller: textController,
          ),
          ElevatedButton(
            onPressed: uploadData,
            child: const Text("Update Date"),
          ),
        ],
      ),
    );
  }
}
