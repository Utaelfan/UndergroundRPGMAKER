$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$dataDir = Join-Path $root "Underground\data"
$mapPath = Join-Path $dataDir "Map017.json"
$mapInfosPath = Join-Path $dataDir "MapInfos.json"

$width = 72
$height = 48
$layers = 6

# Conservative SF Outside tile usage:
# - A5 floor/road tiles are used for most visual massing.
# - B-sheet props below are standalone labels from SF_Outside_B.txt.
# - Known composite sprites such as vehicles, food stalls, walls, monuments,
#   fountains, arches, and convenience stores are intentionally avoided.
$tile = @{
    Empty = 0

    # A5 / terrain-floor style ids.
    Dark = 1536
    Grid = 1537
    Concrete = 1554
    Waste = 1552
    MetalFactory = 1553
    Mecha = 1563
    GreenResin = 1585
    Cobble = 1601
    NeonFloor = 1632
    Marble = 1633
    HeritageStone = 1649
    Water = 2048
    RainChannel = 2063

    # Complete 3-tile stair footprint, A5 indices 28-30.
    StairLeft = 1564
    StairCenter = 1565
    StairRight = 1566

    # Standalone B-sheet props.
    NeonMarketSign = 7
    WhiteLine = 32
    TrafficCone = 46
    StreetLightA = 85
    StreetLightB = 86
    DigitalSignA = 115
    DigitalSignB = 122
    PlantA = 136
    PlantB = 137
    PlantC = 138
    VendingMachine = 139
    Atm = 140
    MachineDevice = 153
    NeonTubeA = 160
    Drain = 184
    Manhole = 191
}

function New-Layer {
    param([int]$Fill)
    $arr = New-Object int[] ($width * $height)
    for ($i = 0; $i -lt $arr.Length; $i++) { $arr[$i] = $Fill }
    return ,$arr
}

function Set-Tile {
    param([int[]]$Layer, [int]$X, [int]$Y, [int]$Value)
    if ($X -ge 0 -and $X -lt $width -and $Y -ge 0 -and $Y -lt $height) {
        $Layer[$Y * $width + $X] = $Value
    }
}

function Fill-Rect {
    param([int[]]$Layer, [int]$X1, [int]$Y1, [int]$X2, [int]$Y2, [int]$Value)
    for ($y = $Y1; $y -le $Y2; $y++) {
        for ($x = $X1; $x -le $X2; $x++) {
            Set-Tile $Layer $x $y $Value
        }
    }
}

function Add-Line {
    param([int[]]$Layer, [int]$X1, [int]$Y1, [int]$X2, [int]$Y2, [int]$Value)
    $dx = [Math]::Abs($X2 - $X1)
    $dy = -[Math]::Abs($Y2 - $Y1)
    $sx = if ($X1 -lt $X2) { 1 } else { -1 }
    $sy = if ($Y1 -lt $Y2) { 1 } else { -1 }
    $err = $dx + $dy
    $x = $X1
    $y = $Y1
    while ($true) {
        Set-Tile $Layer $x $y $Value
        if ($x -eq $X2 -and $y -eq $Y2) { break }
        $e2 = 2 * $err
        if ($e2 -ge $dy) { $err += $dy; $x += $sx }
        if ($e2 -le $dx) { $err += $dx; $y += $sy }
    }
}

function Fill-RegionRect {
    param([int[]]$Layer, [int]$X1, [int]$Y1, [int]$X2, [int]$Y2, [int]$Value, [string]$Name)
    for ($y = $Y1; $y -le $Y2; $y++) {
        for ($x = $X1; $x -le $X2; $x++) {
            $idx = $y * $width + $x
            if ($Layer[$idx] -ne 0) {
                throw "Region overlap while painting $Name at ($x,$y): existing $($Layer[$idx]), new $Value"
            }
            $Layer[$idx] = $Value
        }
    }
}

function Add-StairTriplet {
    param([int[]]$Layer, [int]$X, [int]$Y)
    Set-Tile $Layer $X $Y $tile.StairLeft
    Set-Tile $Layer ($X + 1) $Y $tile.StairCenter
    Set-Tile $Layer ($X + 2) $Y $tile.StairRight
}

