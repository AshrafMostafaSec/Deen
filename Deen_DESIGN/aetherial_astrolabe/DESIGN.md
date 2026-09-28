---
name: Aetherial Astrolabe
colors:
  surface: '#111413'
  surface-dim: '#111413'
  surface-bright: '#373a38'
  surface-container-lowest: '#0c0f0e'
  surface-container-low: '#191c1b'
  surface-container: '#1d201f'
  surface-container-high: '#282b29'
  surface-container-highest: '#323534'
  on-surface: '#e1e3e1'
  on-surface-variant: '#c0c9c1'
  inverse-surface: '#e1e3e1'
  inverse-on-surface: '#2e3130'
  outline: '#8a938c'
  outline-variant: '#414943'
  surface-tint: '#9dd2b3'
  primary: '#9dd2b3'
  on-primary: '#003823'
  primary-container: '#2a5c43'
  on-primary-container: '#9dd2b3'
  inverse-primary: '#36684e'
  secondary: '#b3ccbf'
  on-secondary: '#1f352c'
  secondary-container: '#384e44'
  on-secondary-container: '#a6beb1'
  tertiary: '#e0c298'
  on-tertiary: '#402d0f'
  tertiary-container: '#654f2e'
  on-tertiary-container: '#e0c298'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#b9efce'
  primary-fixed-dim: '#9dd2b3'
  on-primary-fixed: '#002112'
  on-primary-fixed-variant: '#1d5038'
  secondary-fixed: '#cfe8db'
  secondary-fixed-dim: '#b3ccbf'
  on-secondary-fixed: '#091f17'
  on-secondary-fixed-variant: '#354b42'
  tertiary-fixed: '#fedeb2'
  tertiary-fixed-dim: '#e0c298'
  on-tertiary-fixed: '#281800'
  on-tertiary-fixed-variant: '#584323'
  background: '#111413'
  on-background: '#e1e3e1'
  surface-variant: '#323534'
typography:
  display-lg:
    fontFamily: Space Grotesk
    fontSize: 48px
    fontWeight: '600'
    lineHeight: 52px
    letterSpacing: -0.03em
  display-lg-mobile:
    fontFamily: Space Grotesk
    fontSize: 36px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Space Grotesk
    fontSize: 32px
    fontWeight: '500'
    lineHeight: 38px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Space Grotesk
    fontSize: 24px
    fontWeight: '500'
    lineHeight: 30px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Space Grotesk
    fontSize: 20px
    fontWeight: '500'
    lineHeight: 26px
    letterSpacing: 0em
  body-lg:
    fontFamily: Geist
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
    letterSpacing: -0.01em
  body-md:
    fontFamily: Geist
    fontSize: 15px
    fontWeight: '400'
    lineHeight: 22px
    letterSpacing: -0.005em
  body-sm:
    fontFamily: Geist
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
    letterSpacing: 0em
  label-md:
    fontFamily: Geist
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.04em
  label-sm:
    fontFamily: Geist
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
    letterSpacing: 0.06em
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-tablet: 1.5rem
  gutter-desktop: 2rem
  margin: 1.25rem
  margin-tablet: 2rem
  margin-desktop: 3rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2.5rem
---

## Brand & Style

This design system reimagines spiritual utility through the lens of hyper-modern celestial calculation. Combining the historical mathematical rigor of Islamic astrolabes with the ultra-refined spatial depth of forward-looking mobile operating systems, the visual language balances clinical precision with contemplative serenity. 

The aesthetic is minimal, glass-forward, and atmospheric. It moves decisively away from nostalgic brass filigree or literal ornamentation, opting instead for razor-sharp monoline astronomical coordinate geometry, ambient spectral glows, and frosted multi-layered glass. Designed natively for high-density OLED environments with an RTL-first architecture, the UI feels weightless, silent, and architecturally permanent. The emotional resonance is centered on focus, spiritual stillness, and mathematical order.

## Colors

The palette derives its core harmony from deep mineral graphite, celestial stone, and the signature deep emerald sage. 

- **Primary (`#2A5C43`)**: An ancient, deep cypress emerald. Used for focal anchor points, active prayer progress rings, precision celestial pointers, and critical primary toggles.
- **Secondary (`#8EA69A`)**: A soft lichen mist. Provides luminous, legible contrast against dark surfaces for auxiliary data metrics, coordinate axis tracks, and active sub-states.
- **Tertiary (`#C5A880`)**: Muted celestial sand. Evokes ancient parchment and dry desert starlight, reserved strictly for solar transit nodes, golden hour markers, and Quranic verse pauses.
- **Neutral Base (`#0B0E0D`)**: A calibrated OLED graphite-black tinted slightly toward deep obsidian chlorite, eliminating eye strain during pre-dawn (Fajr) and nocturnal (Tahajjud) use.
- **Surface Elevation Layers**:
  - Base: `#0B0E0D`
  - Elevated Card: `#151A18`
  - Floating Interactive Panel: `rgba(21, 26, 24, 0.72)` with active background blur.
  - Hairline Boundaries: `rgba(255, 255, 255, 0.08)` for dark, `rgba(0, 0, 0, 0.06)` for light contexts.

## Typography

The typography unites technological geometric precision with serene clarity. 

