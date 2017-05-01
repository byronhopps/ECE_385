#include "tankGame.h"
#include "system.h"

#define TankControlReg (volatile int*) 0x80

void setTankControls(int keycode[6]) {
    
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
int matchKeycode (int keycode[6], int value) {
    int i;
    for (i = 0; i < 6; i++) {
        if (keycode[i] == value) {
            return 1;
        }
    }

    return 0;
}
