# Draws the beetroot icon in the Fluent Emoji 3D look (the set has no beet).
# Usage: python3 tool/draw_beetroot.py assets/icons/beetroot.png
import sys, math
from PIL import Image, ImageDraw, ImageFilter, ImageChops
out = sys.argv[1]
K = 4; N = 256 * K
def radial(size, center, radius, inner, outer):
    w, h = size
    im = Image.new('RGBA', size)
    px = im.load()
    cx, cy = center
    for y in range(h):
        for x in range(w):
            t = min(1.0, math.hypot(x - cx, y - cy) / radius)
            px[x, y] = tuple(int(inner[i] + (outer[i] - inner[i]) * t) for i in range(4))
    return im

def masked(fill, mask):
    o = Image.new('RGBA', fill.size, (0, 0, 0, 0)); o.paste(fill, (0, 0), mask); return o

S = 256  # draw at 256 for gradients, mask at N for smooth edges
canvas = Image.new('RGBA', (N, N), (0, 0, 0, 0))

# --- leaves (behind the bulb) ---
def leaf(points_fn):
    m = Image.new('L', (N, N), 0); d = ImageDraw.Draw(m)
    d.polygon(points_fn(), fill=255); return m
def leaf_pts(cx, cy, length, width, angle):
    pts = []
    for i in range(41):
        t = i / 40
        x = t * length; y = math.sin(math.pi * t) * width * (1 - 0.3 * t)
        pts.append((x, y))
    pts += [(x, -y) for x, y in reversed(pts)]
    a = math.radians(angle)
    return [(cx + (x * math.cos(a) - y * math.sin(a)) * K, cy * 1 + (x * math.sin(a) + y * math.cos(a)) * K) for x, y in pts]
green = radial((N, N), (N * 0.42, N * 0.10), N * 0.38, (196, 238, 120, 255), (96, 176, 64, 255))
for ang, ln in ((-125, 78), (-58, 84), (-92, 74)):
    m = leaf(lambda: [(x, y) for x, y in leaf_pts(128 * K, 96 * K, ln, 27, ang)])
    canvas = Image.alpha_composite(canvas, masked(green, m))
# stems / veins
d = ImageDraw.Draw(canvas)
for ang, ln in ((-125, 40), (-58, 44), (-92, 38)):
    a = math.radians(ang)
    d.line([(128 * K, 96 * K), (128 * K + math.cos(a) * ln * K, 96 * K + math.sin(a) * ln * K)], fill=(214, 70, 128, 255), width=5 * K)

# --- bulb: a round body with a tapering root ---
m = Image.new('L', (N, N), 0); d = ImageDraw.Draw(m)
d.ellipse([58 * K, 88 * K, 198 * K, 214 * K], fill=255)
d.polygon([(100 * K, 196 * K), (156 * K, 196 * K), (130 * K, 246 * K)], fill=255)
m = m.filter(ImageFilter.GaussianBlur(3 * K)).point(lambda v: 255 if v > 128 else 0)
body = radial((N, N), (N * 0.38, N * 0.46), N * 0.46, (240, 86, 146, 255), (150, 24, 84, 255))
canvas = Image.alpha_composite(canvas, masked(body, m))
# rim light on the right, like the Fluent pictures
rim = Image.new('L', (N, N), 0); ImageDraw.Draw(rim).ellipse([66 * K, 92 * K, 206 * K, 218 * K], fill=255)
rim = ImageChops.subtract(m, rim).filter(ImageFilter.GaussianBlur(6 * K))
canvas = Image.alpha_composite(canvas, masked(Image.new('RGBA', (N, N), (255, 120, 170, 150)), rim))
# soft white highlight top-left
hl = Image.new('L', (N, N), 0); ImageDraw.Draw(hl).ellipse([84 * K, 108 * K, 122 * K, 140 * K], fill=200)
hl = hl.filter(ImageFilter.GaussianBlur(7 * K))
canvas = Image.alpha_composite(canvas, masked(Image.new('RGBA', (N, N), (255, 230, 240, 255)), ImageChops.multiply(hl, m)))
# thin root tail
d = ImageDraw.Draw(canvas)
d.line([(130 * K, 240 * K), (133 * K, 252 * K)], fill=(120, 20, 60, 255), width=3 * K)

canvas.resize((256, 256), Image.LANCZOS).save(out)
