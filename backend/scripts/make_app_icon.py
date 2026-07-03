"""
One-shot generator for WageWise app icon (RM coin + upward arrow on orange gradient).
Outputs:  mobile_app/assets/icons/app_icon.png   (1024x1024, full bleed)
          mobile_app/assets/icons/app_icon_foreground.png (1024x1024, transparent bg for Android adaptive)

Run:  ./.venv/Scripts/python.exe backend/scripts/make_app_icon.py
"""

import os
from PIL import Image, ImageDraw, ImageFont

SIZE = 1024
ORANGE_A = (255, 146, 28)   # #FF921C
ORANGE_B = (236, 164, 39)   # #ECA427
COIN_FILL = (255, 248, 230) # cream
COIN_RING = (255, 255, 255) # white outer ring
TEXT_FILL = (240, 110, 0)   # deep orange for "RM"
ARROW_FILL = (34, 197, 94)  # green-500
ARROW_SHADOW = (0, 0, 0, 60)

OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "..", "mobile_app", "assets", "icons")
os.makedirs(OUT_DIR, exist_ok=True)


def vertical_gradient(size, top_rgb, bot_rgb):
    img = Image.new("RGB", (size, size), top_rgb)
    px = img.load()
    for y in range(size):
        t = y / (size - 1)
        r = int(top_rgb[0] * (1 - t) + bot_rgb[0] * t)
        g = int(top_rgb[1] * (1 - t) + bot_rgb[1] * t)
        b = int(top_rgb[2] * (1 - t) + bot_rgb[2] * t)
        for x in range(size):
            px[x, y] = (r, g, b)
    return img


def rounded_mask(size, radius):
    mask = Image.new("L", (size, size), 0)
    d = ImageDraw.Draw(mask)
    d.rounded_rectangle((0, 0, size - 1, size - 1), radius=radius, fill=255)
    return mask


def load_font(size, bold=True):
    candidates = [
        "C:/Windows/Fonts/segoeuib.ttf" if bold else "C:/Windows/Fonts/segoeui.ttf",
        "C:/Windows/Fonts/arialbd.ttf" if bold else "C:/Windows/Fonts/arial.ttf",
    ]
    for p in candidates:
        if os.path.exists(p):
            return ImageFont.truetype(p, size)
    return ImageFont.load_default()


def draw_icon(transparent_bg: bool):
    """Compose the icon. If transparent_bg=True, skip the orange gradient (for
    Android adaptive icon foreground layer)."""
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))

    if not transparent_bg:
        # Orange gradient background with rounded corners
        bg = vertical_gradient(SIZE, ORANGE_A, ORANGE_B).convert("RGBA")
        bg.putalpha(rounded_mask(SIZE, radius=int(SIZE * 0.22)))
        img.alpha_composite(bg)

    d = ImageDraw.Draw(img)

    # ── Coin (large circle, centred slightly low) ─────────────────────
    coin_d = int(SIZE * 0.62)            # diameter
    coin_x = (SIZE - coin_d) // 2
    coin_y = int(SIZE * 0.26)
    # outer white ring
    ring_w = int(coin_d * 0.06)
    d.ellipse((coin_x, coin_y, coin_x + coin_d, coin_y + coin_d), fill=COIN_RING)
    # inner cream fill
    inner_x = coin_x + ring_w
    inner_y = coin_y + ring_w
    inner_d = coin_d - 2 * ring_w
    d.ellipse((inner_x, inner_y, inner_x + inner_d, inner_y + inner_d), fill=COIN_FILL)

    # "RM" text inside the coin
    font = load_font(int(coin_d * 0.42), bold=True)
    text = "RM"
    bbox = d.textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    tx = coin_x + (coin_d - tw) // 2 - bbox[0]
    ty = coin_y + (coin_d - th) // 2 - bbox[1] - int(coin_d * 0.04)
    d.text((tx, ty), text, fill=TEXT_FILL, font=font)

    # ── Upward arrow (top-right, suggesting wage growth) ─────────────
    # Arrow as a chunky triangle + stem
    arrow_size = int(SIZE * 0.22)
    ax = int(SIZE * 0.70)
    ay = int(SIZE * 0.12)
    # green rounded square background for arrow
    arrow_bg = arrow_size + int(arrow_size * 0.35)
    abg_x = ax - int(arrow_size * 0.18)
    abg_y = ay - int(arrow_size * 0.18)
    d.rounded_rectangle(
        (abg_x, abg_y, abg_x + arrow_bg, abg_y + arrow_bg),
        radius=int(arrow_bg * 0.30),
        fill=ARROW_FILL,
    )
    # white arrow inside the green badge
    arrow_pad = int(arrow_size * 0.20)
    inner_left = abg_x + arrow_pad
    inner_top = abg_y + arrow_pad
    inner_right = abg_x + arrow_bg - arrow_pad
    inner_bottom = abg_y + arrow_bg - arrow_pad

    # Arrow triangle (apex top-right, base bottom-left)
    apex = (inner_right, inner_top)
    bot_left = (inner_left, inner_bottom)
    tip = (inner_right, inner_top)
    # Two diagonal triangles + a stem line for a clean ↗ arrow
    # 1. Diagonal line
    line_w = int(arrow_size * 0.20)
    d.line([bot_left, tip], fill=(255, 255, 255), width=line_w)
    # 2. Arrowhead
    head = int(arrow_size * 0.45)
    d.polygon(
        [
            tip,
            (tip[0] - head, tip[1]),
            (tip[0], tip[1] + head),
        ],
        fill=(255, 255, 255),
    )
    return img


def main():
    # Full icon (orange bg + coin + arrow) — for iOS, web favicon, fallback Android
    full = draw_icon(transparent_bg=False)
    full_path = os.path.join(OUT_DIR, "app_icon.png")
    full.save(full_path, "PNG")
    print(f"  wrote {full_path}")

    # Foreground-only (transparent bg) — for Android adaptive icon
    fg = draw_icon(transparent_bg=True)
    fg_path = os.path.join(OUT_DIR, "app_icon_foreground.png")
    fg.save(fg_path, "PNG")
    print(f"  wrote {fg_path}")

    # 32x32 web favicon (downscaled with antialiasing)
    favicon = full.resize((32, 32), Image.LANCZOS)
    fav_path = os.path.join(OUT_DIR, "favicon.png")
    favicon.save(fav_path, "PNG")
    print(f"  wrote {fav_path}")

    print("\nAll three icons generated.")


if __name__ == "__main__":
    main()