- **Space Grotesk** serves as the headline and technical numeric display face. Its idiosyncratic geometric cuts provide an instrument-grade character, ideal for prayer timestamps, degree measurements, azimuth values, and celestial titles.
- **Geist** handles standard interface labels, functional metadata, and body copy. Its neutral, condensed structure ensures high density without visual clutter.
- **RTL & Script Hierarchy**: When rendering Arabic scripture, the system pairs natively with Amiri/Uthmani typefaces for sacred text, preserving traditional calligraphy metrics while using Geist and Space Grotesk for accompanying translations, timing metrics, and navigational structures. Numerals across all time tables use tabular lining figures (`tnum`) to keep astrolabe data columns aligned.

## Layout & Spacing

Layouts follow an asymmetrical, dynamic fluid grid designed for seamless bidirectional reading (RTL-first default). Margins are generous to maintain visual peace and contemplation.

- **Column System**: A 4-column system on mobile devices, expanding to 8 columns on medium canvas sizes, and 12 columns on large displays. Cards snap to full span or half span; astrolabe instrumentation takes precedence in a centralized 1:1 square aspect ratio block.
- **Directionality (RTL)**: Flow runs intrinsically from right to left. Timeline progressions for daily prayer cycles advance right-to-left across the horizontal axis, reflecting both script dynamics and the counter-clockwise rotation of classic planar astrolabes.
- **Spacing Rhythm**: Constructed around a base 4px/8px modular cadence. Padding tokens dictate clean boundaries, allowing transparent layers to overlap without cognitive noise.

## Elevation & Depth

Elevation is achieved purely through translucent liquid glass physics and tonal luminance stratification rather than muddy drop shadows.

- **Level 0 (Obsidian Canvas)**: Flat `#0B0E0D`, completely non-reflective, anchoring the eye.
- **Level 1 (Surface Tiles)**: Solid `#151A18` backed by an ultra-thin 1px border of `rgba(255, 255, 255, 0.06)` to catch specular rim light.
- **Level 2 (Liquid Astrolabe Glass)**: `rgba(21, 26, 24, 0.65)` layered over real-time vector coordinate meshes with a 32px Gaussian backdrop blur (`backdrop-filter: blur(32px) saturate(160%)`). Outer edge illuminated by an inward top-to-bottom directional gradient border (`rgba(255, 255, 255, 0.14)` to `rgba(255, 255, 255, 0.02)`).
- **Level 3 (Modal Sheets & Floating Navigation Bar)**: Detached pill geometries floating above the viewport with `rgba(11, 14, 13, 0.82)` blur, casting an ultra-diffused ambient shadow: `0 20px 40px rgba(0, 0, 0, 0.45)`.
- **Specular Highlights**: Critical interactive points emit an ethereal inner glow using the primary emerald sage (`box-shadow: inset 0 0 12px rgba(42, 92, 67, 0.3)`).

## Shapes

The design system adopts a pill-shaped curvature philosophy (`roundedness: 3`).

- **Macro Containers (Cards & Instrument Panels)**: Built with `2rem` (32px) to `3rem` (48px) continuous curvature (squircle / Apple smooth corners), echoing celestial orbits and astrolabe plates (*safīḥah*).
- **Interactive Controls (Buttons, Chips, Sliders)**: Fully rounded pill silhouettes (`9999px` / `rounded-full`). These soften the technical nature of coordinate charts and wireframes.
- **Glyphs & Monolines**: All vector accents use uniform 1.25px or 1.5px monoline strokes with round caps and joins, mirroring astrolabe rete pointers and star charts.

## Components

### Buttons
- **Primary Action**: Pill-shaped capsule filled with primary `#2A5C43`, featuring high-contrast white text (`Geist`, 15px, 600 weight). Pressed state applies a tactile `scale(0.97)` and brightens background tint to `#346E51`.
- **Secondary (Glass Pill)**: Translucent surface `rgba(255, 255, 255, 0.06)` framed by a 1px border of `rgba(255, 255, 255, 0.1)`. Supports RTL chevron glyphs that flip automatically based on system locale.

### Astrolabe Prayer Cards
- **Structure**: Generous 32px curved cards housing the prayer name, astronomical altitude angle, and calculated countdown.
- **Active State (Current Prayer)**: The card transitions from deep `#151A18` to an illuminated glass state with a subtle background radial gradient tinted with `#2A5C43`. A thin monoline indicator charts the sun’s exact arc through the sky.

### Chips & Filters
- **Form**: Compact 32px-height pill controls.
- **Visuals**: Unselected chips display subtle `rgba(255, 255, 255, 0.04)` backgrounds with muted text (`#8EA69A`). Selected chips illuminate in primary emerald with crisp white typographic labels.

### Input Fields
- **Form**: 48px height with continuous rounded corners. Background is `rgba(255, 255, 255, 0.03)` with a precise hairline border. On focus, the border turns `#8EA69A` with an ambient glow of `rgba(42, 92, 67, 0.25)`. Text alignment defaults to right-aligned for Arabic script inputs.

### Lists & Navigation
- **Floating Island Tab Bar**: Detached pill floating 24px above the bottom screen margin. Composed of dark frosted glass with icons representing the Astrolabe (Qibla/Sky), Horologium (Prayer Times), and Scripture (Quran).
- **List Items**: Inset grouped styling separated by fractional hairline dividers (`rgba(255, 255, 255, 0.05)`), ending before the trailing edge to maintain airy visual rhythm.

### Selection Controls (Toggles & Radio Indicators)
- **Toggles**: Fluid pill tracks (`#1F2623` when inactive; `#2A5C43` when active) carrying a pure white circular thumb with a low-intensity drop shadow.
- **Radio Rings**: Concentric monoline rings reminiscent of planetary orbits. The inner indicator fills with a clean emerald node when selected.