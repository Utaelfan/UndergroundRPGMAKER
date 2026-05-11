# LUD Tileset Build Report

Generated from `Underground/img/tilesets/LUD FREE ASSETS`.

## Summary

- Target tile size: 48x48
- Autotile inference: no source images were confidently identified as RPG Maker A1-A4 autotile templates.
- Ambiguous assets were packed into regular B-E sheets as requested.

## Output Sheets

- `LUD_B.png` (768x768, 256 tiles): reused existing identical file; sources: !$SFlvlDoor.png, !$SFlvlDoor2.png, BDR001.png, BDR002.png, BDR003.png
- `LUD_C.png` (768x768, 256 tiles): reused existing identical file; sources: BDR003.png, Christmas.png, Forest RTP Clutter Edit.png, Fort.png, H001.png, Icons - Not Sized.png, K001.png, Mining Ores.png, Notice Board.png, Pack 1.png
- `LUD_D.png` (768x768, 256 tiles): reused existing identical file; sources: Pack 1.png, Roman House 1.png, Three Tile Beds.png
- `LUD_E.png` (768x768, 249 tiles): reused existing identical file; sources: Three Tile Beds.png, War Camp 32.32.png, War Camp 42.42.png

## Source Files Processed

- `!$SFlvlDoor.png`: 432x384, mode RGBA, detected/used 48x48 (exact 48px grid from dimensions), normalized tiles 72, packed into `LUD_B.png`
- `!$SFlvlDoor2.png`: 432x384, mode RGBA, detected/used 48x48 (exact 48px grid from dimensions), normalized tiles 72, packed into `LUD_B.png`
- `BDR001.png`: 336x192, mode RGBA, detected/used 48x48 (exact 48px grid from dimensions), normalized tiles 28, packed into `LUD_B.png`
- `BDR002.png`: 384x336, mode RGBA, detected/used 48x48 (exact 48px grid from dimensions), normalized tiles 56, packed into `LUD_B.png`
- `BDR003.png`: 432x240, mode RGBA, detected/used 48x48 (exact 48px grid from dimensions), normalized tiles 45, packed into `LUD_B.png, LUD_C.png`
- `Christmas.png`: 240x96, mode RGBA, detected/used 48x48 (exact 48px grid from dimensions), normalized tiles 10, packed into `LUD_C.png`
- `Forest RTP Clutter Edit.png`: 386x336, mode RGBA, detected/used 48x48 (partial 48px grid; padded transparent edges), normalized tiles 63, packed into `LUD_C.png`
- `Fort.png`: 384x431, mode RGBA, detected/used 48x48 (partial 48px grid; padded transparent edges), normalized tiles 72, packed into `LUD_C.png`
- `H001.png`: 384x288, mode RGBA, detected/used 48x48 (exact 48px grid from dimensions), normalized tiles 48, packed into `LUD_C.png`
- `Icons - Not Sized.png`: 152x144, mode RGBA, detected/used 48x48 (partial 48px grid; padded transparent edges), normalized tiles 12, packed into `LUD_C.png`
- `K001.png`: 192x96, mode RGBA, detected/used 48x48 (exact 48px grid from dimensions), normalized tiles 8, packed into `LUD_C.png`
- `Mining Ores.png`: 192x192, mode RGBA, detected/used 48x48 (exact 48px grid from dimensions), normalized tiles 16, packed into `LUD_C.png`
- `Notice Board.png`: 192x96, mode RGBA, detected/used 48x48 (exact 48px grid from dimensions), normalized tiles 8, packed into `LUD_C.png`
- `Pack 1.png`: 144x96, mode RGBA, detected/used 48x48 (exact 48px grid from dimensions), normalized tiles 6, packed into `LUD_C.png, LUD_D.png`
- `Roman House 1.png`: 256x320, mode RGBA, detected/used 32x32 (exact 32px grid from dimensions), normalized tiles 80, packed into `LUD_D.png`
- `Three Tile Beds.png`: 768x768, mode RGBA, detected/used 48x48 (exact 48px grid from dimensions), normalized tiles 256, packed into `LUD_D.png, LUD_E.png`
- `War Camp 32.32.png`: 544x160, mode RGBA, detected/used 32x32 (filename indicates 32x32), normalized tiles 85, packed into `LUD_E.png`
- `War Camp 42.42.png`: 768x240, mode RGBA, detected/used 48x48 (exact 48px grid from dimensions), normalized tiles 80, packed into `LUD_E.png`

## Skipped Files

- `desktop.ini`: not an image readable by Pillow

## Limitations

- The source pack does not expose RPG Maker A1-A4 autotile structure metadata.
- Images with partial grids were padded with transparent pixels before slicing, preserving visible pixels.
- Source color data was not color-managed or transformed; PNGs were emitted as RGBA with transparency.
