/*******************************************************************************************
*
*   raylib [core] example - Mouse input
*
*   Example originally created with raylib 1.0, last time updated with raylib 4.0
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
    
	r.init_window(screen_width, screen_height, 'raylib [core] example - mouse input'.str)

	mut ball_position := r.Vector2{-100.0, -100.0}
	mut ball_color := r.darkblue

	r.set_target_fps(60) // Set our game to run at 60 frames-per-second
	//---------------------------------------------------------------------------------------

	// Main game loop
	for !r.window_should_close()
	{
		// Update
		//----------------------------------------------------------------------------------
		ball_position = r.get_mouse_position()
		
		if r.is_mouse_button_down(r.mouse_button_left) {
			ball_color = r.maroon
		} else if r.is_mouse_button_down(r.mouse_button_middle) {
			ball_color = r.lime
		} else if r.is_mouse_button_down(r.mouse_button_right) {
			ball_color = r.darkblue
		} else if r.is_mouse_button_down(r.mouse_button_side) {
			ball_color = r.purple
		} else if r.is_mouse_button_down(r.mouse_button_extra) {
			ball_color = r.yellow
		} else if r.is_mouse_button_down(r.mouse_button_forward) {
			ball_color = r.orange
		} else if r.is_mouse_button_down(r.mouse_button_back) {
			ball_color = r.beige
		}
		//----------------------------------------------------------------------------------

		// Draw
		//----------------------------------------------------------------------------------
		r.begin_drawing()

			r.clear_background(r.raywhite)

			r.draw_circle_v(ball_position, 40.0, ball_color)

			r.draw_text('move ball with mouse and click mouse button to change color'.str, 10, 10, 20, r.darkgray)

		r.end_drawing()
		//----------------------------------------------------------------------------------
	}
}