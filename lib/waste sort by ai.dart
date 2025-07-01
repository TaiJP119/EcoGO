import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

class WasteSortScreen extends StatefulWidget {
  const WasteSortScreen({super.key});

  @override
  State<WasteSortScreen> createState() => _WasteSortScreenState();
}

class _WasteSortScreenState extends State<WasteSortScreen> {
  int maxPeople = 1; // 1 people
  int maxTimeCooking = 15; // 10 minutes
  final textController = TextEditingController();
  XFile? image;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Waste Sorting by AI',
            style: GoogleFonts.notoSans(color: Colors.white, fontSize: 18.0)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 56, 228, 128),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  imagePickerMethod();
                },
                child: SizedBox(
                  height: 300,
                  width: 300,
                  child: image != null
                      ? Image.file(File(image!.path))
                      : Image.asset('assets/images/pick_image.png'),
                ),
              ),
              const SizedBox(height: 100),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  try {
                    var recipe = await generateWasteSortbyAI(
                        maxPeople, maxTimeCooking, textController.text, image);
                    openButtomBar(recipe);
                  } catch (e) {
                    log(e.toString());

                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Something went wrong')));
                  }

                  setState(() {
                    isLoading = false;
                  });
                },
                style: ElevatedButton.styleFrom(fixedSize: const Size(400, 40)),
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Generate by AI'),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Show loading
  void showLoading() {
    setState(() {
      isLoading = true;
    });
  }

  // Hide loading
  void hideLoading() {
    setState(() {
      isLoading = false;
    });
  }

  // Method to pick image from gallery
  Future<void> imagePickerMethod() async {
    final picker = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picker != null) {
      setState(() {
        image = picker;
      });
    }
  }

  // Method to open bottom bar
  void openButtomBar(var recipe) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(recipe.toString()),
            ),
          );
        });
  }

  // Method to generate waste sort by Gemini
  Future<List<String>> generateWasteSortbyAI(int people, int maxTimeCooking,
      String? intoleranceOrLimits, XFile? picture) async {
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: 'api-KEY',
    );

    final prompt = _generatePrompt(people, maxTimeCooking, intoleranceOrLimits);
    final image = await picture!.readAsBytes();
    final mimetype = picture.mimeType ?? 'image/jpeg';

    final response = await model.generateContent([
      Content.multi([TextPart(prompt), DataPart(mimetype, image)])
    ]);

    // return response.skipWhile((response) => response.text != null).map((event) => event.text!);
    log(response.text!);
    return [response.text!];
  }

  // Method to generate prompt
  String _generatePrompt(
      int people, int maxTimeCooking, String? intoleranceOrLimits) {
    String prompt =
        '''You are a very experienced waste identify and sorting planner. I want to identify and sort the waste product in the picture.  Sort into wet waste and dry waste. And from the dry waste, sort into recyclable or non-recyclable items. And from the recyclable items, sort into paper, glass, plastic ,and metal.
  I need the identifying and sorting step by step to easily understand it and format me using only markdown.  the output exaple as below:
Here is the breakdown of the waste sorting for the given image.

Here is the breakdown of the waste products:

Wet Waste:

None

Dry Waste

Recyclable

Paper: Miracle-Gro box

Glass: Old English bottle

Plastic:

Gay Lea Whipped Cream Container

Home Paint Thinner Container

Muskol Insect Repellent Container

Easy-Off Oven Cleaner Bottle

Coleman Camp Fuel Container

Propane Tank

The Compact Fluorescent Light Bulb

Metal:

The Paint Can

Supreme Motor Oil Container

Bear Chase Tactical Aerosol Container

Non-Recyclable:

Nail Polish Bottle

Note: It is always best to check with your local recycling guidelines, as they may vary depending on your location.
  ''';

    if (intoleranceOrLimits != null) {
      prompt +=
          'I have the following intolerances or limits: $intoleranceOrLimits';
    }

    return prompt;
  }
}
