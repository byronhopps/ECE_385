#include "tankGame.h"
#include "system.h"
#include <unistd.h>
#include <assert.h>

#define TankControlReg  (volatile int*) 0x080
#define GameControlReg  (volatile int*) 0x0E0
#define GameStatusReg   (volatile int*) 0x0F0
#define TerrainSpawnPos (volatile int*) 0x100
#define TerrainSpawnRad (volatile int*) 0x130
#define TerrainIDreg    (volatile int*) 0x110
#define Tank0SpawnPos   (volatile int*) 0x140
#define Tank1SpawnPos   (volatile int*) 0x150

static enum GameStatus gameState = INIT;
static unsigned int    gameLevel = 0;
static unsigned int    gameScore[2] = {0};

void processGameState(int keycode[6], int modifierKeys)
{
    switch (gameState) {
        case INIT:
            processInitState(keycode, modifierKeys);
            break;

        case RUN:
            processRunState(keycode, modifierKeys);
            break;

        case GAME_OVER:
            processGameOverState(keycode, modifierKeys);
            break;

        case PAUSE:
            // If execution has returned here, the keyboard has been inserted again
            *GameControlReg &= ~0x0100;
            gameState = RUN;
            processRunState(keycode, modifierKeys);
            break;
    }

    return;
}

void processRunState(int keycode[6], int modifierKeys)
{

    int gameStatus = *GameStatusReg;
    int tankStatus = gameStatus & 0x0003;

    // Both tanks already exist, so process keyboard input and return
    if (tankStatus == 0x0003) {
        setTankControls(keycode);
        return;
    }

    // If any tanks have been killed
    if (tankStatus != 0x0003) {

        // Pause the game
        *GameControlReg |= 0x0100;
        gameState = GAME_OVER;

        // Increment the score of the winning tank
        switch (tankStatus) {
            case 0x1: // Tank 0 won the game
                gameScore[0] += 1;
                *GameControlReg |=  0x0010;
                *GameControlReg &= ~0x0010;
                break;

            case 0x2: // Tank 1 won the game
                gameScore[1] += 1;
                *GameControlReg |=  0x0040;
                *GameControlReg &= ~0x0040;
                break;

            case 0x3: // Both tanks tied
                gameScore[0] += 1;
                gameScore[1] += 1;
                *GameControlReg |=  0x0050;
                *GameControlReg &= ~0x0050;
                break;
        }

        // Wait for 500ms, then resume checking keyboard input
        // State will change back to RUN when any key is pressed
        usleep(500000);
        return;
    }
}

void processInitState(int keycode[6], int modifierKeys)
{
    // Resets the score counters to zero
    *GameControlReg |=  0x00F0;
    *GameControlReg &= ~0x00F0;

    // Load level 0
    gameLevel = 0;
    loadLevel(gameLevel);

    // Start running the game (if not already running)
    *GameControlReg &= ~0x0100;
    gameState = RUN;

    // Spawn tanks, let the games begin!
    *GameControlReg |=  0x0001;
    usleep(20000);
    *GameControlReg &= ~0x0001;

    return;
}


void processGameOverState(int keycode[6], int modifierKeys)
{

    int keyPressed = 0;

    // Check for pressed key (errors don't count!)
    for (int i = 0; i < 6; i++) {
        if (keycode[i] > 3) {
            keyPressed = 1;
            break;
        }
    }

    // Check for pressed modifier key
    if (modifierKeys != 0) {
        keyPressed = 1;
    }

    // If no key pressed, check again for keyboard input
    if (keyPressed == 0) {
        return;
    }

    // Key was pressed, so setup for the next game

    // Load next game level
    loadLevel(++gameLevel);

    // Unpause game
    *GameControlReg &= ~0x0100;
    gameState = RUN;

    // Spawn tanks, let the games begin!
    *GameControlReg |=  0x0001;
    usleep(20000);
    *GameControlReg &= ~0x0001;

    return;
}


void processKeyboardRemoval()
{
    // Pause game until the keyboard has been inserted again
    *GameControlReg |= 0x0100;
    gameState = PAUSE;
}


