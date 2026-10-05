"""Draws build/topdown.json (from scripts/bake.luau) as a preview PNG.

    python3 scripts/render_topdown.py top  [scale] [x0 z0 x1 z1] [out.png]
    python3 scripts/render_topdown.py side [scale] [a0 y0 a1 y1] [out.png] [x|z] [clip0 clip1]

"top" is the overhead view in the same orientation as the reference
screenshots: +X to the right, the hub at the top and the portal at the bottom.
"side" is a flat elevation (bounding boxes only) for checking heights; its
optional clip range keeps only the parts within a slice of the other axis.
"""
import json
import sys

from PIL import Image, ImageDraw

SKY = (120, 180, 255)


def convex_hull(points):
    pts = sorted(set(map(tuple, points)))
    if len(pts) <= 2:
        return pts

    def cross(o, a, b):
        return (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0])

    lower, upper = [], []
    for p in pts:
        while len(lower) >= 2 and cross(lower[-2], lower[-1], p) <= 0:
            lower.pop()
        lower.append(p)
    for p in reversed(pts):
        while len(upper) >= 2 and cross(upper[-2], upper[-1], p) <= 0:
            upper.pop()
        upper.append(p)
    return lower[:-1] + upper[:-1]


def render_top(parts, scale, box, out):
    x0, z0, x1, z1 = box
    img = Image.new("RGB", (int((x1 - x0) * scale), int((z1 - z0) * scale)), SKY)
    draw = ImageDraw.Draw(img, "RGBA")
    for part in sorted(parts, key=lambda p: p["y"]):
        poly = [((x - x0) * scale, (z - z0) * scale) for x, z in convex_hull(part["p"])]
        if len(poly) >= 3:
            draw.polygon(poly, fill=tuple(part["c"]) + (int(255 * (1 - part["t"])),))
    img.save(out)
    return img


def render_side(parts, scale, box, out, axis, clip=None):
    a0, y0, a1, y1 = box
    i = 0 if axis == "x" else 2
    depth = 2 if axis == "x" else 0
    if clip:
        parts = [p for p in parts if p["b"][depth] <= clip[1] and p["b"][depth + 3] >= clip[0]]
    img = Image.new("RGB", (int((a1 - a0) * scale), int((y1 - y0) * scale)), SKY)
    draw = ImageDraw.Draw(img, "RGBA")
    # Far parts first: along +X for a z-elevation, along +Z for an x-elevation.
    for part in sorted(parts, key=lambda p: -p["b"][depth]):
        b = part["b"]
        draw.rectangle(
            [(b[i] - a0) * scale, (y1 - b[4]) * scale, (b[i + 3] - a0) * scale, (y1 - b[1]) * scale],
            fill=tuple(part["c"]) + (int(255 * (1 - part["t"])),),
        )
    img.save(out)
    return img


def main():
    args = sys.argv[1:]
    mode = args[0] if args else "top"
    scale = float(args[1]) if len(args) > 1 else 0.5
    parts = json.load(open("build/topdown.json"))
    if mode == "top":
        box = tuple(map(float, args[2:6])) if len(args) >= 6 else (-390, -390, 390, 1710)
        out = args[6] if len(args) >= 7 else "build/topdown.png"
        img = render_top(parts, scale, box, out)
    else:
        box = tuple(map(float, args[2:6])) if len(args) >= 6 else (-390, -30, 390, 140)
        out = args[6] if len(args) >= 7 else "build/side.png"
        axis = args[7] if len(args) >= 8 else "x"
        clip = tuple(map(float, args[8:10])) if len(args) >= 10 else None
        img = render_side(parts, scale, box, out, axis, clip)
    print(out, img.size)


if __name__ == "__main__":
    main()
