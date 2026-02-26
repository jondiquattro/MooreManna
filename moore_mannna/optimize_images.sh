#!/bin/bash

# Image optimization script for Moore Manna website
# This script will:
# 1. Create optimized WebP versions of all PNG images
# 2. Compress existing PNG files
# 3. Create a backup of original images

PHOTO_DIR="moore_manna_photos"
BACKUP_DIR="moore_manna_photos_backup"

echo "Starting image optimization..."

# Create backup directory if it doesn't exist
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Creating backup of original images..."
    mkdir -p "$BACKUP_DIR"
    cp -r "$PHOTO_DIR"/* "$BACKUP_DIR"/
    echo "✓ Backup created in $BACKUP_DIR"
fi

# Navigate to photos directory
cd "$PHOTO_DIR" || exit

echo ""
echo "Converting images to WebP format (80% quality)..."

# Convert all PNG files to WebP
for file in *.png; do
    if [ -f "$file" ]; then
        filename="${file%.png}"
        echo "  Processing: $file"

        # Convert to WebP with 80% quality (good balance of size/quality)
        cwebp -q 80 "$file" -o "${filename}.webp" 2>/dev/null

        # Also optimize the original PNG (reduce to max 1200px width)
        convert "$file" -resize "1200x1200>" -quality 85 -strip "temp_${file}" 2>/dev/null
        mv "temp_${file}" "$file"
    fi
done

echo ""
echo "✓ Image optimization complete!"
echo ""
echo "Summary:"
echo "- Original images backed up to: $BACKUP_DIR"
echo "- WebP versions created (80% quality, ~70-90% size reduction)"
echo "- PNG images optimized (max width 1200px, 85% quality)"
echo ""

# Show size comparison
ORIGINAL_SIZE=$(du -sh "../$BACKUP_DIR" | cut -f1)
NEW_SIZE=$(du -sh . | cut -f1)

echo "Directory sizes:"
echo "  Original: $ORIGINAL_SIZE"
echo "  Optimized: $NEW_SIZE"

