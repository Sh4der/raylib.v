/*******************************************************************************************
*
*   raylib [core] examples - basic screen manager
*
*   NOTE: This example illustrates a very simple screen manager based on a states machines
*
*   Example originally created with raylib 4.0, last time updated with raylib 4.0
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2021-2024 Ramon Santamaria (@raysan5)
*
********************************************************************************************/

import raylibv as r

const screen_width = 800
const screen_height = 450

//------------------------------------------------------------------------------------------
// Types and Structures Definition
//------------------------------------------------------------------------------------------
enum GameScreen {
	logo = 0
	title
	gameplay
	ending
}

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
fn main()
{
	// Initialization
    //--------------------------------------------------------------------------------------
    r.init_window(screen_width, screen_height, 'raylib [core] example - basic screen manager'.str)

	mut current_screen := GameScreen.logo

	// TODO: Initialize all required variables and load all required data here!

	mut frames_counter := 0    // Useful to count frames

	r.set_target_fps(60)    // Set our game to run at 60 frames-per-second
	//--------------------------------------------------------------------------------------

	// Main game loop
	for !r.window_should_close()    // Detect window close button or ESC key
	{
		// Update
        //----------------------------------------------------------------------------------
        match current_screen {
			.logo {
				// Update logo screen data here!
				frames_counter += 1 // Count frames

				// Wait for 2 seconds (120 frames) before jumping to title screen
				if frames_counter > 120
				{
					current_screen = GameScreen.title
				}
			}
			.title
			{
				// TODO: Update title screen data here!

				// Press enter to change to gameplay screen
				if r.is_key_pressed(r.key_enter) || r.is_gesture_detected(r.gesture_tap)
				{
					current_screen = GameScreen.gameplay
				}
			}
			.gameplay
			{
				// TODO: Update gameplay screen variables here!

				// Press enter to change to ending screen
				if r.is_key_pressed(r.key_enter) || r.is_gesture_detected(r.gesture_tap)
				{
					current_screen = GameScreen.ending
				}
			}
			.ending
			{
				// TODO: Update ending screen variables here!

				// Press enter to return to title screen
				if r.is_key_pressed(r.key_enter) || r.is_gesture_detected(r.gesture_tap)
				{
					current_screen = GameScreen.title
				}
			}
		}
		//----------------------------------------------------------------------------------

		// Draw
		//----------------------------------------------------------------------------------
		r.begin_drawing()
			r.clear_background(r.raywhite)

			match current_screen
			{
				.logo
				{
					// TODO: Draw logo screen here!
					r.draw_text('logo SCREEN'.str, 20, 20, 40, r.lightgray)
					r.draw_text('WAIT for 2 SECONDS...'.str, 290, 220, 20, r.gray)
				}
				.title
				{
					// TODO: Draw title screen here!
					r.draw_rectangle(0, 0, screen_width, screen_height, r.green)
					r.draw_text('title SCREEN'.str, 20, 20, 40, r.darkgreen)
					r.draw_text('PRESS ENTER to JUMP to gameplay SCREEN'.str, 120, 220, 20, r.darkgreen)
				}
				.gameplay
				{
					r.draw_rectangle(0, 0, screen_width, screen_height, r.purple)
					r.draw_text('gameplay SCREEN'.str, 20, 20, 40, r.maroon)
					r.draw_text('PRESS ENTER to JUMP to ending SCREEN'.str, 120, 220, 20, r.maroon)
				}
				.ending
				{
					r.draw_rectangle(0, 0, screen_width, screen_height, r.blue)
					r.draw_text('ending SCREEN'.str, 20, 20, 40, r.darkblue)
					r.draw_text('PRESS ENTER to RETURN to title SCREEN'.str, 120, 220, 20, r.darkblue)
				}
			}
		r.end_drawing()
		//----------------------------------------------------------------------------------
	}

	// De-Initialization
	//--------------------------------------------------------------------------------------
	r.close_window()        // Close window and OpenGL context
	//--------------------------------------------------------------------------------------
}