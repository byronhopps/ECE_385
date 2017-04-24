typedef enum {UP = 0, DOWN = 1, LEFT = 2, RIGHT = 3} DIRECTION;

typedef enum logic [23:0] {RED_24 = 24'hFF0000, GREEN_24 = 24'h00FF00,
    BLUE_24 = 24'h0000FF} COLOR_24;

typedef enum logic [23:0] {RED = 24'hFF0000, GREEN = 24'h00FF00, BLUE = 24'h0000FF,
    BULLET = 24'hFFFFFF, BACKGROUND = 24'h000000,
    TURRET = 24'hAAAAAA, TANK = 24'h555555} COLOR;