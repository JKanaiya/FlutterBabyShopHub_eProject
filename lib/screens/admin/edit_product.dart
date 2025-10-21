import 'package:babyshophub/main.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

/// An administrative screen used for editing the details of an existing product.
///
/// It allows updating the product's image, name, price, and description.
class EditProduct extends StatefulWidget {
  // Initial product details passed to the widget.
  final double price;
  final int id;
  final String description;
  final String name;

  const EditProduct({
    super.key,
    required this.price,
    required this.description,
    required this.id,
    required this.name,
  });

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  // Holds the selected image file from the user's gallery before upload.
  File? _imageFile;
  // Controllers for the input fields, pre-populated with current values in the UI.
  final priceTextController = TextEditingController();
  final descriptionController = TextEditingController();
  final nameController = TextEditingController();

  /// Opens the gallery to allow the user to pick a new image file for the product.
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path); // Set the selected file for preview.
      });
    }
  }

  /// Handles the concurrent upload of the new image and/or updates the text fields to Supabase.
  Future<void> uploadData() async {
    // Check if any change has been made to prevent unnecessary database calls.
    if (_imageFile == null &&
        descriptionController.text == widget.description &&
        nameController.text == widget.name &&

        priceTextController.text == widget.price.toString()) {
      return;
    }

    final futures = <Future>[]; // List to hold all update operations.

    // ---  Image Update ---

    if (_imageFile != null) {
      futures.add(
        supabase
            .from('products')
        // This line needs correction in a production app to upload the file to storage first.
            .update({'image_url': _imageFile})
            .eq("id", widget.id),
      );
    }

    // ---  Description Update ---
    if (descriptionController.text.isNotEmpty &&
        descriptionController.text != widget.description) {
      futures.add(
        supabase
            .from('products')
            .update({'description': descriptionController.text})
            .eq("id", widget.id),
      );
    }

    // ---  Name Update ---
    if (nameController.text.isNotEmpty && nameController.text != widget.name) {
      futures.add(
        supabase
            .from('products')
            .update({'name': nameController.text})
            .eq("id", widget.id),
      );
    }

    // ---  Price Update ---
    if (priceTextController.text.isNotEmpty &&
        priceTextController.text != widget.price.toString()) {
      futures.add(
        supabase
            .from('products')
            .update({'price': priceTextController.text}) // Price should be parsed to a number type if necessary.
            .eq("id", widget.id),
      );
    }

    // Wait for all database operations to complete successfully.
    await Future.wait(futures).then(
          (value) => {
        if (mounted)
          {
            // Show success message and navigate back.
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Section updated successfully!")),
            ),
            Navigator.pop(context),
          },
      },
    );
  }

  @override
  void dispose() {
    // Dispose of controllers to prevent memory leaks.
    priceTextController.dispose();
    descriptionController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context), // Back button
          icon: Icon(
            Icons.west,
            color: Theme.of(context).colorScheme.primary,
            size: 25,
          ),
        ),
        title: Text(
          "Edit Product",
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
                "Update Product",
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
            // Name Text Field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: widget.name,
                  label: const Text("Name:"),
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
            // Price Text Field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: priceTextController,
                decoration: InputDecoration(
                  label: const Text("Price:"),
                  hintText: widget.price.toString(),
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
            // Description Text Field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  label: const Text("Description"),
                  hintText: widget.description,
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