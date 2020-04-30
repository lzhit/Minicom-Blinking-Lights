#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "stm32f3xx_hal.h"
#include "stm32f3_discovery.h"

extern IWDG_HandleTypeDef hiwdg;

void mes_InitIWDG(uint32_t);

void mes_IWDGStart( void );
