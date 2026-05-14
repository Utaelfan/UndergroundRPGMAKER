from __future__ import annotations

import math
from dataclasses import dataclass, field
from pathlib import Path
from typing import Iterable

from PIL import Image, UnidentifiedImageError


ROOT = Path(__file__).resolve().parents[1]
TILESET_DIR = ROOT / "Underground" / "img" / "tilesets"
SOURCE_DIR = TILESET_DIR / "LUD FREE ASSETS"
REPORT_PATH = TILESET_DIR / "LUD_tileset_build_report.md"

TARGET_TILE = 48
RPG_SHEET_TILES_W = 16
RPG_SHEET_TILES_H = 16
REGULAR_SHEETS = ["LUD_B.png", "LUD_C.png", "LUD_D.png", "LUD_E.png"]
TILE_CANDIDATES = [16, 24, 32, 48]


@dataclass
class SourceInfo:
    path: Path
    size: tuple[int, int]
    mode: str
    detected_tile: int
    detection_note: str
    normalized_tiles: list[Image.Image] = field(default_factory=list)
    output_sheets: list[str] = field(default_factory=list)
    tile_count: int = 0


@dataclass
class SheetResult:
    requested_name: str
    actual_path: Path
    image: Image.Image
    tile_count: int
    source_names: list[str]
    reused_existing: bool = False


def image_files(root: Path) -> Iterable[Path]:
    for path in sorted(root.rglob("*")):
        if path.is_file():
            yield path


def detect_tile_size(path: Path, size: tuple[int, int]) -> tuple[int, str]:
    width, height = size
    stem = path.stem.lower()

    if "32.32" in stem or "32x32" in stem:
        return 32, "filename indicates 32x32"
    if "48.48" in stem or "48x48" in stem:
        return 48, "filename indicates 48x48"
    if "24.24" in stem or "24x24" in stem:
        return 24, "filename indicates 24x24"
    if "16.16" in stem or "16x16" in stem:
        return 16, "filename indicates 16x16"

    exact = [tile for tile in TILE_CANDIDATES if width % tile == 0 and height % tile == 0]
    if exact:
        # Prefer the largest exact grid because RPG Maker MV/MZ assets are commonly 48 px.
        tile = max(exact)
        return tile, f"exact {tile}px grid from dimensions"

    width_matches = [tile for tile in TILE_CANDIDATES if width % tile == 0]
    height_matches = [tile for tile in TILE_CANDIDATES if height % tile == 0]
    shared = sorted(set(width_matches) | set(height_matches), reverse=True)
    if shared:
        return shared[0], f"partial {shared[0]}px grid; padded transparent edges"

    return TARGET_TILE, "uncertain; defaulted to 48px and padded transparent edges"


def normalize_tiles(image: Image.Image, tile_size: int) -> list[Image.Image]:
    rgba = image.convert("RGBA")
    width, height = rgba.size
    cols = max(1, math.ceil(width / tile_size))
    rows = max(1, math.ceil(height / tile_size))
    padded = Image.new("RGBA", (cols * tile_size, rows * tile_size), (0, 0, 0, 0))
    padded.alpha_composite(rgba, (0, 0))

    tiles: list[Image.Image] = []
    for row in range(rows):
        for col in range(cols):
            crop = padded.crop(
                (
                    col * tile_size,
                    row * tile_size,
                    (col + 1) * tile_size,
                    (row + 1) * tile_size,
                )
            )
            if tile_size != TARGET_TILE:
                crop = crop.resize((TARGET_TILE, TARGET_TILE), Image.Resampling.NEAREST)
            tiles.append(crop)
    return tiles


def equivalent_png(path: Path, generated: Image.Image) -> bool:
    if not path.exists():
        return False
    try:
        with Image.open(path) as existing:
            existing_rgba = existing.convert("RGBA")
            generated_rgba = generated.convert("RGBA")
            return existing_rgba.size == generated_rgba.size and existing_rgba.tobytes() == generated_rgba.tobytes()
    except (OSError, UnidentifiedImageError):
        return False


def choose_output_path(base_path: Path, generated: Image.Image) -> tuple[Path, bool]:
    if not base_path.exists():
        return base_path, False
    if equivalent_png(base_path, generated):
        return base_path, True

    stem = base_path.stem
    suffix = base_path.suffix
    version = 2
    while True:
        candidate = base_path.with_name(f"{stem}_v{version}{suffix}")
        if not candidate.exists():
            return candidate, False
        if equivalent_png(candidate, generated):
            return candidate, True
        version += 1