function New-Event {
    param([int]$Id, [string]$Name, [int]$X, [int]$Y, [string[]]$Comments, [int]$Trigger = 0)
    $list = @()
    foreach ($comment in $Comments) {
        $list += [ordered]@{ code = 108; indent = 0; parameters = @($comment) }
    }
    $list += [ordered]@{ code = 0; indent = 0; parameters = @() }

    return [ordered]@{
        id = $Id
        name = $Name
        note = ""
        pages = @([ordered]@{
            conditions = [ordered]@{
                actorId = 1; actorValid = $false; itemId = 1; itemValid = $false
                selfSwitchCh = "A"; selfSwitchValid = $false
                switch1Id = 1; switch1Valid = $false; switch2Id = 1; switch2Valid = $false
                variableId = 1; variableValid = $false; variableValue = 0
            }
            directionFix = $false
            image = [ordered]@{ tileId = 0; characterName = ""; direction = 2; pattern = 1; characterIndex = 0 }
            list = $list
            moveFrequency = 3
            moveRoute = [ordered]@{ list = @([ordered]@{ code = 0; parameters = @() }); repeat = $true; skippable = $false; wait = $false }
            moveSpeed = 3
            moveType = 0
            priorityType = 0
            stepAnime = $false
            through = $false
            trigger = $Trigger
            walkAnime = $true
        })
        x = $X
        y = $Y
    }
}

$ground = New-Layer $tile.Water
$detail1 = New-Layer 0
$detail2 = New-Layer 0
$detail3 = New-Layer 0
$shadow = New-Layer 0
$region = New-Layer 0

# Peninsular Malaysia mass, East Malaysia mass, and open sea channel.
Fill-Rect $ground 3 4 47 44 $tile.Concrete
Fill-Rect $ground 50 7 69 31 $tile.GreenResin
Fill-Rect $ground 47 0 49 47 $tile.Water
Fill-Rect $ground 2 28 47 31 $tile.RainChannel
Fill-Rect $ground 48 26 69 28 $tile.RainChannel

# Main readable circulation: two spines and clear cross-links.
Fill-Rect $ground 25 5 30 43 $tile.Mecha
Fill-Rect $ground 4 21 47 25 $tile.Mecha
Fill-Rect $ground 31 21 60 24 $tile.Mecha
Fill-Rect $ground 57 9 60 30 $tile.Mecha
Fill-Rect $ground 5 35 45 39 $tile.Mecha

# Non-overlapping district pads.
Fill-Rect $ground 6 6 20 16 $tile.GreenResin
Fill-RegionRect $region 6 6 20 16 3 "government-tech quarter"

Fill-Rect $ground 33 5 45 18 $tile.Grid
Fill-RegionRect $region 33 5 45 18 4 "commercial mega-district"

Fill-Rect $ground 6 18 22 27 $tile.HeritageStone
Fill-RegionRect $region 6 18 22 27 9 "heritage-tech enclave"

Fill-Rect $ground 6 32 23 43 $tile.Cobble
Fill-RegionRect $region 6 32 23 43 5 "residential arcology"

Fill-Rect $ground 33 29 46 43 $tile.MetalFactory
Fill-RegionRect $region 33 29 46 43 6 "industrial automation port"

Fill-Rect $ground 51 9 68 26 $tile.NeonFloor
Fill-RegionRect $region 51 9 68 26 10 "East Malaysia rainforest dome"

Fill-Rect $ground 25 18 32 27 $tile.Marble
Fill-RegionRect $region 25 18 32 27 1 "central safe transit hub"

# Chokepoints are separate connector cells, not district interiors.
Fill-RegionRect $region 23 21 24 24 2 "west hub chokepoint"
Fill-RegionRect $region 33 21 34 24 2 "east hub chokepoint"
Fill-RegionRect $region 48 21 50 24 2 "sea skybridge chokepoint"
Fill-RegionRect $region 30 29 32 31 2 "port customs chokepoint"

# Hidden/service routes are separate edge lanes.
Fill-RegionRect $region 3 28 7 31 7 "flood service tunnel"
Fill-RegionRect $region 65 27 69 31 7 "dome maintenance spine"

# Encounter zones live outside the district blocks.
Fill-RegionRect $region 9 28 18 31 8 "heritage back alley encounter zone"
Fill-RegionRect $region 47 32 53 39 8 "drone yard encounter zone"

# Complete tower footprints: repeated floor tiles, no partial facade sprites.
Fill-Rect $detail1 35 6 38 16 $tile.Grid
Fill-Rect $detail1 40 6 43 16 $tile.Grid
Fill-Rect $detail2 35 6 35 16 $tile.NeonTubeA
Fill-Rect $detail2 38 6 38 16 $tile.NeonTubeA
Fill-Rect $detail2 40 6 40 16 $tile.NeonTubeA
Fill-Rect $detail2 43 6 43 16 $tile.NeonTubeA
Fill-Rect $detail2 38 10 40 11 $tile.WhiteLine

