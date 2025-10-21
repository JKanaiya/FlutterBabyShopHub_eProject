import 'package:babyshophub/main.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Package for picking images from the device gallery.
import 'dart:io'; // Required for the File class to handle local images.

/// A screen for administrators to edit a specific front page section's content.
///
/// It allows updating both the image and the associated text for a splash screen section.
class EditSection extends StatefulWidget {
  // The unique ID of the front page section being edited (1, 2, or 3).
  final int section;
  // The current text associated with this section.
  final String text;
  const EditSection({super.key, required this.section, required this.text});

  @override
  State<EditSection> createState() => _EditSectionState();
}

class _EditSectionState extends State<EditSection> {
  // Holds the selected image file from the user's gallery before upload.
  File? _imageFile;
  // Controller for the text input field.
  final textController = TextEditingController();

  /// Opens the gallery to allow the user to pick an image file.
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();

    // Request to pick an image from the gallery.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Update state to show the selected image file preview.
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  /// Handles the process of uploading the new image and/or updating the text to Supabase.
  Future<void> uploadData() async {
    // If neither image was selected nor text was changed, exit early.
    if (_imageFile == null && textController.text == widget.text) return;

    // ---  Image Upload/Update ---
    if (_imageFile != null) {
      // Upload the new image to the Supabase Storage bucket, replacing the old one.
      await supabase.storage
          .from('product-images')
          .update(
        "Splash Screen/splashscreen${widget.section}", // Dynamic file path
        _imageFile!,
      )
          .then(
            (value) => {
          if (mounted)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Image updated successfully!")),
            ),
        },
      );
    }

    // --- Text Update ---
    // Only update the database if the text field contains a new value.
    if (textController.text != widget.text && textController.text.isNotEmpty) {
      await supabase
          .from('app_data_upserts')
          .update({'sectionText': textController.text})
          .eq("section", widget.section); // Target the correct section row.
    }

    // Navigate back after successful update (ensuring widget is still mounted).
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context), // Back button functionality
          icon: Icon(
            Icons.west,
            color: Theme.of(context).colorScheme.primary,
            size: 25,
          ),
        ),
        title: Text(
          "Edit Section",
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Selection Header and Button
            ListTile(
              title: Text(
                "Update Section ${widget.section}",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              trailing: ElevatedButton(
                onPressed: pickImage, // Triggers image selection
                child: Text(
                  "Select Image",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'ubuntu',
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ),
            // Image Preview Area
            Container(
              height: screenHeight * 0.4,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  width: 2.0,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              child: _imageFile != null
                  ? Image.file(_imageFile!, fit: BoxFit.fill) // Show selected image
                  : const Center(child: Text("No image selected ...")), // Placeholder
            ),
            // Text Editing Field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: textController,
                decoration: InputDecoration(
                  hintText: widget.text, // Show current text as a hint
                  hintStyle: TextStyle(
                    fontFamily: 'ubuntu',
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                    fontSize: 17,
                  ),
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            // Update Data Button
            Center(
              child: ElevatedButton(
                onPressed: uploadData, // Triggers database update/upload
                child: const Text(
                  "Update Data",
                  style: TextStyle(fontFamily: "ubuntu", fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}