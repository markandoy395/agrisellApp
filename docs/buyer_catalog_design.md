# Buyer home and All Products design

Reference: Figma file `qhRCyLteZ8riof9O7huqTa`, home frame `1:343` and
All Products frame `1:2`. The originally linked home node `1:344` is only
the background vector; its parent is the actual home design.

Following the user's layout revision, sale and regular products share the same
Fresh picks grid. The separate sale preview and its duplicate widget were removed.
Both Home and All Products show exactly two wider cards per row. Discount badges
and original/active prices appear on eligible sale cards in this combined grid.
View All is available beside Fresh picks and opens the full authenticated buyer
catalog. Its shared catalog controller preserves
pagination, refresh, errors and account-scoped product data. Category chips,
search, sorting, saved hearts, product details and basket actions are functional.
Sorting uses active sale prices. Counts with `+` indicate more pages are available.
The bottom navigation returns to the existing home tabs and carries real badges.

Both grids use lazy slivers and retain two columns with enlarged device text.
Existing authenticated product image loading and
bounded image decoding are reused. Production product images, prices, discounts,
stock and badges remain data supplied; Figma sample products are not bundled.

Typography and colors use Poppins, AppTypography and AgrisellColors. The supplied
home frame leaves its upper region blank, so existing header, search, promotions
and catalog discovery remain. Existing buyer navigation assets are retained.

Six static icons were downloaded from the supplied design and rasterized at
72px width with preserved aspect ratios, about 8 KB total. They are bundled as
`assets/icons/buyer_catalog_*.png`; no temporary Figma URL or new runtime package
is used. The temporary converter and original SVGs live only under ignored build
output. Card shapes, category pills and backgrounds are native Flutter styles.

The new destination uses the guarded route factory plus AuthRoleGate for buyer
role/status. The basket shortcut independently checks the valid session and
central buyer role/status contract before invoking the existing basket service.
No queries, backend grants, tables, or policies were added or broadened. Existing
catalog RPCs and cart synchronization use the same bound parameters and identity
contracts. Live backend/cart/device verification is not implied by widget tests.

Verification covers catalog filtering, active-price sorting, saves, cart actions,
product callbacks, session-loss hiding, combined-grid bounds, pagination, local asset
decoding and responsive layouts at 320/390/700px with enlarged device text.
Rendered screenshots are generated under `build/buyer_catalog_previews`.

Final local checks: 16 focused Flutter tests passed across the combined catalog,
existing buyer home, pagination and campaign screens. Focused Dart
analysis reported no issues. Modified application files are at most 200 lines,
and styling constructors remain in dedicated style files. Rendered previews were
inspected with decoded local images and icons; the sample test uses generic
product imagery, while production continues to use actual catalog photos.
Existing bottom-navigation rendering was reused; its separate visual differences
from the reference were not changed. No device or hosted checkout test was run.

Navigation clearance follow-up: buyer Home no longer extends its body behind the
bottom navigation. Scaffold reserves the bar's actual height and safe-area inset,
so product cards and basket actions stay in the visible scrolling viewport.
Nine home/navigation tests passed, including full-card and button geometry and
successful taps with 0px and 34px device bottom insets.
