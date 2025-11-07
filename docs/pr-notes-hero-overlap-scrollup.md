# WAZEET App — Hero size + Overlap fix + Scroll-Up

Summary of UI-only changes. No business logic or navigation was modified.

## Final hero heights per breakpoint
- Desktop (>=1024px): ~58vh, min 420px, max 760px
- Tablet (768–1023px): ~50vh, min 380px
- Mobile (<=767px): ~42vh, min 300px

Implemented in `lib/ui/responsive.dart` and applied to:
- Services (`lib/ui/pages/services_page.dart`)
- Community (`lib/ui/pages/community_page.dart`)
- Track Application (`lib/ui/pages/applications_page.dart`)
- More/Profile (`lib/ui/pages/profile_page.dart`)
- Generic `GradientHeader` (`lib/ui/widgets/gradient_header.dart`) used by detail pages

All hero background images use `BoxFit.cover` and a gradient overlay with ~0.35–0.5 opacity for legibility. Titles/subtitles are clamped and ellipsized to prevent overflow.

## Overlap fix
Symptoms were header/avatars spilling past the hero edge. Fixes:
- Sliver backgrounds now set `clipBehavior: Clip.hardEdge` to keep absolutely positioned children within hero bounds on small screens.
- Overlay z-order preserved (image < gradient < texts). SliverAppBar remains `pinned` for proper stacking with content.

## Back-to-Top button
- New reusable widget `BackToTopButton` in `lib/ui/widgets/back_to_top_button.dart`.
- Mounted as `floatingActionButton` and bound to each page's `ScrollController`.
- Appears after ~400px scroll; smooth-scrolls to top; includes accessibility label.

## Typography & spacing
- `GradientHeader` title uses `clampFont()` helper to size between 28–56px with `line-height ~1.1`, max 2 lines.
- Subtitles under heroes limited to 2 lines and ellipsized.

## Notes
- Only presentation layer touched. No handlers/routes/services were changed.
- Tested on common breakpoints; no contrast regressions observed due to overlay tuning.
