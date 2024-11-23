/*******************************************************************************************
*
*   raylib [core] example - Generate random values
*
*   Example originally created with raylib 1.1, last time updated with raylib 1.1
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2014-2024 Ramon Santamaria (@raysan5)
*
********************************************************************************************/

import raylibv as r

const screen_width = 800
const screen_height = 450

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
fn main()
{
	// Initialization
    //--------------------------------------------------------------------------------------
    
	r.init_window(screen_width, screen_height, 'raylib [core] example - generate random values'.str)

	// r.set_random_seed(42) // Set a custom random seed if desired, by default: "time(NULL)"

	mut rand_value := r.get_random_value(-8, 5)	// Get a random integer number between -8 and 5 (both included)
	
	mut frames_counter := 0	// Variable used to count frames

	r.set_target_fps(60) // Set our game to run at 60 frames-per-second

	//--------------------------------------------------------------------------------------

	// Main game loop
	for !r.window_should_close()
	{
		// Update
		//----------------------------------------------------------------------------------
		frames_counter += 1

		// Every two seconds (120 frames) a new random value is generated
		if (frames_counter/120)%2 == 1
		{
			rand_value = r.get_random_value(-8, 5)
			frames_counter = 0
		}
		//----------------------------------------------------------------------------------

		// Draw
		//----------------------------------------------------------------------------------
		r.begin_drawing()

			r.clear_background(r.raywhite)

			r.draw_text('Every 2 seconds a new random value is generated:'.str, 130, 100, 20, r.maroon)
			r.draw_text("${rand_value}".str, 360, 180, 80, r.lightgray)

		r.end_drawing()
		//----------------------------------------------------------------------------------
	}

	// De-Initialization
	//--------------------------------------------------------------------------------------
	r.close_window() // Close window and OpenGL context
	//--------------------------------------------------------------------------------------


}