# Complete stair triplets for verticality.
Add-StairTriplet $detail2 24 17
Add-StairTriplet $detail2 31 25
Add-StairTriplet $detail2 54 27
Add-StairTriplet $detail2 17 31

# Standalone signage, terminals, lights, greenery, and service details.
foreach ($p in @(@(8,19),@(12,19),@(16,19),@(20,19))) { Set-Tile $detail2 $p[0] $p[1] $tile.NeonMarketSign }
foreach ($p in @(@(10,24),@(14,24),@(18,24))) { Set-Tile $detail2 $p[0] $p[1] $tile.DigitalSignA }
foreach ($p in @(@(27,20),@(30,20),@(11,10),@(37,21),@(42,35),@(58,14),@(58,22))) { Set-Tile $detail3 $p[0] $p[1] $tile.MachineDevice }
foreach ($p in @(@(27,25),@(29,25),@(14,36),@(43,31),@(59,11))) { Set-Tile $detail3 $p[0] $p[1] $tile.VendingMachine }
foreach ($p in @(@(12,13),@(38,18),@(44,18),@(8,32),@(22,42),@(34,28),@(46,28),@(53,9),@(67,25))) { Set-Tile $detail2 $p[0] $p[1] $tile.StreetLightA }
foreach ($p in @(@(52,12),@(55,16),@(63,12),@(66,18),@(54,24),@(64,24),@(9,33),@(19,40))) { Set-Tile $detail2 $p[0] $p[1] $tile.PlantA }
foreach ($p in @(@(54,13),@(61,10),@(65,15),@(57,23),@(67,23),@(10,40),@(18,34))) { Set-Tile $detail2 $p[0] $p[1] $tile.PlantB }
foreach ($p in @(@(5,29),@(21,29),@(31,30),@(47,34),@(52,34),@(26,7),@(28,42))) { Set-Tile $detail2 $p[0] $p[1] $tile.Drain }
foreach ($p in @(@(27,12),@(29,22),@(38,38),@(15,37))) { Set-Tile $detail2 $p[0] $p[1] $tile.Manhole }
foreach ($p in @(@(32,29),@(32,30),@(48,21),@(49,21),@(23,21),@(24,21))) { Set-Tile $detail2 $p[0] $p[1] $tile.TrafficCone }

# Transit/light routes using line tiles only.
Add-Line $detail1 7 5 44 44 $tile.WhiteLine
Add-Line $detail1 6 44 67 9 $tile.WhiteLine
Fill-Rect $detail1 25 5 25 43 $tile.NeonTubeA
Fill-Rect $detail1 30 5 30 43 $tile.NeonTubeA
Fill-Rect $detail1 51 20 68 20 $tile.NeonTubeA