void setTankControls(int keycode[6])
{

    // Tank 0 move up
    if (matchKeycode(keycode, 26)) {
        *TankControlReg |= 0x4;
    } else {
        *TankControlReg &= ~0x4;
    }

    // Tank 0 move down
    if (matchKeycode(keycode, 22)) {
        *TankControlReg |= 0x2;
    } else {
        *TankControlReg &= ~0x2;
    }

    // Tank 0 move left
    if (matchKeycode(keycode, 4)) {
        *TankControlReg |= 0x8;
    } else {
        *TankControlReg &= ~0x8;
    }

    // Tank 0 move right
    if (matchKeycode(keycode, 7)) {
        *TankControlReg |= 0x1;
    } else {
        *TankControlReg &= ~0x1;
    }

    // Tank 0 shoot
    if (matchKeycode(keycode, 44)) {
        *TankControlReg |= 0x10;
    } else {
        *TankControlReg &= ~0x10;
    }

    //Tank 1 move up
    if (matchKeycode(keycode, 82)) {
        *TankControlReg |= (0x4 << 8);
    } else {
        *TankControlReg &= ~(0x4 << 8);
    }

    //Tank 1 move down
    if (matchKeycode(keycode, 81)) {
        *TankControlReg |= (0x2 << 8);
    } else {
        *TankControlReg &= ~(0x2 << 8);
    }

    //Tank 1 move left
    if (matchKeycode(keycode, 80)) {
        *TankControlReg |= (0x8 << 8);
    } else {
        *TankControlReg &= ~(0x8 << 8);
    }

    //Tank 1 move right
    if (matchKeycode(keycode, 79)) {
        *TankControlReg |= (0x1 << 8);
    } else {
        *TankControlReg &= ~(0x1 << 8);
    }

    //Tank 1 shoot
    if (matchKeycode(keycode, 98)) {
        *TankControlReg |= (0x10 << 8);
    } else {
        *TankControlReg &= ~(0x10 << 8);
    }

    return;
}


// Returns 1 if the specified value is in the keycode array
// Returns 0 otherwise
int matchKeycode (int keycode[6], int value)
{
    for (int i = 0; i < 6; i++) {
        if (keycode[i] == value) {
            return 1;
        }
    }

    return 0;
}

#define NUM_LEVELS 4
#define NUM_JUNGLE 10
#define NUM_WALLS  20
#define NUM_WATER  10
#define NUM_TANKS  2

