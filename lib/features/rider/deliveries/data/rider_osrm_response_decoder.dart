import 'dart:convert';
import 'dart:typed_data';

import '../domain/rider_route_plan.dart';
import 'rider_osrm_parser.dart';

/// A top-level compute callback avoids capturing the HTTP client or cache.
List<RiderRoutePlan> decodeOsrmRiderResponse(
  ({Uint8List bytes, String requestId, String destinationKey}) input,
) => parseOsrmRiderRoutes(
  jsonDecode(utf8.decode(input.bytes)),
  requestId: input.requestId,
  destinationKey: input.destinationKey,
);
