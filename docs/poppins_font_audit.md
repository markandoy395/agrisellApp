# Poppins font audit

Audit date: 2026-10-19. Scope: all 1,779 Dart files under `lib`, font assets and
declarations, Android application sources, and text embedded in application HTML.
This is a source audit, not a visual certification of every running screen.
No application behavior or styles were changed for this audit.

## Findings

Update: all seven source findings are resolved. Navigation, OTP descriptions and
destinations, farmer statistic values/labels, support ticket numbers, and waybill
code text now explicitly select `AppTypography.fontFamily`. Printed/exported HTML
links to a self-contained stylesheet containing bundled Poppins font bytes for
weights 400, 600, 700, and 800. The original table below is historical evidence;
its line numbers describe the code before these corrections.

The stylesheet source is now `assets/styles/waybill.css`, registered as a Flutter
asset. `WaybillHtmlStyles` loads that stylesheet and its font assets into data URIs
without network requests. `WaybillHtmlService.generateHtml` is asynchronous so
printing and saving wait for the complete document. Browser-triggered printing
waits for `document.fonts.ready`. Android retains its existing native WebView print
flow and network/file-access restrictions. Actual device printing still needs
visual verification; copied plain text cannot carry a font selection.

Seven affected areas were identified. A missing `fontFamily` alone is not a
failure: ordinary Flutter `Text` widgets merge with their inherited text style.
The inheritance failures below use widgets that do not perform that merge.

| Area | Evidence | Why it does not reliably use Poppins | Recommended correction |
| --- | --- | --- | --- |
| Buyer/farmer bottom navigation labels | `lib/features/shared/widgets/navigation/custom_bottom_nav_tab.dart:75`; `lib/features/shared/widgets/navigation/custom_bottom_nav_tab_styles.dart:11` | `AnimatedDefaultTextStyle` installs a replacement default style whose family is unspecified. Labels inside it lose the surrounding Poppins default and can fall back to the engine/platform font. Used by buyer home, buyer catalogue navigation, and farmer home. | Set `AppTypography.fontFamily` in the dedicated navigation label style. |
| OTP destination instructions and email address | `lib/features/auth/presentation/widgets/otp_verification_components.dart:22`; `lib/features/auth/presentation/styles/otp_verification_styles.dart:80` and `:86` | Raw `RichText` does not merge `DefaultTextStyle`. Neither the root description style nor the destination style specifies Poppins. | Set Poppins in the dedicated styles, or use `Text.rich` to inherit the application typography. |
| Farmer profile statistic values and labels | `lib/features/farmer/profile/presentation/widgets/farmer_profile_stat_pill.dart:19`; `lib/features/farmer/profile/presentation/styles/farmer_profile_header_styles.dart:108` and `:113` | Raw `RichText` has no root font; both child styles omit the family. These pills are mounted by `farmer_profile_header.dart:144` and `:148`. | Set Poppins in the two statistic styles, or use `Text.rich`. |
| Support ticket number in list cards | `lib/features/shared/support/presentation/styles/support_ticket_card_styles.dart:12`; usage in `lib/features/shared/support/presentation/widgets/support_ticket_card.dart:54` | Explicit `fontFamily: 'monospace'` overrides Poppins. | Replace with `AppTypography.fontFamily` if identifiers must follow the same font policy. |
| Support ticket number on detail page | `lib/features/shared/support/presentation/styles/support_ticket_detail_styles.dart:25`; usage in `lib/features/shared/support/presentation/screens/support_ticket_detail_screen.dart:102` | Explicit `fontFamily: 'monospace'` overrides Poppins. | Replace with `AppTypography.fontFamily`. |
| Waybill barcode/code text in preview | `lib/features/shared/waybills/presentation/styles/delivery_waybill_styles.dart:126`; usage in `lib/features/shared/waybills/presentation/widgets/waybill_preview_card.dart:47` | Explicit `fontFamily: 'monospace'` overrides Poppins. This is the code text displayed in the barcode section. | Replace with Poppins if uniform typography is required; review the existing letter spacing separately. |
| Printed/exported HTML waybill | `lib/features/shared/waybills/services/waybill_html_styles.dart:3` and `:7` | The document body selects system fonts (Apple system, Segoe UI, Roboto, Arial, sans-serif); its barcode section selects monospace. Flutter's theme and bundled font registration do not apply to standalone HTML. | Provide Poppins to the standalone document through an offline-compatible font embedding/loading mechanism, then apply it to the body and code section. Merely naming Poppins is insufficient on devices without that font installed. |

