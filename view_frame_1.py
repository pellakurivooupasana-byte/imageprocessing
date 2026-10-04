from PIL import Image

WIDTH, HEIGHT = 640, 480

img = Image.new("RGB", (WIDTH, HEIGHT))
pixels = img.load()

path = r"C:\intelFPGA_lite\18.1\simulation\modelsim\frame_output_6.txt"

def hex_to_int(s):
    """Convert hex string to int, treating 'x' as 0."""
    s = s.lower().replace('x', '0').replace('z', '0')
    try:
        return int(s, 16)
    except ValueError:
        return 0

with open(path) as f:
    idx = 0
    for line in f:
        parts = line.split()

        if len(parts) == 5:
            x, y, r, g, b = parts
            x, y = int(x), int(y)
        elif len(parts) == 3:
            r, g, b = parts
            y, x = divmod(idx, WIDTH)
            idx += 1
        else:
            continue

        r = hex_to_int(r) * 17
        g = hex_to_int(g) * 17
        b = hex_to_int(b) * 17

        if 0 <= x < WIDTH and 0 <= y < HEIGHT:
            pixels[x, y] = (r, g, b)

out_path = r"C:\intelFPGA_lite\18.1\simulation\modelsim\simulated_output_6.png"
img.save(out_path)
img.show()
print(f"Saved: {out_path}")
