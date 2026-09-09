#!/usr/bin/env python3
"""Generates Dompet brand assets (launcher, splash, logo) with PIL.

Flat wallet mark on the Dompet brand gradient. Run from the repo root:
    python3 scripts/generate_brand_assets.py
Then regenerate platform assets:
    dart run flutter_launcher_icons
    dart run flutter_native_splash:create
"""

from PIL import Image, ImageDraw

SIZE = 1024
TOP = (123, 131, 236)  # #7B83EC
BOTTOM = (49, 61, 170)  # #313DAA
WHITE = (255, 255, 255, 255)
WHITE_SOFT = (255, 255, 255, 150)


def gradient(size: int) -> Image.Image:
    img = Image.new("RGBA", (size, size))
    px = img.load()
    assert px is not None
    for y in range(size):
        t = y / (size - 1)
        px_color = tuple(int(TOP[i] + (BOTTOM[i] - TOP[i]) * t) for i in range(3)) + (255,)
        for x in range(size):
            px[x, y] = px_color
    return img


def rounded_rect(draw: ImageDraw.ImageDraw, box, radius: int, fill) -> None:
    draw.rounded_rectangle(box, radius=radius, fill=fill)


def draw_wallet(draw: ImageDraw.ImageDraw, s: float, bg) -> None:
    """Draws the wallet mark scaled by s onto a 1024 canvas."""

    def x(v: float) -> int:
        return int(v * s)

    # Back panel peeking above the body.
    rounded_rect(draw, [x(232), x(300), x(700), x(560)], x(70), WHITE_SOFT)
    # Main body.
    rounded_rect(draw, [x(212), x(400), x(812), x(720)], x(100), WHITE)
    # Wallet opening slot.
    rounded_rect(draw, [x(272), x(470), x(752), x(500)], x(15), bg)
    # Side clasp tab.
    rounded_rect(draw, [x(692), x(540), x(868), x(648)], x(54), WHITE)
    # Clasp dot in background color.
    draw.ellipse([x(764), x(566), x(816), x(618)], fill=bg)


def main() -> None:
    bg = gradient(SIZE)
    draw = ImageDraw.Draw(bg)
    draw_wallet(draw, 1.0, BOTTOM)
    bg.convert("RGB").save("assets/images/launcher.png")
    bg.convert("RGB").save("assets/images/logo.png")

    splash = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(splash)
    draw_wallet(draw, 0.72, (85, 96, 214, 255))
    splash.save("assets/images/splash.png")
    print("wrote assets/images/launcher.png, logo.png, splash.png")


if __name__ == "__main__":
    main()
