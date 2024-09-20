import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rolebase/pages/large_map_page.dart';

class PlaceDetails extends StatefulWidget {
  final Map<String, dynamic> record;

  const PlaceDetails({Key? key, required this.record}) : super(key: key);

  @override
  State<PlaceDetails> createState() => _PlaceDetailsState();
}

class _PlaceDetailsState extends State<PlaceDetails> {
  GoogleMapController? mapController;
  late LatLng initialLocation;

  @override
  void initState() {
    super.initState();
    double latitude = double.tryParse(widget.record['latitude'] ?? '') ?? 0.0;
    double longitude = double.tryParse(widget.record['longitude'] ?? '') ?? 0.0;
    initialLocation = LatLng(latitude, longitude);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            SizedBox(
              height: size.height * 0.38,
              width: double.maxFinite,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                      image: DecorationImage(
                        image: NetworkImage(
                          widget.record['imageUrl'],
                        ),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          spreadRadius: 0,
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 20,
                    left: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(15),
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            iconSize: 20,
                            icon: const Icon(Icons.arrow_back),
                          ),
                          IconButton(
                            iconSize: 20,
                            onPressed: () {},
                            icon: const Icon(Icons.favorite_border),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.record['name'],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                      ),
                      // style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.record['category'],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600
                      ),
                    )
                  ],
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: IconButton(
                    onPressed: () {},
                    iconSize: 20,
                    icon: const Icon(
                      Icons.chat_bubble_outline,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "4.6",
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Icon(
                      Icons.star,
                      color: Colors.yellow[800],
                      size: 15,
                    )
                  ],
                )
              ],
            ),
            const SizedBox(height: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color:Color(0xFFB75019),
                      size: 20,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Location:',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.inversePrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600
                            ),
                          ),
                          Text(
                            widget.record['location'] ?? '',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Icon(
                      Icons.location_city,
                      color: Color(0xFFB75019),
                      size: 20,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'City:',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.inversePrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600
                            ),
                          ),
                          Text(
                            widget.record['city'] ?? '',
                             style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Description:',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200), // Set a maximum height
                      child: SingleChildScrollView(
                        child: Text(
                          widget.record['description'] ?? '',
                          style: TextStyle(
                             color: Theme.of(context).colorScheme.inversePrimary,
                             fontSize: 14,
                          ),
                          
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10,),
            Container(
              height: 160,
              width: double.maxFinite,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              ),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: initialLocation,
                  zoom: 12,
                ),
                markers: Set<Marker>.of([
                  Marker(
                    markerId: MarkerId(widget.record['name']),
                    position: initialLocation,
                  ),
                ]),
                onMapCreated: (GoogleMapController controller) {
                  setState(() {
                    mapController = controller;
                  });
                },
              ),
            ),
             const SizedBox(height: 15),
             ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LargeMapPage(initialLocation: initialLocation),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(10),
                  backgroundColor: const Color(0xFF0B91A0), 
                elevation: 0,
                shape: const StadiumBorder(),
              ),
              child: const Text("View Larger Map",  style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }
}
