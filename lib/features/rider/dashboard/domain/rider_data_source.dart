enum RiderDataOrigin { backend, temporaryLocal }

abstract interface class RiderDataSourceMetadata {
  RiderDataOrigin get dataOrigin;
}

RiderDataOrigin riderDataOriginOf(Object source) {
  return source is RiderDataSourceMetadata
      ? source.dataOrigin
      : RiderDataOrigin.backend;
}