void loadLevel(int level) {

    level %= NUM_LEVELS;

    const struct point tankSpawnPos[NUM_LEVELS][NUM_TANKS] = {
        { { 50, 50}, {590,430} },   // Level 0
        { {100,256}, {500,256} },   // Level 1
        { { 50,430}, {590, 50} },   // Level 2
        { {100,100}, {350,350} }    // Level 3
    };

    const struct area jungleSpawnArea[NUM_LEVELS][NUM_JUNGLE] = {
        { {{300,200}, { 50, 70}} }, // Level 0

        { {{320, 48}, {256, 48}},   // Level 1
          {{320,448}, {256, 32}},
          {{ 32,240}, { 32,240}},
          {{608,240}, { 32,240}},
          {{352,256}, { 64, 96}} },

        { {{104,100}, { 32, 32}},   // Level 2
          {{104,356}, { 32, 32}},
          {{168,228}, { 31,160}},
          {{272,228}, { 23,160}},
          {{384,228}, { 23,160}},
          {{472,164}, { 15, 96}},
          {{535,100}, { 48, 32}},
          {{505,356}, { 48, 32}},
          {{568,292}, { 15, 96}},
          {{328,228}, { 32, 32}} }
    };

    const struct area wallSpawnArea[NUM_LEVELS][NUM_WALLS] = {
        { {{144,104}, {  8, 20}},   // Level 0
          {{336,224}, {  8, 20}},
          {{496,320}, {  8, 20}},
          {{144,320}, {  8, 20}} },

        { {{224,128}, {  8, 12}},   // Level 1
          {{416,128}, {  8, 12}},
          {{576,128}, {  8, 12}},
          {{224,256}, {  8, 12}},
          {{576,256}, {  8, 12}},
          {{224,384}, {  8, 12}},
          {{416,384}, {  8, 12}},
          {{576,384}, {  8, 12}} },

        { {{104,228}, { 32, 32}},   // Level 2
          {{328, 92}, { 32, 24}},
          {{328,364}, { 32, 24}},
          {{520,228}, { 32, 32}} }
    };

    const struct area waterSpawnArea[NUM_LEVELS][NUM_WATER] = {
        { {{520,180}, { 30, 20}},   // Level 0
          {{320,320}, { 40, 25}} },

        { {{176,192}, { 48, 32}},   // Level 1
          {{176,320}, { 48, 32}},
          {{528,192}, { 48, 32}},
          {{528,320}, { 48, 32}} },

        { {{104,164}, { 32, 32}},   // Level 2
          {{104,292}, { 32, 32}},
          {{328,156}, { 32, 40}},
          {{328,300}, { 32, 40}},
          {{535,164}, { 48, 32}},
          {{505,292}, { 48, 32}} }
    };

    const int jungleTilesUsed[NUM_LEVELS] = {1,5,10,0};
    const int waterTilesUsed[NUM_LEVELS]  = {2,4,6,0};
    const int wallTilesUsed[NUM_LEVELS]   = {4,8,4,0};

    // Sanity check to enforce hardware limitations
    assert(jungleTilesUsed[level] <= NUM_JUNGLE);
    assert(waterTilesUsed[level] <= NUM_WATER);
    assert(wallTilesUsed[level] <= NUM_WALLS);

    const int jungleTerrainID[NUM_JUNGLE] = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
    const int waterTerrainID[NUM_WATER]   = {10,11,12,13,14,15,16,17,18,19};
    const int wallTerrainID[NUM_WALLS]    = {20,21,22,23,24,25,26,27,28,29,
                                             30,31,32,33,34,35,36,37,38,39};

    // Despawn all entities and terrain
    *GameControlReg |=  0x000A;
    *GameControlReg &= ~0x000A;

    // Load jungle tiles
    for (int i = 0; i < jungleTilesUsed[level]; i++) {
        loadTerrain(jungleSpawnArea[level][i], jungleTerrainID[i]);
    }

    // Load water tiles
    for (int i = 0; i < waterTilesUsed[level]; i++) {
        loadTerrain(waterSpawnArea[level][i], waterTerrainID[i]);
    }

    // Load wall tiles
    for (int i = 0; i < wallTilesUsed[level]; i++) {
        loadTerrain(wallSpawnArea[level][i], wallTerrainID[i]);
    }

    // Load tanks
        loadTanks(tankSpawnPos[level]);

    return;
}


void loadTerrain(struct area spawnArea, int terrainID)
{
    // Assign spawn position
    *TerrainSpawnPos = (spawnArea.center.x & 0x000003FF)
        | ( (spawnArea.center.y & 0x000003FF) << 16 );

    // Assign spawn radius
    *TerrainSpawnRad = (spawnArea.radius.x & 0x000003FF)
        | ( (spawnArea.radius.y & 0x000003FF) << 16 );

    // Assert terrain ID
    *TerrainIDreg = terrainID;

    // Assert spawn signal
    *GameControlReg |=  0x0004;
    *GameControlReg &= ~0x0004;

    // Change terrain ID to an invalid number
    *TerrainIDreg = 0xFF;

    return;
}

void loadTanks(const struct point spawnPos[2])
{
    // Assign tank 0 spawn position
    *Tank0SpawnPos = (spawnPos[0].x & 0x000003FF)
        | ( (spawnPos[0].y & 0x000003FF) << 16 );

    // Assign tank 1 spawn position
    *Tank1SpawnPos = (spawnPos[1].x & 0x000003FF)
        | ( (spawnPos[1].y & 0x000003FF) << 16 );

    // Assert spawn signal
    *GameControlReg |=  0x0001;
    *GameControlReg &= ~0x0001;

    return;
}
