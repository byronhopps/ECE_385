typedef enum {UP = 0, DOWN = 1, LEFT = 2, RIGHT = 3} DIRECTION;

typedef enum logic [23:0] {RED_24 = 24'hFF0000, GREEN_24 = 24'h00FF00,
    BLUE_24 = 24'h0000FF} COLOR_24;

typedef enum logic [23:0] {
    BULLET = 24'hFFFFFF, BACKGROUND = 24'h000000,
    JUNGLE = 24'h11FF11,
    TURRET = 24'hAAAAAA, TANK = 24'h555555,
    TURRET_0 = 24'hFF0000, TANK_0 = 24'h885555,
    TURRET_1 = 24'h00FF00, TANK_1 = 24'h558855,
    TURRET_2 = 24'h0000FF, TANK_2 = 24'h555588,
    TURRET_3 = 24'h00FFFF, TANK_3 = 24'h558888
} COLOR;

typedef struct {
    logic [9:0] x;
    logic [9:0] y;
} POSITION;

typedef struct {
    logic [8:0] x;
    logic [8:0] y;
} RADIUS;

typedef struct {
    POSITION center;
    RADIUS radius;
} RECT;
