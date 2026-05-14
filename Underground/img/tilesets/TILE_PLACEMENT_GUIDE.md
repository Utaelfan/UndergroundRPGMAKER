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

## Map Composition References

Use good RPG Maker maps as references for tile logic, not as layouts to copy.

### Outdoor Settlement With Water Channels

- Water is not a single blue tile path. It uses a complete edge system: inner water, banks, corners, turns, and T-junctions.
- Channels are wide enough to read as geography and narrow enough to shape navigation.
- Fences form complete boundaries with posts, rails, corners, and intentional openings.
- Buildings use full roof/wall/door/shadow footprints. A house is a complete assembly, not one facade tile.
- Market crates, signs, wells, and small props are placed as coherent objects with breathing room around walkable paths.
- Large empty ground areas are acceptable when they improve readability, but they should be broken up by landmarks, water, or boundaries.

### Interior Room

- Walls have full thickness: top wall, side walls, and floor meet cleanly.
- Floors use broad repeated texture, while damaged holes and props are accents rather than noise.
- Beds, counters, stools, tables, meals, and wall damage are placed as full object footprints.
- Shadows clarify vertical surfaces and raised walls.
- Walkable space is obvious: the player can read the room routes, furniture barriers, and interaction points at a glance.

### River, Bridge, And Stone Platform

- Terrain types are separated with complete transition borders: water, grass edge, stone edge, and masonry each have their correct boundary tiles.
- Bridges use their complete structure: deck, supports, edges, and shadows.
- Rivers have consistent width and plausible bends, with banks matching each turn.
- Stone platforms use large contiguous fields with edge treatment instead of scattered individual tiles.
- Decorative details are sparse and intentional, supporting scale without blocking navigation.

## Practical Mapping Rules

- Build from terrain masses first: water, roads, platforms, walls, and district footprints.
- Add transition tiles before decorative props.
- Place complete buildings and objects only after their surrounding walkable space is readable.
- Keep regions and gameplay zones separate unless an overlap is deliberately scripted and documented.
- Use landmarks to orient the player, but keep primary paths wider and cleaner than decorative areas.
- When unsure about a prop footprint, skip it or replace it with a clearly standalone tile.
