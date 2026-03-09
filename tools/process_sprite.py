"""
Simple sprite processing script
Requires: pip install pillow
"""

from PIL import Image
import os

def process_sprite(input_path, output_path, target_size=64):
    """
    Process a generated sprite:
    1. Open image
    2. Remove white/light backgrounds
    3. Crop to content
    4. Resize to target size with nearest neighbor
    5. Save as PNG
    """
    print(f"Processing {input_path}...")
    
    # Open image
    img = Image.open(input_path).convert("RGBA")
    
    # Remove white/light background (make transparent)
    pixels = img.load()
    width, height = img.size
    
    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            # If pixel is light (close to white/gray), make it transparent
            if r > 200 and g > 200 and b > 200:
                pixels[x, y] = (255, 255, 255, 0)
    
    # Get bounding box of non-transparent pixels
    bbox = img.getbbox()
    
    if bbox:
        # Crop to content
        img = img.crop(bbox)
        
        # Add small padding
        padding = 4
        new_img = Image.new("RGBA", 
                           (img.width + padding*2, img.height + padding*2), 
                           (0, 0, 0, 0))
        new_img.paste(img, (padding, padding))
        img = new_img
    
    # Resize to target size using nearest neighbor (preserves pixel art look)
    img.thumbnail((target_size, target_size), Image.NEAREST)
    
    # Save
    img.save(output_path, "PNG")
    print(f"Saved to {output_path}")
    print(f"Final size: {img.width}x{img.height}")

if __name__ == "__main__":
    input_file = "assets/sprites/characters/necromancer_raw.png"
    output_file = "assets/sprites/characters/necromancer_idle.png"
    
    if os.path.exists(input_file):
        process_sprite(input_file, output_file, target_size=64)
        print("\nDone! Check the output file.")
    else:
        print(f"Error: {input_file} not found")
