# Save The Baby - Game Implementation Plan

## Story Flow

### Act 1: The Kidnapping (Overview Scene)

- **Scene**: overview.png fades in with dangerous sounds
- **Story**: Victor has kidnapped Ethan (baby)
- **Next**: Transition to Amara's appeal scene

### Act 2: Amara's Plea (Main Story Scene)

- **Image**: badge.png (Amara)
- **Text**: Amara begs David to save Ethan
- **Victor's Demand**: "All your wealth should be transferred to me or you lose the baby"
- **David's Choices**:
  1. **Call Police** → Police Station Scene → Level Track 1 (50 levels)
  2. **Trace Signal** → Tech Specialist Scene → Level Track 2 (50 levels)
  3. **Go Alone** → David Solo Scene → Level Track 3 (50 levels)

---

## Level Structure (Per Choice Track)

Each track has **50+ levels** with progressive difficulty. Each level must reach **100% progress bar** before advancing (not move-based).

### Track 1: Call Police (Police Station Investigation)

- **Scenes**:
  - police-station.png: Detective says "We need evidence"
  - Levels 1-50: Collect evidence (phone records, fingerprints, witness statements)
  - Final Scene: "We found the key to Victor's factory location"
- **Level Progression**:
  - Levels 1-10: Easy difficulty
  - Levels 11-30: Medium difficulty
  - Levels 31-50: Hard difficulty

### Track 2: Trace Signal (Phone Hacking)

- **Scenes**:
  - phone.png + recorder.png: Tech specialist says "Decrypt communication data"
  - Levels 1-50: Match signal patterns and decrypt data
  - Final Scene: "Signal traced! Factory location discovered"
- **Level Progression**: Similar difficulty curve

### Track 3: Go Alone (Factory Traps)

- **Scenes**:
  - david.png: "I'm going alone"
  - Levels 1-50: Navigate bombs, chains, locked doors, traps
  - Encounters missles, pinchers, pliers (tools), tape, thunder-bolts
  - **Lives System**:
    - Start with 5 lives
    - Each failed level costs 1 life
    - After 5 lives exhausted: Wait 20 minutes OR watch ad to play
    - After 20 min privilege used: Wait 24 hours for 5 more lives (or watch ads)

---

## Victory Condition

After completing 50 levels in any track:

- **Victory Scene**: David receives key pieces (minimum 10 keys)
- **Next Act**: Factory rescue with remaining puzzles
- **Final Boss**: Confront Victor, rescue Ethan

---

## Asset Mapping

| Asset              | Purpose                                |
| ------------------ | -------------------------------------- |
| overview.png       | Opening scene - Victor kidnaps Ethan   |
| badge.png          | Amara (placeholder - needs real image) |
| kidnapping.png     | Story illustration                     |
| police.png         | Police officer                         |
| police-station.png | Police station setting                 |
| detective.png      | Detective                              |
| david.png          | David (protagonist)                    |
| Victor.png         | Victor (antagonist)                    |
| etan.png           | Ethan (baby)                           |
| phone.png          | Phone/communication                    |
| key.png            | Evidence/puzzle piece                  |
| bomb.png           | Obstacle tile                          |
| chain.png          | Obstacle tile                          |
| clock.png          | Timer/special tile                     |
| finger-print.png   | Evidence tile                          |
| missile.png        | Trap/obstacle                          |
| locked.png         | Locked door tile                       |
| opened.png         | Unlocked state                         |
| pincher.png        | Trap/tool                              |
| plier.png          | Tool/obstacle                          |
| recorder.png       | Recording/evidence                     |
| tape.png           | Evidence/obstacle                      |
| thunder-bolt.png   | Power/special effect                   |

---

## UI/Layout Issues to Fix

### Current Problems:

- Game window too tall for portrait (overflow)
- Game window may be too wide
- Text/buttons cut off or too small
- Images not displaying correctly
- Progress bar not visible

### Solution:

- **Target Window Size**: 480×854 (standard Android 9:16 aspect ratio)
- **Safe Area**: 460×800 (20px margins)
- **Max Content Height**: 780px (accounting for status bar)

### Scene Layout Structure:

```
Portrait Mode (480×854):
┌─────────────────────────┐
│      Header (100px)     │  <- Title, scene name
├─────────────────────────┤
│      Image (200px)      │  <- Character/scene image
├─────────────────────────┤
│  Story Text (250px)     │  <- Scrollable text area
├─────────────────────────┤
│ Choices Area (150px)    │  <- Buttons with padding
├─────────────────────────┤
│ Progress Bar (40px)     │  <- Progress bar at bottom
└─────────────────────────┘
```

---

## Implementation Steps

1. **Fix window dimensions** to 480×854
2. **Create master story.json** with 50+ scenes per track
3. **Create master levels.json** with 50+ levels per track
4. **Fix MainMenu layout** - reduce font sizes, better spacing
5. **Create StoryScene** - proper image display, scrollable text
6. **Create LevelScene** - progress bar system (0-100%), not move-based
7. **Implement lives system** - for Go Alone track
8. **Create victory scenes** - for each track completion
9. **Add sound effects** - especially for opening scene
10. **Add animations** - fade-ins, transitions

---

## Next Steps

- Update all scene files with proper layout
- Generate complete story/levels JSON files
- Implement progress bar mechanics
- Add lives system UI
