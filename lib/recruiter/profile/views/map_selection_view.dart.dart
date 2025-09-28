import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapSelectionView extends StatefulWidget {
  @override
  _MapSelectionViewState createState() => _MapSelectionViewState();
}

class _MapSelectionViewState extends State<MapSelectionView> {
  final TextEditingController searchController = TextEditingController();
  GoogleMapController? mapController;
  LatLng currentLocation = const LatLng(-7.978469, 112.561741); // Default lokasi
  LatLng? selectedLocation;
  String? selectedAddress;
  List<Prediction> suggestions = [];
  bool isLoading = false;

  final GoogleMapsPlaces places = GoogleMapsPlaces(
    apiKey: dotenv.env['GOOGLE_MAPS_PLACES_API_KEY'] ?? '',
  );

  @override
  void initState() {
    super.initState();
  }
  Future<String> _getAddressFromLatLng(double lat, double lng, {String? placeId}) async {
    try {
      // Jika ada placeId (dari suggestion), gunakan Places API untuk mendapatkan detail alamat
      if (placeId != null) {
        final details = await places.getDetailsByPlaceId(placeId);
        if (details.isOkay) {
          return details.result.formattedAddress ?? 'Unknown Location';
        }
      }
      
      // Fallback ke geocoding jika tidak ada placeId atau Places API gagal
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        List<String> addressParts = [];
        
        // Tambahkan komponen alamat jika tersedia
        if (place.street?.isNotEmpty ?? false) addressParts.add(place.street!);
        if (place.subLocality?.isNotEmpty ?? false) addressParts.add(place.subLocality!);
        if (place.locality?.isNotEmpty ?? false) addressParts.add(place.locality!);
        if (place.subAdministrativeArea?.isNotEmpty ?? false) addressParts.add(place.subAdministrativeArea!);
        if (place.administrativeArea?.isNotEmpty ?? false) addressParts.add(place.administrativeArea!);
        if (place.postalCode?.isNotEmpty ?? false) addressParts.add(place.postalCode!);
        if (place.country?.isNotEmpty ?? false) addressParts.add(place.country!);
        
        return addressParts.join(', ');
      }
    } catch (e) {
      print('Error getting address: $e');
    }
    return 'Unknown Location';
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      isLoading = true;
    });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          Get.snackbar('Permission Denied', 'Location permissions are permanently denied.');
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final address = await _getAddressFromLatLng(position.latitude, position.longitude);

      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        selectedLocation = currentLocation;
        selectedAddress = address;
      });

      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(currentLocation, 15),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to get current location: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  void _searchAddress(String query) async {
    if (query.isEmpty) {
      setState(() {
        suggestions.clear();
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    final response = await places.autocomplete(query);

    if (response.isOkay) {
      setState(() {
        suggestions = response.predictions;
      });
    } else {
      Get.snackbar('Error', 'Failed to fetch suggestions');
    }
    setState(() {
      isLoading = false;
    });
  }

  void _selectSuggestion(Prediction suggestion) async {
    setState(() {
      isLoading = true;
    });

    final details = await places.getDetailsByPlaceId(suggestion.placeId!);

    if (details.isOkay) {
      final location = details.result.geometry!.location;
      final newLocation = LatLng(location.lat, location.lng);
      
      // Gunakan placeId untuk mendapatkan alamat lengkap
      final address = await _getAddressFromLatLng(
        location.lat, 
        location.lng,
        placeId: suggestion.placeId
      );

      setState(() {
        selectedLocation = newLocation;
        selectedAddress = address;
        suggestions.clear();
        searchController.text = suggestion.description ?? '';
      });

      mapController?.animateCamera(CameraUpdate.newLatLngZoom(newLocation, 15));
    } else {
      Get.snackbar('Error', 'Failed to fetch location details');
    }

    setState(() {
      isLoading = false;
    });
  }

  void _clearSearch() {
    setState(() {
      searchController.clear();
      suggestions.clear();
    });
  }

  void _saveLocation() {
    if (selectedLocation != null) {
      Get.back(result: {
        'address': selectedAddress ?? 'Selected Location',
        'position': selectedLocation,
      });
    } else {
      Get.snackbar('Error', 'No location selected!');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: currentLocation,
              zoom: 15,
            ),
            onMapCreated: (controller) => mapController = controller,
            onTap: (position) async {
              setState(() {
                isLoading = true;
              });
              final address = await _getAddressFromLatLng(position.latitude, position.longitude);
              setState(() {
                selectedLocation = position;
                selectedAddress = address;
                isLoading = false;
              });
            },
            markers: selectedLocation != null
                ? {
                    Marker(
                      markerId: const MarkerId('selected'),
                      position: selectedLocation!,
                    ),
                  }
                : {},
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          onChanged: _searchAddress,
                          decoration: InputDecoration(
                            hintText: 'Search location...',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.search, color: Color(0xFF6B34BE)),
                            suffixIcon: searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: Color(0xFF6B34BE)),
                                    onPressed: _clearSearch,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (selectedAddress != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedAddress!,
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (suggestions.isNotEmpty)
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: ListView.builder(
                        itemCount: suggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = suggestions[index];
                          return ListTile(
                            leading: const Icon(Icons.location_on_outlined, color: Color(0xFF6B34BE)),
                            title: Text(suggestion.description!),
                            onTap: () => _selectSuggestion(suggestion),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
          Positioned(
            bottom: 80,
            right: 20,
            child: FloatingActionButton(
              onPressed: _getCurrentLocation,
              backgroundColor: const Color(0xFF6B34BE),
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _saveLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B34BE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Save Location',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}