$events = @($null)
$eventSpecs = @(
    @("FAST TRAVEL - KL Sentral Skybridge", 28, 22, @("Safe transit hub. District routes radiate outward without overlapping region zones.", "Malaysia 2120 navigation anchor: hover-rail, skybridge, and fast-travel unlock.")),
    @("LANDMARK - Twin Cyber Towers", 39, 11, @("KL skyline anchor. Built as two complete 4x11 tower footprints with full light columns and a skybridge band.", "No partial facade or one-tile tower fragment is used.")),
    @("MONUMENT - Crescent Star Plaza", 28, 25, @("Civic plaza for crescent/star-inspired holographic sculpture. Use event graphics/animation here if desired.", "Safe zone region 1, clear walkable staging area.")),
    @("DISTRICT - Government Tech Quarter", 13, 11, @("Standalone government-tech zone, region 3. Clean green-resin/civic floor with terminals and access control.", "Not nested inside any other gameplay zone.")),
    @("DISTRICT - Commercial Mega-District", 39, 17, @("Standalone commercial zone, region 4. Twin towers, signs, street lights, and elevated route access.", "Use for corporate NPCs and neon shop hooks.")),
    @("DISTRICT - Heritage Tech Night Market", 14, 23, @("Standalone heritage-tech zone, region 9. Malay, Chinese, and Indian motifs should be implemented as holographic stalls/sign events.", "No food-stall composite sprites are placed; signage is standalone.")),
    @("DISTRICT - Residential Arcology", 15, 38, @("Standalone residential arcology, region 5. Rooftop garden and rain capture route hooks.", "Good safe social side-quest block.")),
    @("DISTRICT - Industrial Automation Port", 40, 36, @("Standalone smart-port zone, region 6. AI cargo systems, machine terminals, and autonomous ship access.", "No single-tile vehicle/container fragments.")),
    @("EAST MALAYSIA - Rainforest Research Dome", 60, 17, @("Standalone East Malaysia sector, region 10. Sabah/Sarawak rainforest biodome with suspended walkway hooks.", "Plants are standalone B-sheet plant tiles only.")),
    @("CHOKEPOINT - West Hub Gate", 24, 22, @("Connector chokepoint region 2 between night market and central hub.")),
    @("CHOKEPOINT - Commercial Skybridge Gate", 34, 22, @("Connector chokepoint region 2 between central hub and commercial district.")),
    @("CHOKEPOINT - Sea Skybridge Customs", 49, 22, @("Connector chokepoint region 2 over the sea channel to East Malaysia sector.")),
    @("CHOKEPOINT - Port Customs", 31, 30, @("Connector chokepoint region 2 leading into industrial port.")),
    @("HIDDEN ROUTE - Flood Service Tunnel", 5, 30, @("Hidden service route, region 7. Runs along the rainwater channel behind the west districts.")),
    @("HIDDEN ROUTE - Dome Maintenance Spine", 67, 29, @("Hidden service route, region 7. Back edge of the rainforest dome for stealth or treasure.")),
    @("ENCOUNTER ZONE - Heritage Back Alley", 13, 30, @("Encounter zone region 8. Market-adjacent alley, separate from the market district.")),
    @("ENCOUNTER ZONE - Drone Yard", 50, 36, @("Encounter zone region 8. Port-side drone yard outside the port district.")),
    @("INTERACT - Transit Kiosk", 27, 20, @("Standalone machine device tile. Route info and fast-travel menu hook.")),
    @("INTERACT - Quest Board", 10, 24, @("Standalone digital signage tile. Night-market job board and cultural quest hooks.")),
    @("INTERACT - Port Data Terminal", 42, 35, @("Standalone machine device tile. AI port manifest, drone permits, and cargo puzzle hook.")),
    @("INTERACT - Rain Garden Shelter", 58, 14, @("Safe rest/info point inside the East Malaysia dome sector.")),
    @("ATMOSPHERE - Rainy Neon Dusk", 29, 7, @("Atmosphere hook: rainy neon dusk transitioning to vibrant night, with subtle fog and sign flicker.")),
    @("ATMOSPHERE - Drone Lane Light Pattern", 51, 20, @("Animation hook: moving cyan/magenta lane lights over the sea skybridge and dome approach."))
)

$id = 1
foreach ($spec in $eventSpecs) {
    $events += New-Event -Id $id -Name $spec[0] -X $spec[1] -Y $spec[2] -Comments $spec[3]
    $id++
}

$data = @()
foreach ($layer in @($ground, $detail1, $detail2, $detail3, $shadow, $region)) {
    foreach ($value in $layer) { $data += $value }
}

$map = [ordered]@{
    autoplayBgm = $false
    autoplayBgs = $true
    battleback1Name = "Cyberspace"
    battleback2Name = "Town5"
    bgm = [ordered]@{ name = ""; pan = 0; pitch = 100; volume = 90 }
    bgs = [ordered]@{ name = "Rain"; pan = 0; pitch = 85; volume = 45 }
    disableDashing = $false
    displayName = "Malaysia 2120"
    encounterList = @()
    encounterStep = 35
    height = $height
    note = "SF Outside Malaysia 2120 rebuilt with non-overlapping regions and conservative complete-footprint tile use. Regions: 1 safe transit hub, 2 chokepoints, 3 government-tech, 4 commercial mega-district, 5 residential arcology, 6 industrial smart port, 7 hidden service routes, 8 encounter zones, 9 heritage-tech market, 10 East Malaysia rainforest dome."
    parallaxLoopX = $false
    parallaxLoopY = $false
    parallaxName = "BlueSky"
    parallaxShow = $true
    parallaxSx = 0
    parallaxSy = 0
    scrollType = 0
    specifyBattleback = $true
    tilesetId = 5
    width = $width
    data = $data
    events = $events
}

$map | ConvertTo-Json -Depth 100 -Compress | Set-Content -Path $mapPath -Encoding UTF8

$infos = Get-Content $mapInfosPath -Raw | ConvertFrom-Json
$list = @($null)
foreach ($entry in $infos) {
    if ($null -ne $entry -and $entry.id -ne 17) {
        $list += $entry
    }
}
while ($list.Count -le 17) { $list += $null }
$list[17] = [ordered]@{
    id = 17
    expanded = $false
    name = "Malaysia 2120"
    order = 17
    parentId = 0
    scrollX = 1728
    scrollY = 1152
    quick = $false
}
ConvertTo-Json -InputObject $list -Depth 20 | Set-Content -Path $mapInfosPath -Encoding UTF8

Write-Host "Created $mapPath"
Write-Host "Registered Malaysia 2120 in $mapInfosPath"
