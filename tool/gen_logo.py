#!/usr/bin/env python3
"""Generates the Admity brand assets from the in-app Eraly mascot geometry.

Outputs (drawn at 4x then downsampled for crisp anti-aliasing):
  assets/brand/admity_icon.png        1024  full-bleed terracotta app icon
  assets/brand/admity_mark.png        1024  transparent mark (terracotta tile + bird)
  assets/brand/admity_splash.png      1024  transparent mark for the native splash

Colors mirror lib/core/theme/app_colors.dart so the static assets match the
runtime vector logo exactly.
"""
import os
from PIL import Image, ImageDraw

# ── Brand palette (from app_colors.dart) ──────────────────────────────────────
TERRACOTTA = (200, 99, 59)      # #C8633B
TERRACOTTA_DARK = (163, 78, 44)  # #A34E2C
CREAM = (255, 251, 243)          # #FFFBF3
INK = (35, 31, 26)               # #231F1A
SAND = (246, 241, 231)           # #F6F1E7

SCALE = 4
OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "brand")
os.makedirs(OUT, exist_ok=True)


def rounded(size, radius_frac, fill):
    """An iOS-ish rounded square RGBA layer."""
    s = size * SCALE
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    r = int(s * radius_frac)
    d.rounded_rectangle([0, 0, s - 1, s - 1], radius=r, fill=fill + (255,))
    return img


def draw_bird(img, inset_frac=0.0):
    """Paints the Eraly steppe-bird mark centered on `img` (RGBA, square)."""
    s = img.size[0]
    d = ImageDraw.Draw(img)
    cx, cy = s / 2, s / 2
    w = s * (1 - inset_frac)

    # Body — warm cream rounded shield.
    br = w * 0.34
    d.rounded_rectangle(
        [cx - br, cy - br * 0.92, cx + br, cy + br * 1.08],
        radius=int(br * 0.9), fill=CREAM + (255,),
    )

    # Crest — a steppe-bird feather rising from the head (terracotta-dark).
    crest = [
        (cx, cy - br * 1.55),
        (cx + w * 0.16, cy - br * 0.78),
        (cx - w * 0.02, cy - br * 0.55),
        (cx - w * 0.13, cy - br * 0.86),
    ]
    d.polygon(crest, fill=TERRACOTTA_DARK + (255,))

    # Eyes.
    er = w * 0.038
    for dx in (-0.105, 0.105):
        ex, ey = cx + w * dx, cy - br * 0.02
        d.ellipse([ex - er, ey - er, ex + er, ey + er], fill=INK + (255,))

    # Smile — a warm terracotta arc.
    mw = w * 0.17
    my = cy + br * 0.42
    d.arc([cx - mw, my - mw, cx + mw, my + mw], start=20, end=160,
          fill=TERRACOTTA + (255,), width=int(w * 0.028))


def save(img, name, final=1024):
    img = img.resize((final, final), Image.LANCZOS)
    path = os.path.normpath(os.path.join(OUT, name))
    img.save(path)
    print("wrote", path)


# 1) Full-bleed app icon: terracotta tile + bird.
icon = rounded(1024, 0.225, TERRACOTTA)
draw_bird(icon, inset_frac=0.18)
save(icon, "admity_icon.png")

# 2) Transparent mark: a smaller terracotta tile with the bird (for in-doc use).
mark = Image.new("RGBA", (1024 * SCALE, 1024 * SCALE), (0, 0, 0, 0))
tile = rounded(1024, 0.26, TERRACOTTA).resize(
    (int(1024 * SCALE * 0.78), int(1024 * SCALE * 0.78)), Image.LANCZOS)
off = (1024 * SCALE - tile.size[0]) // 2
mark.alpha_composite(tile, (off, off))
draw_bird(mark, inset_frac=0.30)
save(mark, "admity_mark.png")

# 3) Native splash mark (same as the tile mark; sits on a SAND background).
save(mark.copy(), "admity_splash.png")

print("done")
