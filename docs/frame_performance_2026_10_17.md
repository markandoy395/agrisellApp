# October 17 Android frame capture

Input: `test/frames/dart_devtools_2026-10-17_22_47_11.245.json`.
Flutter 3.44.4, Android profile build, 60 Hz (16.67 ms stage budget).

## Baseline evidence

The exported frame list contains 1,151 frames. Eleven have build durations
above budget and 43 have raster durations above budget; these counts can overlap.
The worst build is frame 212 at 35.752 ms. The worst raster is frame 811 at
40.813 ms. Frame 213 has 93.238 ms of vsync overhead.

The embedded Perfetto timeline also contains startup frames outside that list.
It records a 97.807 ms `PipelineVK::Create` inside startup frame 10, plus a
103.616 ms `AcquireNextDrawable` in startup frame 20. Many later raster spikes
spend most of their time in `AcquireNextDrawable`, while encoding takes only a
few milliseconds. This is evidence of surface/presentation waits; widget build
optimizations alone cannot establish that these device stalls are resolved.

Slow build frames include root layout, build work and garbage collection.
The capture does not include widget-level attribution or CPU samples, so it
does not prove which individual widget caused each slow build.

## Changes

- Address suggestions retain their entry list when the visible results are
  unchanged, including when a parent creates an equivalent options list.
  Flutter's DropdownMenu otherwise regenerates item GlobalKeys whenever the
  entry list identity changes. Actual option changes still replace the entries.
- AuthScaffold observes keyboard insets only inside the compact card layout.
  Ordinary auth sheets no longer rebuild their header for each inset update.
- The role selection background has the same repaint isolation as other auth
  layouts, keeping its static image separate from foreground changes.

These are targeted reductions in avoidable work found during source inspection,
not measured improvements to the saved capture. The capture is preserved.

## Verification and reproduction

The targeted tests cover retained entries during parent/keyboard rebuilds,
searching catalogues up to 1,800 places, changed options, no-match results,
selection, composition preservation, auth header identity, compact layouts,
keyboard focus, and signup address payloads.

All 19 tests in the six targeted test files passed. The four application source
files are 44, 150, 102 and 81 physical lines respectively. Formatting passed,
and no prohibited inline style constructors were found in those files.
Targeted Dart analysis completed with no issues.

Run the trace inspector with Node; it needs no downloaded packages:

```powershell
node scripts/maintenance/inspect_frame_trace.cjs test/frames/dart_devtools_2026-10-17_22_47_11.245.json
```

Timeline spans such as image listeners and platform channel results may cover
asynchronous waits. Their wall duration must not be treated as UI CPU time.

For device verification, rebuild in profile mode on the same Infinix device,
repeat the original navigation/address typing/keyboard interactions and export
a fresh capture. Compare build and raster stage counts separately, separating
cold startup from warmed interactions. Persistent drawable waits require further
Android presentation/driver investigation. No renderer change or device-level
improvement is claimed by this patch.
