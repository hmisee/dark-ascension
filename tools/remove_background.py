"""
Remove background from sprite using color similarity
Works better for patterned backgrounds
"""

from PIL import Image
import math

def color_distance(c1, c2):
    """Calculate Euclidean distance between two RGB colors"""
    return math.sqrt(sum((a - b) ** 2 for a, b in zip(c1[:3], c2[:3])))

def remove_background(input_path, output_path, sample_corner=True, threshold=50):
    """
    Remove background by sampling corner color and removing similar colors
    
    Args:
        input_path: Input image path
        output_path: Output image path
        sample_corner: If True, use top-left corner as background color
        threshold: Color similarity threshold (0-255, lower = more strict)
    """
    print(f"Processing {input_path}...")
    
    # Open image
    img = Image.open(input_path).convert("RGBA")
    width, height = img.size
    pixels = img.load()
    
    # Sample background color from top-left corner
    if sample_corner:
        bg_color = pixels[0, 0]
        print(f"Background color sampled: RGB{bg_color[:3]}")
    else:
        bg_color = (200, 200, 200, 255)  # Default gray
    
    # Process each pixel
    transparent_count = 0
    for y in range(height):
        for x in range(width):
            current_color = pixels[x, y]
            
            # Calculate color distance
            distance = color_distance(current_color, bg_color)
            
            # If color is similar to background, make transparent
            if distance < threshold:
                pixels[x, y] = (current_color[0], current_color[1], current_color[2], 0)
                transparent_count += 1
    
    print(f"Made {transparent_count} pixels transparent")
    
    # Crop to content
    bbox = img.getbbox()
    if bbox:
        img = img.crop(bbox)
        print(f"Cropped to {img.size}")
    
    # Resize to 64x64 with padding
    max_size = 64
    img.thumbnail((max_size - 8, max_size - 8), Image.NEAREST)
    
    # Create new image with padding
    final_img = Image.new("RGBA", (max_size, max_size), (0, 0, 0, 0))
    offset = ((max_size - img.width) // 2, (max_size - img.height) // 2)
    final_img.paste(img, offset)
    
    # Save
    final_img.save(output_path, "PNG")
    print(f"Saved to {output_path} (64x64)")

if __name__ == "__main__":
    remove_background(
        "assets/sprites/characters/necromancer_raw.png",
        "assets/sprites/characters/necromancer_idle.png",
        sample_corner=True,
        threshold=100  # Maximum removal for edge pixels
    )
    print("\nDone! Reimport in Godot to see changes.")
