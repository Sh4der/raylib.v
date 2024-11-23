/*******************************************************************************************
*
*   raylib [core] example - Scissor test
*
*   Example originally created with raylib 2.5, last time updated with raylib 3.0
*
*   Example contributed by Chris Dill (@MysteriousSpace) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2019-2024 Chris Dill (@MysteriousSpace)
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
    r.init_window(screen_width, screen_height, 'raylib [core] example - scissor test'.str)

	mut scissor_area := r.Rectangle {0, 0, 300, 300}
	mut scissor_mode := true

	r.set_target_fps(60)	// Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    for !r.window_should_close()
	{
		// Update
        //----------------------------------------------------------------------------------
        if r.is_key_pressed(r.key_s)
		{
			scissor_mode = !scissor_mode
		}

		// Centre the scissor area around the mouse position
		mut mouse_position := r.get_mouse_position()
		scissor_area.x = mouse_position.x - scissor_area.width / 2
		scissor_area.y = mouse_position.y - scissor_area.height / 2
		//----------------------------------------------------------------------------------

		// Draw
		//----------------------------------------------------------------------------------
		r.begin_drawing()

			r.clear_background(r.raywhite)

			if scissor_mode
			{
				r.begin_scissor_mode(int(scissor_area.x), int(scissor_area.y), int(scissor_area.width), int(scissor_area.height))
			}

			r.draw_rectangle(0, 0, screen_width, screen_height, r.red)
			r.draw_text('Move the mouse around to reveal this text!'.str, 190, 200, 20, r.lightgray)

			if scissor_mode
			{
				r.end_scissor_mode()
			}

			r.draw_rectangle_lines_ex(scissor_area, 1, r.black)

			r.draw_text('Press S to toggle scissor test'.str, 10, 10, 20, r.black)

		r.end_drawing()
		//----------------------------------------------------------------------------------
	}

	// De-Initialization
	//--------------------------------------------------------------------------------------
	r.close_window()	// Close window and OpenGL context
	//--------------------------------------------------------------------------------------
		
}

