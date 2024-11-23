/*******************************************************************************************
*
*   raylib [core] example - Keyboard input
*
*   Example originally created with raylib 1.0, last time updated with raylib 1.0
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

fn main() {

	// Initialization
	//--------------------------------------------------------------------------------------
	r.init_window(screen_width, screen_height, 'raylib [core] example - keyboard input'.str)

	mut ball_position := r.Vector2{ x: screen_width / 2, y: screen_height / 2 }

	r.set_target_fps(60) // Set our game to run at 60 frames-per-second

	for !r.window_should_close(){
		// Update
		//----------------------------------------------------------------------------------
		if r.is_key_down(r.key_right) {
			ball_position.x += 2
		}
		if r.is_key_down(r.key_left) {
			ball_position.x -= 2
		}		
		if r.is_key_down(r.key_up) {
			ball_position.y -= 2
		}
		if r.is_key_down(r.key_down) {
			ball_position.y += 2
		}

		// Draw
		//----------------------------------------------------------------------------------
		r.begin_drawing()
		r.clear_background(r.raywhite)
		r.draw_text('move the ball with arrow keys'.str, 10, 10, 20, r.darkgray)
		r.draw_circle_v(ball_position, 50, r.maroon)
		r.end_drawing()
	}

	// De-Initialization
    //--------------------------------------------------------------------------------------
	r.close_window()
    //--------------------------------------------------------------------------------------

}
