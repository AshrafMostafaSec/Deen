#!/usr/bin/env python3
import json
import os
from PIL import Image, ImageDraw, ImageFont

def generate_icons():
    # Base size for supersampling
    super_size = 2048
    target_size = 1024
    
    # Create OLED pure black canvas
    img = Image.new("RGBA", (super_size, super_size), (0, 0, 0, 255))
    draw = ImageDraw.Draw(img)
    
    # Use DejaVuSans-Bold for authoritative, iconic typography
    font_path = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
    if not os.path.exists(font_path):
        font_path = "/usr/share/fonts/truetype/ubuntu/UbuntuSans[wdth,wght].ttf"
        
    font_size = int(super_size * 0.58)
    font = ImageFont.truetype(font_path, font_size)
    text = "D"
    
    # Measure text bounding box
    bbox = draw.textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    
    # Optical center shift slightly right (+1.5% of canvas) to compensate for left stem weight
    x = (super_size - tw) // 2 - bbox[0] + int(super_size * 0.015)
    y = (super_size - th) // 2 - bbox[1]
    
    # Draw pure white "D" with black counter
    draw.text((x, y), text, font=font, fill=(255, 255, 255, 255))
    
    # Downsample with Lanczos for ultra-crisp antialiasing
    icon_1024 = img.resize((target_size, target_size), Image.Resampling.LANCZOS)
    
    output_dir = "IslamicCompanion/Resources/Assets.xcassets/AppIcon.appiconset"
    os.makedirs(output_dir, exist_ok=True)
    
    # Master 1024x1024 icon
    master_path = os.path.join(output_dir, "AppIcon-1024.png")
    icon_1024.save(master_path, "PNG")
    print(f"Saved master icon: {master_path}")
    
    # Required iOS Icon Sizes
    sizes = [
        ("AppIcon-20@2x.png", 40),
        ("AppIcon-20@3x.png", 60),
        ("AppIcon-29@2x.png", 58),
        ("AppIcon-29@3x.png", 87),
        ("AppIcon-40@2x.png", 80),
        ("AppIcon-40@3x.png", 120),
        ("AppIcon-60@2x.png", 120),
        ("AppIcon-60@3x.png", 180),
        ("AppIcon-76.png", 76),
        ("AppIcon-76@2x.png", 152),
        ("AppIcon-83.5@2x.png", 167),
        ("AppIcon-1024.png", 1024)
    ]
    
    for filename, sz in sizes:
        p = os.path.join(output_dir, filename)
        resized = icon_1024.resize((sz, sz), Image.Resampling.LANCZOS)
        resized.save(p, "PNG")
        
    # Contents.json for AppIcon.appiconset
    contents = {
        "images": [
            {
                "filename": "AppIcon-1024.png",
                "idiom": "universal",
                "platform": "ios",
                "size": "1024x1024"
            },
            {
                "filename": "AppIcon-20@2x.png",
                "idiom": "iphone",
                "scale": "2x",
                "size": "20x20"
            },
            {
                "filename": "AppIcon-20@3x.png",
                "idiom": "iphone",
                "scale": "3x",
                "size": "20x20"
            },
            {
                "filename": "AppIcon-29@2x.png",
                "idiom": "iphone",
                "scale": "2x",
                "size": "29x29"
            },
            {
                "filename": "AppIcon-29@3x.png",
                "idiom": "iphone",
                "scale": "3x",
                "size": "29x29"
            },
            {
                "filename": "AppIcon-40@2x.png",
                "idiom": "iphone",
                "scale": "2x",
                "size": "40x40"
            },
            {
                "filename": "AppIcon-40@3x.png",
                "idiom": "iphone",
                "scale": "3x",
                "size": "40x40"
            },
            {
                "filename": "AppIcon-60@2x.png",
                "idiom": "iphone",
                "scale": "2x",
                "size": "60x60"
            },
            {
                "filename": "AppIcon-60@3x.png",
                "idiom": "iphone",
                "scale": "3x",
                "size": "60x60"
            }
        ],
        "info": {
            "author": "xcode",
            "version": 1
        }
    }
    
    with open(os.path.join(output_dir, "Contents.json"), "w") as f:
        json.dump(contents, f, indent=2)
        
    # Root Assets.xcassets Contents.json
    root_contents = {
        "info": {
            "author": "xcode",
            "version": 1
        }
    }
    with open("IslamicCompanion/Resources/Assets.xcassets/Contents.json", "w") as f:
        json.dump(root_contents, f, indent=2)

    # LaunchScreenBackground.colorset
    launch_color_dir = "IslamicCompanion/Resources/Assets.xcassets/LaunchScreenBackground.colorset"
    os.makedirs(launch_color_dir, exist_ok=True)
    launch_color_contents = {
        "colors": [
            {
                "color": {
                    "color-space": "srgb",
                    "components": {
                        "alpha": "1.000",
                        "blue": "0.075",
                        "green": "0.078",
                        "red": "0.067"
                    }
                },
                "idiom": "universal"
            }
        ],
        "info": {
            "author": "xcode",
            "version": 1
        }
    }
    with open(os.path.join(launch_color_dir, "Contents.json"), "w") as f:
        json.dump(launch_color_contents, f, indent=2)
        
    # Also update docs landing page icon
    icon_1024.save("docs/appicon.png", "PNG")
    print("All AppIcon and Asset catalog assets generated successfully!")

if __name__ == "__main__":
    generate_icons()
