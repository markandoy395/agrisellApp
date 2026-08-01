# Asset cleanup candidates

These local farmer and product images were not referenced by repository text as
of 2026-08-01, but they may be selected dynamically from Supabase records. They
must remain in the application until live data can be checked with credentials
that can read all relevant rows.

Live verification was attempted with the local Supabase publishable key. Schema
introspection required a secret key, and read-only queries against the known
image-bearing tables were unauthorized or schema-limited. The incomplete
publishable view is not sufficient evidence for deletion.

Before removing any candidate, search full live data for both its exact relative
path and filename in at least:

- `commodities.image_url`
- `farmers.profile_image_url`
- `farms.farm_images`
- `farms.cover_image_url`
- `users.profile_photo_url`
- `riders.profile_photo_url`
- order, listing, and message snapshots that copy product or profile images

## Farmer image candidates

- `assets/images/farmerImage/images.jpg`
- `assets/images/farmerImage/images1.jpg`
- `assets/images/farmerImage/images2.jpg`
- `assets/images/farmerImage/images3.jpg`
- `assets/images/farmerImage/images4.jpg`

## Product image candidates

- `assets/images/sample fruits and vegetable/photo1464965911861746a04b4bca6.jpg`
- `assets/images/sample fruits and vegetable/photo1517282009859F000ec3b26fe.jpg`
- `assets/images/sample fruits and vegetable/photo1523049673857Eb18f1d7b578.jpg`
- `assets/images/sample fruits and vegetable/photo15288258711153581a5387919.jpg`
- `assets/images/sample fruits and vegetable/photo1571771894821Ce9b6c11b08e.jpg`
- `assets/images/sample fruits and vegetable/photo1574856344991Aaa31b6f4ce3.jpg`
- `assets/images/sample fruits and vegetable/photo158297951221099b6a53386f9.jpg`
- `assets/images/sample fruits and vegetable/photo160042311536787ea7661688f.jpg`
- `assets/images/sample fruits and vegetable/photo1615484477778Ca3b77940c25.jpg`
- `assets/images/sample fruits and vegetable/premiumPhoto1671379041175782d15092945.jpg`
- `assets/images/sample fruits and vegetable/premiumPhoto1674228288342D72cf144e5de.jpg`
