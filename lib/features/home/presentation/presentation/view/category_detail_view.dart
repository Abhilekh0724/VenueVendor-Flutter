import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../../../../../core/networking/local/api_service.dart';
import '../../data/model/venue_card.dart';

class CategoryDetailView extends StatefulWidget {
  final String categoryId;

  const CategoryDetailView({Key? key, required this.categoryId}) : super(key: key);

  @override
  _CategoryDetailViewState createState() => _CategoryDetailViewState();
}

class _CategoryDetailViewState extends State<CategoryDetailView> {
  VenueCard? venueCard;
  bool isLoading = true;
  bool hasError = false;
  DateTime? _selectedDate; // Nullable date for booking

  @override
  void initState() {
    super.initState();
    _fetchCategoryDetails();
  }

  Future<void> _fetchCategoryDetails() async {
    try {
      final fetchedCategory = await ApiService.getCategoryById(widget.categoryId);
      setState(() {
        venueCard = fetchedCategory;
        isLoading = false;
      });
    } catch (e) {
      print('Fetch Exception: $e');
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _bookCategory() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a booking date')),
      );
      return;
    }

    final userId = '66b4690da3c2323e47087524'; // Fetch the actual user ID from a secure source
    try {
      await ApiService.bookCategory(widget.categoryId, userId, _selectedDate!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking successful!')),
      );
    } catch (e) {
      print('Booking Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to book category')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/Venue.png', // Path to the logo image
              height: 40.0, // Adjust height if necessary
            ),
            const SizedBox(width: 8.0),
            const Text('Category Details'),
          ],
        ),
        backgroundColor: Colors.red[50],
        elevation: 0, // Optional: Remove shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.red[50],
      body: isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16.0),
            Text('Loading category details...'),
          ],
        ),
      )
          : hasError || venueCard == null
          ? const Center(child: Text('Error loading category details'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.network(
                'http://192.168.1.70:5500${venueCard!.photo ?? ''}',
                height: 200.0,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) {
                    return child;
                  } else {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16.0),
                          const Text('Loading image...'),
                        ],
                      ),
                    );
                  }
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.error, color: Colors.red),
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              venueCard!.name ?? 'No Name',
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 8.0),
            Text(
              venueCard!.info ?? 'No Info',
              style: const TextStyle(fontSize: 18.0),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            const SizedBox(height: 8.0),
            Text(
              '\$${venueCard!.price?.toString() ?? "N/A"}',
              style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate != null
                        ? 'Selected Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}'
                        : 'No Date Selected',
                    style: const TextStyle(fontSize: 18.0),
                  ),
                ),
                ElevatedButton(
                  onPressed: _selectDate,
                  child: const Text('Select Date'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _bookCategory,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey, // Button color
              ),
              child: const Text('Book Now'),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