def pack_regular_sheets(sources: list[SourceInfo]) -> list[SheetResult]:
    capacity = RPG_SHEET_TILES_W * RPG_SHEET_TILES_H
    sheet_results: list[SheetResult] = []
    sheet_index = 0
    cursor = 0
    current = Image.new(
        "RGBA",
        (RPG_SHEET_TILES_W * TARGET_TILE, RPG_SHEET_TILES_H * TARGET_TILE),
        (0, 0, 0, 0),
    )
    current_sources: list[str] = []
    current_count = 0

    def flush() -> None:
        nonlocal current, current_sources, current_count, sheet_index, cursor
        if current_count == 0:
            return
        if sheet_index < len(REGULAR_SHEETS):
            requested_name = REGULAR_SHEETS[sheet_index]
        else:
            requested_name = f"LUD_Extra_{sheet_index - len(REGULAR_SHEETS) + 1}.png"
        output_path, reused = choose_output_path(TILESET_DIR / requested_name, current)
        if not reused:
            current.save(output_path, "PNG")
        sheet_results.append(
            SheetResult(
                requested_name=requested_name,
                actual_path=output_path,
                image=current,
                tile_count=current_count,
                source_names=current_sources.copy(),
                reused_existing=reused,
            )
        )
        sheet_index += 1
        cursor = 0
        current_count = 0
        current_sources = []
        current = Image.new(
            "RGBA",
            (RPG_SHEET_TILES_W * TARGET_TILE, RPG_SHEET_TILES_H * TARGET_TILE),
            (0, 0, 0, 0),
        )

    for source in sources:
        if not source.normalized_tiles:
            continue
        tile_index = 0
        while tile_index < len(source.normalized_tiles):
            if cursor == capacity:
                flush()

            requested_name = (
                REGULAR_SHEETS[sheet_index]
                if sheet_index < len(REGULAR_SHEETS)
                else f"LUD_Extra_{sheet_index - len(REGULAR_SHEETS) + 1}.png"
            )
            if requested_name not in source.output_sheets:
                source.output_sheets.append(requested_name)
            if source.path.name not in current_sources:
                current_sources.append(source.path.name)

            available = capacity - cursor
            take = min(available, len(source.normalized_tiles) - tile_index)
            for tile in source.normalized_tiles[tile_index : tile_index + take]:
                col = cursor % RPG_SHEET_TILES_W
                row = cursor // RPG_SHEET_TILES_W
                current.alpha_composite(tile, (col * TARGET_TILE, row * TARGET_TILE))
                cursor += 1
                current_count += 1
            tile_index += take

    flush()
    return sheet_results


def build_report(
    processed: list[SourceInfo],
    skipped: list[tuple[Path, str]],
    sheets: list[SheetResult],
) -> str:
    lines = [
        "# LUD Tileset Build Report",
        "",
        "Generated from `Underground/img/tilesets/LUD FREE ASSETS`.",
        "",
        "## Summary",
        "",
        f"- Target tile size: {TARGET_TILE}x{TARGET_TILE}",
        "- Autotile inference: no source images were confidently identified as RPG Maker A1-A4 autotile templates.",
        "- Ambiguous assets were packed into regular B-E sheets as requested.",
        "",
        "## Output Sheets",
        "",
    ]
    if sheets:
        for sheet in sheets:
            status = "reused existing identical file" if sheet.reused_existing else "created"
            lines.append(
                f"- `{sheet.actual_path.name}` ({sheet.image.width}x{sheet.image.height}, "
                f"{sheet.tile_count} tiles): {status}; sources: {', '.join(sheet.source_names)}"
            )
    else:
        lines.append("- No output sheets were generated.")

    lines.extend(["", "## Source Files Processed", ""])
    for source in processed:
        lines.append(
            f"- `{source.path.relative_to(SOURCE_DIR)}`: {source.size[0]}x{source.size[1]}, "
            f"mode {source.mode}, detected/used {source.detected_tile}x{source.detected_tile} "
            f"({source.detection_note}), normalized tiles {source.tile_count}, "
            f"packed into `{', '.join(source.output_sheets) or 'none'}`"
        )

    lines.extend(["", "## Skipped Files", ""])
    if skipped:
        for path, reason in skipped:
            try:
                display = path.relative_to(SOURCE_DIR)
            except ValueError:
                display = path
            lines.append(f"- `{display}`: {reason}")
    else:
        lines.append("- None.")

    lines.extend(
        [
            "",
            "## Placement Guidance",
            "",
            "- Treat visually continuous neighboring tiles as composite objects, not standalone tiles.",
            "- When placing furniture or props, place the complete footprint in the same relative order as the source sheet.",
            "- Never place only the first or upper-left tile of a multi-tile object unless a broken fragment is intended.",
            "- Before finalizing map edits, check each furniture or object placement for missing companion tiles.",
            "- If a tile might belong to a composite object and the full footprint is unclear, use a clearly standalone tile instead.",
            "",
            "## Limitations",
            "",
            "- The source pack does not expose RPG Maker A1-A4 autotile structure metadata.",
            "- Images with partial grids were padded with transparent pixels before slicing, preserving visible pixels.",
            "- Source color data was not color-managed or transformed; PNGs were emitted as RGBA with transparency.",
            "",
        ]
    )
    return "\n".join(lines)


def main() -> None:
    if not SOURCE_DIR.exists():
        raise SystemExit(f"Missing source directory: {SOURCE_DIR}")

    processed: list[SourceInfo] = []
    skipped: list[tuple[Path, str]] = []

    for path in image_files(SOURCE_DIR):
        try:
            with Image.open(path) as image:
                detected, note = detect_tile_size(path, image.size)
                source = SourceInfo(path, image.size, image.mode, detected, note)
                source.normalized_tiles = normalize_tiles(image, detected)
                source.tile_count = len(source.normalized_tiles)
                processed.append(source)
        except UnidentifiedImageError:
            skipped.append((path, "not an image readable by Pillow"))
        except OSError as exc:
            skipped.append((path, f"could not read image: {exc}"))

    sheets = pack_regular_sheets(processed)
    REPORT_PATH.write_text(build_report(processed, skipped, sheets), encoding="utf-8")

    print("Created/reused tileset outputs:")
    if sheets:
        for sheet in sheets:
            status = "reused" if sheet.reused_existing else "created"
            print(
                f"- {sheet.actual_path.name}: {sheet.image.width}x{sheet.image.height}, "
                f"{sheet.tile_count} tiles, {status}"
            )
    else:
        print("- none")
    print(f"Report: {REPORT_PATH.name}")


if __name__ == "__main__":
    main()
