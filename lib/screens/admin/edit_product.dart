import 'package:babyshophub/main.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProduct extends StatefulWidget {
  final int section;
  final String text;
  const EditProduct({super.key, required this.section, required this.text});

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
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
                  const SnackBar(
                    content: Text("Section updated successfully!"),
                  ),
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
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
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
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(
                "Update Product ${widget.section}",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.secondaryContainer,
                  padding: EdgeInsets.all(20),
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: pickImage,
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
            Container(
              height: screenHeight * 0.4,
              decoration: BoxDecoration(
                color: Colors.white,
                // borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  width: 2.0,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              child: _imageFile != null
                  ? Image.file(_imageFile!, fit: BoxFit.fill)
                  : const Center(child: Text("No image selected ...")),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: widget.text,
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
                controller: textController,
              ),
            ),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: EdgeInsets.all(20),
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: uploadData,
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
