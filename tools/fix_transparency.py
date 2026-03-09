"""
Fix sprite transparency by removing gray/white background
"""

from PIL import Image

def fix_transparency(input_path, output_path, threshold=200):
    print(f"Fixing transparency for {input_path}...")
    
    # Open image
    img = Image.open(input_path).convert("RGBA")
    
    # Get pixel data
    width, height = img.size
    pixels = img.load()
    
    # Process each pixel
    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            
            # If pixel is light gray/white, make it transparent
            if r > threshold and g > threshold and b > threshold:
                pixels[x, y] = (r, g, b, 0)
    
    # Save
    img.save(output_path, "PNG")
    print(f"Saved to {output_path}")

if __name__ == "__main__":
    fix_transparency(
        "assets/sprites/characters/necromancer_raw.png",
        "assets/sprites/characters/necromancer_idle.png",
        threshold=180  # Lower threshold to catch more gray pixels
    )
    print("Done!")
