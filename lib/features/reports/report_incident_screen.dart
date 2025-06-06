import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:report_app/providers/report_provider.dart';

class ReportIncidentScreen extends StatefulWidget {
  final void Function(int)? onReportSubmitted;

  const ReportIncidentScreen({super.key, this.onReportSubmitted});

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  final List<DropDownValueModel> _categories = const [
    DropDownValueModel(name: 'Potholes', value: 'Potholes'),
    DropDownValueModel(name: 'Street Lighting', value: 'Street Lighting'),
    DropDownValueModel(name: 'Garbage', value: 'Garbage'),
    DropDownValueModel(name: 'Public Safety', value: 'Public Safety'),
    DropDownValueModel(name: 'Noise', value: 'Noise'),
    DropDownValueModel(name: 'Vandalism', value: 'Vandalism'),
    DropDownValueModel(name: 'Loose Animals', value: 'Loose Animals'),
    DropDownValueModel(name: 'Road Obstruction', value: 'Road Obstruction'),
    DropDownValueModel(name: 'Other', value: 'Other'),
  ];

  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedCategory;

  void _nextPage() async {
    final provider = Provider.of<ReportProvider>(context, listen: false);

    if (_currentPage == 0) {
      if (_titleController.text.trim().isEmpty || _selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please enter a title and select a category."),
          ),
        );
        return;
      }
      provider.setTitle(_titleController.text.trim());
      provider.setCategory(_selectedCategory);
    } else if (_currentPage == 1) {
      if (_addressController.text.trim().isEmpty ||
          provider.selectedLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Please enter an address and select a location on the map.",
            ),
          ),
        );
        return;
      }
    }

    if (_currentPage < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage++);
    } else {
      setState(() => _isLoading = true);
      await provider.submitReport(context, () async {
        setState(() => _isLoading = false);
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("Report Submitted"),
                content: const Text(
                  "Your report has been successfully registered.",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("OK"),
                  ),
                ],
              ),
        );
        provider.reset();
        _titleController.clear();
        _addressController.clear();
        setState(() {
          _currentPage = 0;
          _controller.jumpToPage(0);
          _selectedCategory = null;
        });
        if (widget.onReportSubmitted != null) {
          widget.onReportSubmitted!(3);
        }
      });
    }
  }

  InputDecoration _inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontWeight: FontWeight.w500),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReportProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Image.asset(
                      'assets/new_report_header.png',
                      height: 60,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _step1(provider),
                    _step2(provider),
                    _step3(provider),
                  ],
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _nextPage,
          child: Text(_currentPage == 2 ? "Submit Report" : "Next"),
        ),
      ),
    );
  }

  Widget _step1(ReportProvider provider) {
    return _cardWrapper(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Report Details",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _titleController,
            decoration: _inputStyle("Title"),
          ),
          const SizedBox(height: 16),
          DropDownTextField(
            clearOption: true,
            textFieldDecoration: _inputStyle("Category"),
            dropDownList: _categories,
            onChanged: (val) {
              if (val is DropDownValueModel) {
                _selectedCategory = val.value;
              }
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: _inputStyle("Description"),
            maxLines: 3,
            onChanged: provider.setDescription,
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text("Submit anonymously"),
            value: provider.isAnonymous,
            onChanged: (value) => provider.setAnonymous(value ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _step2(ReportProvider provider) {
    return _cardWrapper(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //_backButton(),
          const Text(
            "Location",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _addressController,
            decoration: _inputStyle("Address"),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 250,
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(20.52353, -100.8157),
                zoom: 14,
              ),
              onTap: provider.setLocation,
              markers:
                  provider.selectedLocation != null
                      ? {
                        Marker(
                          markerId: const MarkerId("selected"),
                          position: provider.selectedLocation!,
                        ),
                      }
                      : {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _step3(ReportProvider provider) {
    return _cardWrapper(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //_backButton(),
          const Text(
            "Photo",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (provider.selectedImage != null)
            Image.file(provider.selectedImage!, height: 150),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.photo_library),
                label: const Text("Gallery"),
                onPressed: () async {
                  final picked = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (picked != null) provider.setImage(File(picked.path));
                },
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text("Camera"),
                onPressed: () async {
                  final picked = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                  );
                  if (picked != null) provider.setImage(File(picked.path));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _backButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () {
          _controller.previousPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        icon: const Icon(Icons.arrow_back),
        label: const Text("Back"),
      ),
    );
  }

  Widget _cardWrapper(Widget child) {
    return Center(
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(child: child),
        ),
      ),
    );
  }
}
