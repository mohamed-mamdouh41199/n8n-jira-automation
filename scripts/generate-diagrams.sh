#!/bin/bash

# Mermaid to Image Converter Script
# Converts .mmd files to PNG/SVG images using mmdc (mermaid-cli)

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${BLUE}  Mermaid Diagram to Image Converter${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo ""

# Check if mmdc is installed
if ! command -v mmdc &> /dev/null; then
    echo -e "${RED}Error: mermaid-cli (mmdc) is not installed${NC}"
    echo ""
    echo -e "${YELLOW}To install, run:${NC}"
    echo "  npm install -g @mermaid-js/mermaid-cli"
    echo ""
    echo "Or using Docker:"
    echo "  docker pull minlag/mermaid-cli"
    echo ""
    exit 1
fi

# Configuration
DIAGRAM_DIR="./diagrams"
OUTPUT_DIR="./diagrams/images"
FORMAT="${1:-png}" # Default to PNG, or use first argument (png/svg/pdf)

# Validate format
if [[ ! "$FORMAT" =~ ^(png|svg|pdf)$ ]]; then
    echo -e "${RED}Error: Invalid format '$FORMAT'${NC}"
    echo "Usage: $0 [png|svg|pdf]"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo -e "${YELLOW}Configuration:${NC}"
echo "  Input directory:  $DIAGRAM_DIR"
echo "  Output directory: $OUTPUT_DIR"
echo "  Output format:    $FORMAT"
echo ""

# Find all .mmd files
MMD_FILES=$(find "$DIAGRAM_DIR" -maxdepth 1 -name "*.mmd" 2>/dev/null)

if [ -z "$MMD_FILES" ]; then
    echo -e "${RED}No .mmd files found in $DIAGRAM_DIR${NC}"
    exit 1
fi

# Count files
TOTAL=$(echo "$MMD_FILES" | wc -l | tr -d ' ')
CURRENT=0
SUCCESS=0
FAILED=0

echo -e "${YELLOW}Found $TOTAL diagram(s) to convert${NC}"
echo ""

# Convert each file
while IFS= read -r mmd_file; do
    CURRENT=$((CURRENT + 1))
    filename=$(basename "$mmd_file" .mmd)
    output_file="$OUTPUT_DIR/${filename}.$FORMAT"
    
    echo -e "${BLUE}[$CURRENT/$TOTAL]${NC} Converting: ${filename}.mmd"
    
    # Convert with mmdc
    if mmdc -i "$mmd_file" -o "$output_file" -b transparent 2>/dev/null; then
        SUCCESS=$((SUCCESS + 1))
        filesize=$(du -h "$output_file" | cut -f1)
        echo -e "  ${GREEN}✓${NC} Created: ${output_file} (${filesize})"
    else
        FAILED=$((FAILED + 1))
        echo -e "  ${RED}✗${NC} Failed to convert: ${filename}.mmd"
    fi
    echo ""
done <<< "$MMD_FILES"

# Summary
echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${BLUE}  Conversion Summary${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo -e "  Total files:     $TOTAL"
echo -e "  ${GREEN}Successful:      $SUCCESS${NC}"
if [ $FAILED -gt 0 ]; then
    echo -e "  ${RED}Failed:          $FAILED${NC}"
fi
echo ""

if [ $SUCCESS -gt 0 ]; then
    echo -e "${GREEN}✓ Images saved to: $OUTPUT_DIR${NC}"
    echo ""
    echo "Generated files:"
    ls -lh "$OUTPUT_DIR"/*.$FORMAT 2>/dev/null | awk '{print "  - "$9" ("$5")"}'
fi

echo ""
echo -e "${YELLOW}Tip: Add images to README with:${NC}"
echo '  ![Diagram Name](diagrams/images/filename.png)'
echo ""
