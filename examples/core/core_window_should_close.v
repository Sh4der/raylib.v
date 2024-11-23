/*******************************************************************************************
*
*   raylib [core] example - Window should close
*
*   Example originally created with raylib 4.2, last time updated with raylib 4.2
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2013-2024 Ramon Santamaria (@raysan5)
*
********************************************************************************************/


import raylibv as r

const screen_width = 800
const screen_height = 450

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------

fn main() {

	// Initialization
	//--------------------------------------------------------------------------------------
	r.init_window(screen_width, screen_height, 'raylib [core] example - window should close'.str)

	r.set_exit_key(r.key_null) // Disable KEY_ESCAPE to close window, X-button still works

	mut exit_window_requested := false // Flag to request window to exit
	mut exit_window := false // Flag to set window to exit

	r.set_target_fps(60) // Set our game to run at 60 frames-per-second

	// Main game loop
	for !exit_window {
		// Update
		//----------------------------------------------------------------------------------
		// Detect if X-button or KEY_ESCAPE have been pressed to close window
		if r.window_should_close() || r.is_key_pressed(r.key_escape) {
			exit_window_requested = true
		}

		if exit_window_requested {
			// A request for close window has been issued, we can save data before closing
            // or just show a message asking for confirmation
			if r.is_key_down(r.key_y) {
				exit_window = true
			}
			else if r.is_key_down(r.key_n) {
				exit_window_requested = false
			}
		}
		//----------------------------------------------------------------------------------

		// Draw
		//----------------------------------------------------------------------------------
		r.begin_drawing()

			r.clear_background(r.raywhite)

				if exit_window_requested {
					r.draw_rectangle(0, 100, screen_width, 200, r.black)
					r.draw_text("Are you sure you want to exit program? [Y/N]".str, 40, 180, 30, r.white)
				}
				else {
					r.draw_text("Try to close the window to get confirmation message!".str, 120, 200, 20, r.lightgray)
				}

		r.end_drawing()


	}
}
