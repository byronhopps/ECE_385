void setTankControls(int keycode[6]);
int matchKeycode (int keycode[6], int value);

void processRunState(int keycode[6], int modifierKeys);
void processGameState(int keycode[6], int modifierKeys);
void processInitState(int keycode[6], int modifierKeys);
void processGameOverState(int keycode[6], int modifierKeys);
void processKeyboardRemoval();

enum GameStatus {INIT, RUN, GAME_OVER, PAUSE};

struct point {
    int x;
    int y;
};

struct area {
    struct point center;
    struct point radius;
};


void loadLevel(int level);
void loadTerrain(const struct area spawnArea, const int terrainID);
void loadTanks(const struct point spawnPos[2]);
