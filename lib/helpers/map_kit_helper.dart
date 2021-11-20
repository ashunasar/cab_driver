import 'package:maps_toolkit/maps_toolkit.dart';

class MapKitHelper {
  static double getMarkerRotation(
    double sourceLat,
    double sourceLng,
    double destinationLat,
    double destinationLng,
  ) {
    var rotation = SphericalUtil.computeHeading(
        LatLng(sourceLat, sourceLng), LatLng(destinationLat, destinationLng));

    return rotation;
  }
}
