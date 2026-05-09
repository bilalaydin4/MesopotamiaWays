import os
import shutil

ios_assets = "/Users/bilalaydin4/Desktop/MesopotamiaWays/MesopotamiaWays/Assets.xcassets"
android_drawable = "/Users/bilalaydin4/Desktop/MesopotamiaWaysAndroid/app/src/main/res/drawable"

os.makedirs(android_drawable, exist_ok=True)

for root, dirs, files in os.walk(ios_assets):
    if root.endswith(".imageset"):
        image_name = os.path.basename(root).replace(".imageset", "").lower()
        
        # Find the largest image file in the imageset (highest resolution)
        largest_file = None
        max_size = -1
        
        for f in files:
            if f.lower().endswith((".jpg", ".png", ".jpeg", ".webp")):
                filepath = os.path.join(root, f)
                size = os.path.getsize(filepath)
                if size > max_size:
                    max_size = size
                    largest_file = filepath
                    
        if largest_file:
            ext = largest_file.split(".")[-1].lower()
            dest_path = os.path.join(android_drawable, f"{image_name}.{ext}")
            print(f"Copying {image_name}...")
            shutil.copy(largest_file, dest_path)
