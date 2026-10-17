const fs = require('node:fs');

// Read the protobuf wire format without requiring a Perfetto installation.
function fields(bytes) {
  let offset = 0;
  const result = new Map();
  function varint() {
    let value = 0;
    let scale = 1;
    while (offset < bytes.length) {
      const byte = bytes[offset++];
      value += (byte & 127) * scale;
      if (!(byte & 128)) return value;
      scale *= 128;
    }
    throw new Error('Truncated protobuf');
  }
  while (offset < bytes.length) {
    const tag = varint();
    const wire = tag % 8;
    let value;
    if (wire === 0) value = varint();
    else if (wire === 2) {
      const length = varint();
      value = bytes.subarray(offset, offset + length);
      offset += length;
    } else if (wire === 1 || wire === 5) {
      const length = wire === 1 ? 8 : 4;
      value = bytes.subarray(offset, offset + length);
      offset += length;
    } else throw new Error(`Unsupported wire type ${wire}`);
    if (!result.has(tag >>> 3)) result.set(tag >>> 3, []);
    result.get(tag >>> 3).push(value);
  }
  return result;
}

const first = (map, key) => map.get(key)?.[0];
const snapshot = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
const performance = snapshot.performance;
const stacks = new Map();
const slices = [];
for (const packetBytes of fields(Buffer.from(performance.traceBinary)).get(1)) {
  const packet = fields(packetBytes);
  const eventBytes = first(packet, 11);
  if (!eventBytes) continue;
  const event = fields(eventBytes);
  const type = first(event, 9);
  const track = first(event, 11);
  const timestamp = first(packet, 8) / 1000;
  if (!stacks.has(track)) stacks.set(track, []);
  const stack = stacks.get(track);
  if (type === 1) {
    const name = first(event, 23)?.toString() ?? '(unnamed)';
    const annotations = (event.get(4) ?? []).map(bytes => {
      const annotation = fields(bytes);
      return [first(annotation, 10)?.toString(),
        (first(annotation, 6) ?? first(annotation, 9))?.toString()];
    });
    stack.push({name, start: timestamp, track, annotations});
  } else if (type === 2 && stack.length) {
    const slice = stack.pop();
    slices.push({...slice, duration: timestamp - slice.start});
  }
}
const budget = 1e6 / performance.displayRefreshRate;
const frames = performance.flutterFrames;
console.log(JSON.stringify({
  refreshRate: performance.displayRefreshRate,
  frames: frames.length,
  slowBuild: frames.filter(frame => frame.build > budget).length,
  slowRaster: frames.filter(frame => frame.raster > budget).length,
  rasterEvents: slices.filter(slice => slice.name === 'Rasterizer::DoDraw' &&
    slice.duration > budget).map(slice => ({
      start: slice.start, duration: slice.duration, annotations: slice.annotations,
      events: slices.filter(event => event.track === slice.track &&
        event.start >= slice.start &&
        event.start < slice.start + slice.duration && event.duration > 1000 &&
        !event.name.startsWith('Rasterizer::'))
        .map(event => [event.name, event.duration]),
    })),
  longestSlices: slices.filter(slice => slice.duration > 1000)
    .sort((a, b) => b.duration - a.duration).slice(0, 65),
  slowBuildEvents: frames.filter(frame => frame.build > budget).map(frame => ({
    frame,
    events: slices.filter(slice => slice.start >= frame.startTime &&
      slice.start < frame.startTime + frame.build + frame.vsyncOverhead &&
      slice.duration > 500 && !slice.name.startsWith('PlatformChannel'))
      .sort((a, b) => b.duration - a.duration).slice(0, 10),
  })),
}, null, 2));
