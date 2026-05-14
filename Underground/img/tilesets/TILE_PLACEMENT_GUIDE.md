# Tile Placement Guide

When choosing tiles from an RPG Maker tileset, treat visually connected tiles as one object instead of standalone items.

## Composite Objects

- If neighboring tiles in the tileset visually continue one object, group them together.
- Shared outlines, cushions, wood trim, shadows, perspective, or object silhouettes usually mean the tiles are companions.
- Never place only the first or upper-left tile of a composite object unless the map intentionally needs a broken fragment.

## Full Footprints

- Determine the object footprint before placement, such as 2x2, 2x3, or 4x2.
- Place every required tile in the correct relative position.
- Preserve the same adjacency and orientation shown in the source tileset.

## Castle Sofa Example

- The castle sofa is an 8-tile composite object.
- Always place all 8 sofa tiles together in the correct order.
- Do not place only the top-left sofa tile as if it were standalone furniture.

## Completeness Check

Before finalizing furniture or object placement:

- Confirm every required companion tile is included.
- If companion tiles are missing, add them in their proper positions.
- If the full footprint is uncertain, choose a clearly standalone tile instead.

One-line rule: never place a tile that is part of a multi-tile object without placing all companion tiles in the correct footprint and order.
