/**
******************************************************************************* 
@file    watchdog.c* 
@author  AES edited by EBU* 
@version V2.0* 
@date    31-Mar-2016* 
@brief   This file provides a set of functions for demonstrating the use of
*          IWDG watchdog timer
*******************************************************************************
******************************************************************************/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "stm32f3xx_hal.h"
#include "stm32f3_discovery.h"

static IWDG_HandleTypeDef hiwdg; // IWDG handle

// Initialize the Watchdog structures etc, only called once
void mes_InitIWDG(uint32_t delay)
{
	hiwdg.Instance = IWDG;
	hiwdg.Init.Prescaler = IWDG_PRESCALER_256; // IWDG prescaler 4, 8, 16, 32, 64, 128, 256
						   // This divides the clock for longer
                                                   // or shorter watchdog timing
	hiwdg.Init.Reload = delay; 		   // The watchdog counts down from this value
	hiwdg.Init.Window = 0x0FFF;		   // Window option is disabled
	
	if (HAL_IWDG_Init(&hiwdg) != HAL_OK)
		printf("IWDG initialization error\n");  // Initialization Error
}

// Start the watchdog, generally would only be called once
void mes_IWDGStart( void )
{
	if (HAL_IWDG_Start(&hiwdg) != HAL_OK)
		printf("IWDG start error\n");  // Start Error
}

// Refresh the watchdog, this must be called before the 
// watchdog timer times out or the board will reset
void mes_IWDGRefresh(void)
{
	if (HAL_IWDG_Refresh(&hiwdg) != HAL_OK)
		printf("IWDG refresh error\n");  // Refresh Error
}
