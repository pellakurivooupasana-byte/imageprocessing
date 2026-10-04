from PIL import Image

WIDTH = 320
HEIGHT = 240

input_path = r"C:/Users/kumar/OneDrive/Desktop/New folder/rose.png"
output_path = r"C:/Users/kumar/OneDrive/Desktop/New folder/rose.mif"

# --------------------------------------------------
# OPEN ORIGINAL IMAGE
# --------------------------------------------------

img = Image.open(input_path).convert("RGBA")

print("Original:", img.size)

# --------------------------------------------------
# Convert transparency to BLACK background
# --------------------------------------------------

background = Image.new("RGB", img.size, (0, 0, 0))

background.paste(
    img,
    mask=img.getchannel("A")
)

img = background

# --------------------------------------------------
# DO NOT CROP
# Resize entire original image
# --------------------------------------------------

img = img.resize(
    (WIDTH, HEIGHT),
    Image.Resampling.LANCZOS
)

print("Final:", img.size)

# --------------------------------------------------
# GENERATE MIF
# --------------------------------------------------

with open(output_path, "w") as f:

    f.write("WIDTH=12;\n")
    f.write(f"DEPTH={WIDTH * HEIGHT};\n")
    f.write("ADDRESS_RADIX=UNS;\n")
    f.write("DATA_RADIX=HEX;\n")
    f.write("CONTENT BEGIN\n")

    for i, (r, g, b) in enumerate(img.getdata()):

        r4 = r >> 4
        g4 = g >> 4
        b4 = b >> 4

        pixel = f"{r4:X}{g4:X}{b4:X}"

        f.write(f"\t{i} : {pixel};\n")

    f.write("END;\n")

print("rose.mif generated successfully!")
print("Depth:", WIDTH * HEIGHT)
print("Output:", output_path)