## Correct configuration and reviewed exceptions

- `lib/core/theme/app_typography.dart:18` defines the family as Poppins.
- `lib/core/theme/agrisell_theme.dart:39` applies that family to the application
  theme; its text theme also applies the same family.
- `lib/main.dart:87` uses `AgrisellTheme.light`. Its builder additionally merges
  `MainStyles.textStyle` into `DefaultTextStyle`; `lib/main_styles.dart:5` resolves
  that style to Poppins.
- `pubspec.yaml:95` registers Poppins weights 400, 500, 600, 700, and 800. The five
  referenced TTF files exist under `assets/fonts/Poppins`.
- All explicit Dart font-family overrides resolve to Poppins or the three
  monospace declarations listed above. No Google Fonts call, alternate Dart
  font-family fallback list, or `inherit: false` text style was found in `lib`.
- All four raw `RichText` call sites were reviewed. Buyer profile statistic pills
  explicitly specify Poppins in `ProfileHeaderStyles`; home promotion banner
  spans use Poppins through `HomeBannerPromoStyles`. Those two are not findings.
- Local `Theme` wrappers on catalogue, rider vehicle, rider documents, and
  logistics partner views copy the parent theme and change app-bar settings;
  they do not install an unrelated font theme.
- Chat message text, dates/status, input text, hints, counters, and quick replies
  have explicit Poppins styles after the preceding chat changes.
- Across `lib`, 274 files construct `TextStyle` and 76 contain an explicit
  `fontFamily:` argument. This does **not** mean the remaining files use the wrong
  font: most ordinary text and Material controls inherit the application theme.

## Verification and limits

- Ran `flutter test test/app_typography_test.dart`: all three tests passed.
  These verify central typography tokens/theme integration, not every screen.
- Checked the installed Flutter implementation: `RichText` requires explicit
  styling, while `AnimatedDefaultTextStyle` builds a replacement `DefaultTextStyle`
  directly from its supplied animated style. This supports the inheritance
  findings without assuming that all unspecified styles are defective.
- Reviewed application Dart, printable HTML, Android font references, and bundled
  SVG/HTML/CSS font declarations. No additional explicit alternate family was
  found in those asset/native searches. iOS, web, and Windows application folders
  are absent in this checkout.
- No device-wide screenshot review, installed release inspection, or printed
  output verification was performed. Map tile labels, OS permission dialogs,
  keyboards, notification system UI, and lettering inside raster images do not
  inherit Flutter typography and cannot be certified by this source audit.
- Emoji and characters unsupported by the bundled Poppins fonts may use platform
  fallback glyphs even when Poppins is selected. Unsupported font weights may be
  matched/synthesized; this alone does not establish a different font family.
- The originally embedded waybill CSS has now been extracted into a dedicated
  asset stylesheet. Generated HTML uses a stylesheet link rather than a style
  attribute or embedded style block. Font data is embedded in that stylesheet
  to preserve offline printing and standalone HTML export.
- Modified application source/style files remain within 200 physical lines.
  Flutter style definitions remain in dedicated style files.
- Post-fix verification: the OTP, farmer profile, and support detail suites passed;
  the waybill model, preview, screen integration, and print service suites passed
  after their asynchronous asset-loading expectations were updated. Print tests
  verify self-contained TrueType font bytes and preserved native failure handling.
- Formatting and source/style checks passed. The targeted analyzer remained at
  its startup message without returning diagnostics and was stopped; static
  analysis completion is not claimed for these fixes.

## Suggested order

1. Fix navigation labels because they appear throughout buyer/farmer navigation.
2. Fix OTP and farmer profile rich text inheritance.
3. Standardize support/waybill identifiers if monospace is not an approved
   typography exception.
4. Handle printed waybill font delivery separately and verify offline printing.
