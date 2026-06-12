import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../data/models/item_model.dart';
import '../../services/location_service.dart';
import '../../core/constants.dart';

class FullMapScreen extends StatelessWidget {
  final Item item;

  const FullMapScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final locationService = LocationService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lokasi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: 'Buka di Maps',
            onPressed: () {
              locationService.openInMaps(
                item.latitude!,
                item.longitude!,
                itemName: item.name,
              );
            },
          ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(item.latitude!, item.longitude!),
          initialZoom: 17,
        ),
        children: [
          TileLayer(
            urlTemplate: AppConstants.mapTileUrl,
            userAgentPackageName: 'com.naruhdimana.naruh_dimana',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(item.latitude!, item.longitude!),
                width: 200,
                height: 60,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 36,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
