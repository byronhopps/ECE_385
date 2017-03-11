//io_handler.c
#include "io_handler.h"
#include <stdio.h>
#include "alt_types.h"
#include "system.h"

#define otg_hpi_address      (volatile int*)     OTG_HPI_ADDRESS_BASE
#define otg_hpi_data         (volatile int*)     OTG_HPI_DATA_BASE
#define otg_hpi_r            (volatile char*)    OTG_HPI_R_BASE
#define otg_hpi_cs           (volatile char*)    OTG_HPI_CS_BASE //FOR SOME REASON CS BASE BEHAVES WEIRDLY MIGHT HAVE TO SET MANUALLY
#define otg_hpi_w            (volatile char*)    OTG_HPI_W_BASE


void IO_init(void)
{
    *otg_hpi_cs = 1;
    *otg_hpi_r = 1;
    *otg_hpi_w = 1;
    *otg_hpi_address = 0;
    *otg_hpi_data = 0;
}

void IO_write(alt_u8 Address, alt_u16 Data)
{
    // Select the register address and data
    *otg_hpi_address = Address;
    *otg_hpi_data    = Data;

    // Make sure that we're not reading data from the chip 
    *otg_hpi_r = 1;

    // Select the chip and then write the data
    *otg_hpi_cs = 0;
    *otg_hpi_w  = 0;

    // Deassert write and chip select
    *otg_hpi_cs = 1;
    *otg_hpi_w  = 1;
}

alt_u16 IO_read(alt_u8 Address)
{
    alt_u16 temp;

    // Set the address we want to read from
    *otg_hpi_address = Address;

    // Make sure we're not writing data to the chip
    *otg_hpi_w = 1;

    // Select the chip and then read the data
    *otg_hpi_cs = 0;
    *otg_hpi_r   = 0;

    // Read the data from the data lines
    temp = *otg_hpi_data;

    // Deassert write and chip select
    *otg_hpi_cs = 1;
    *otg_hpi_r   = 1;

    //printf("%x\n",temp);

    return temp;
}
