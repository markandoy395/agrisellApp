# Shipping address editing performance

The October 18 DevTools snapshot contains 2,618 recorded frames at 60 Hz.
84 frames exceed 16.67 ms of UI work, and 16 exceed that raster budget.
The worst UI duration is 44.212 ms. These are totals for the recording,
not measurements isolated to the shipping editor or a before/after comparison.

The address suggestions now use a bounded, lazily built list inside a menu
anchor. The previous dropdown constructed and intrinsically measured all visible
suggestion buttons. Search still covers the full locality catalogue and returns
up to 20 suggestions, while the 240-pixel viewport builds only nearby rows.
The list has an independent scroll position to avoid sharing the surrounding
form/menu scroll controller. Explicit selection suppresses duplicate controller
notifications; manual typing preserves cursor and composing changes.

Ordinary edits no longer rebuild the shipping editor just to clear an already
empty validation error. Keyboard inset changes update a small scroll wrapper
while retaining the form child. GPS capture and saving behavior are unchanged.

22 targeted tests pass across address autocomplete, shipping editing/saving,
buyer signup, farmer address lookup, composing text and floating label styling.
Regression assertions cover retaining the form during typing/keyboard resizing,
lazy suggestion rows, searching the last item in a 1,800-place catalogue,
reopening suggestions after no results, and asynchronously loaded localities.
Targeted Dart analysis passes. Changed application files are below 200 lines;
Flutter styles remain dedicated, and the whitespace check passes.

Device performance remains unmeasured after this change. Restart the app with
the updated source in profile mode, clear the Performance recording, and repeat
shipping editing: open the sheet, type/search/select each address field, scroll
suggestions, show/hide the keyboard and save. Compare UI/raster percentiles and
over-budget frame counts for that same interaction on the same phone. A widget
test demonstrates reduced work and behavior, but does not establish phone FPS.
