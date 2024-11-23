/*******************************************************************************************
*
*   raylib [core] examples - Mouse wheel input
*
*   Example originally created with raylib 1.1, last time updated with raylib 1.3
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

	r.init_window(screen_width, screen_height, 'raylib [core] example - input mouse wheel'.str)

	mut box_position_y := screen_height / 2 - 40
	mut scroll_speed := 4 // Scrolling speed in pixels

	r.set_target_fps(60) // Set our game to run at 60 frames-per-second
	//--------------------------------------------------------------------------------------

	// Main game loop
	for !r.window_should_close() {
		// Update
        //----------------------------------------------------------------------------------
		box_position_y -= int(r.get_mouse_wheel_move()) * scroll_speed
		//----------------------------------------------------------------------------------

		// Draw
		//----------------------------------------------------------------------------------
		r.begin_drawing()
		r.clear_background(r.raywhite)

		r.draw_rectangle(screen_width / 2 - 40, box_position_y, 80, 80, r.maroon)

		r.draw_text('Use mouse wheel to move the cube up and down!'.str, 10, 10, 20, r.gray)
		r.draw_text('Box position Y: ${box_position_y}'.str, 10, 40, 20, r.lightgray)

		r.end_drawing()
		//----------------------------------------------------------------------------------
	}

	// De-Initialization
	//--------------------------------------------------------------------------------------
	r.close_window() // Close window and OpenGL context
	//--------------------------------------------------------------------------------------
}