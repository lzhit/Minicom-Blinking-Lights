/*
 * NAME 	: blinking_lights_hook.c
 * PROJECT	: SENG2010 - Assignment #4
 * PROGRAMMER	: Lidiia Zhitova and Ken Alparslan
 */
#include <stdio.h>
#include <stdint.h>
#include <ctype.h>
#include "common.h"
#include "doggy.h"


int lzTilt(uint32_t delay, uint32_t target);
void win();
void lose(uint32_t target);



// NAME        : a3
// DESCRIPTION : Adds a new command to minicom


void a3(int action)
{

  int fetch_status;


  if(action==CMD_SHORT_HELP) return;
  if(action==CMD_LONG_HELP)
  {
    printf("LED Game\n\nThis command starts the LED game;\n");

    return;
  }

  //retrieve the delay time
  uint32_t delay;
  fetch_status = fetch_uint32_arg(&delay);
  if(fetch_status)
  {
    delay = 500;
  }


  //get the target light
  uint32_t target;
  fetch_status = fetch_uint32_arg(&target);
  if(fetch_status)
  {
    target = 4;
  }


  //get the game_time
  uint32_t game_time;
  fetch_status = fetch_uint32_arg(&game_time);
  if(fetch_status)
  {
    game_time = 30;
  }
  game_time *= 2;

  int counter = 0;   //for counting the game time
  int result = 0;    //for checking the win/lose condition

  while(game_time > counter)
  {
	//call the function and save the return value
	result = lzTilt(delay, target);
	//if the user wins - exit the loop
	if(result == 1) break;
	counter++;
  }

  //call lose() if user did not win
  if (result != 1) lose(target);
}


ADD_CMD("a3", a3, "<delay> <target> <game_time> play blinking lights game")
