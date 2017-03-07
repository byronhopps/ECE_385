// Main.c - makes LEDG0 on DE2-115 board blink if NIOS II is set up correctly
// for ECE 385 - University of Illinois - Electrical and Computer Engineering
// Author: Zuofu Cheng

int main()
{
    // Declare pointers to PIO blocks
    volatile unsigned int *LED_PIO = (unsigned int*) 0x50;
    volatile unsigned int *SW_PIO  = (unsigned int*) 0x60;
    volatile unsigned int *BTN_PIO = (unsigned int*) 0x70;

    // Clear LEDs
    *LED_PIO = 0;

    // Declare variables
    unsigned int buttons = 0;
    unsigned int accPrev = 0;
    unsigned int rst = 0;
    unsigned int acc = 0;

    while (0xECE) {

        // Set previous value of acc
        accPrev = acc;

        // Read buttons and update variables
        buttons = *BTN_PIO;
        rst = !((buttons & 0x4) >> 2);
        acc = !((buttons & 0x8) >> 3);

        // Check if the reset button is pressed
        if (rst == 1) {
            *LED_PIO = 0;
            continue;
        }

        // Increment green LEDs if the accumulate button was just released 
        if (acc == 0 && accPrev == 1) {
            *LED_PIO += *SW_PIO;
        }
    }

    return 1;
}
