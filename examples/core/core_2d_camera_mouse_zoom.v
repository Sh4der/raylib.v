/*******************************************************************************************
*
*   raylib [core] example - 2d camera mouse zoom
*
*   Example originally created with raylib 4.2, last time updated with raylib 4.2
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2022-2024 Jeffery Myers (@JeffM2501)
*
********************************************************************************************/
import raylibv as r
import math

const screen_width = 800
const screen_height = 450

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
fn main() {
	// Initialization
	//--------------------------------------------------------------------------------------
	r.init_window(screen_width, screen_height, 'raylib [core] example - 2d camera mouse zoom'.str)

	mut camera := r.Camera2D{
		zoom: 1.0
	}

	mut zoom_mode := 0 // 0 = zoom with mouse, 1 = zoom with keys

	r.set_target_fps(60) // Set our game to run at 60 frames-per-second
	//--------------------------------------------------------------------------------------

	// Main game loop
	for !r.window_should_close() {
		// Update
		//----------------------------------------------------------------------------------
		if r.is_key_pressed(r.key_one) {
			zoom_mode = 0
		} else if r.is_key_pressed(r.key_two) {
			zoom_mode = 1
		}

		// Translate based on mouse right click
		if r.is_mouse_button_down(r.mouse_button_left) {
			mut delta := r.get_mouse_delta()
			delta = r.vector2_scale(delta, -1.0 / camera.zoom)
			camera.target = r.vector2_add(camera.target, delta)
		}

		match zoom_mode {
			0 {
				// Zoom based on mouse wheel
				wheel := r.get_mouse_wheel_move()

				if wheel != 0 {
					// Get the world point that is under the mouse
					mouse_world_pos := r.get_screen_to_world_2d(r.get_mouse_position(),
						camera)

					// Set the offset to where the mouse is
					camera.offset = r.get_mouse_position()

					// Set the target to match, so that the camera maps the world space point
					// under the cursor to the screen space point under the cursor at any zoom
					camera.target = mouse_world_pos

					// Zoom increment
					mut scale_factor := 1.0 + (0.25 * math.abs(wheel))
					if wheel < 0 {
						scale_factor = 1.0 / scale_factor
					}
					camera.zoom = r.clamp(camera.zoom * scale_factor, 0.125, 64.0)
				}
			}
			else {
				// Zoom based on mouse right click
				if r.is_mouse_button_pressed(r.mouse_button_right) {
					// Get the world point that is under the mouse
					mouse_world_pos := r.get_screen_to_world_2d(r.get_mouse_position(),
						camera)

					// Set the offset to where the mouse is
					camera.offset = r.get_mouse_position()

					// Set the target to match, so that the camera maps the world space point
					// under the cursor to the screen space point under the cursor at any zoom
					camera.target = mouse_world_pos
				}
				if r.is_mouse_button_down(r.mouse_button_right) {
					// Zoom increment
					delta_x := r.get_mouse_delta().x
					mut scale_factor := 1.0 + (0.01 * math.abs(delta_x))
					if delta_x < 0 {
						scale_factor = 1.0 / scale_factor
					}
					camera.zoom = r.clamp(camera.zoom * scale_factor, 0.125, 64.0)
				}
			}
		}
		// ----------------------------------------------------------------------------------

		// Draw
		//----------------------------------------------------------------------------------
		r.begin_drawing()
		r.clear_background(r.raywhite)

		r.begin_mode_2d(camera)

		// Draw the 3d grid, rotated 90 degrees and centered around 0,0
		// just so we have something in the XY plane
		r.rl_push_matrix()
		r.rl_translatef(0.0, 25 * 50, 0.0)
		r.rl_rotatef(90.0, 1.0, 0.0, 0.0)
		r.draw_grid(100, 50.0)
		r.rl_pop_matrix()

		// Draw a reference circle
		r.draw_circle(r.get_screen_width() / 2, r.get_screen_height() / 2, 50, r.maroon)
		r.end_mode_2d()

		// Draw mouse reference
		// Vector2 mousePos = GetWorldToScreen2D(GetMousePosition(), camera)
		r.draw_circle(r.get_mouse_x(), r.get_mouse_y(), 4, r.darkgreen)
		r.draw_text_ex(r.get_font_default(), '[${r.get_mouse_x()}, ${r.get_mouse_y()}]'.str,
			r.vector2_add(r.get_mouse_position(), r.Vector2{-44, -24}), 20, 2, r.black)

		r.draw_text('[1][2] Select mouse zoom mode (Wheel or Move)'.str, 20, 20, 20, r.darkgray)
		if zoom_mode == 0 {
			r.draw_text('Mouse left button drag to move, mouse wheel to zoom'.str, 20,
				50, 20, r.darkgray)
		} else {
			r.draw_text('Mouse left button drag to move, mouse press and move to zoom'.str,
				20, 50, 20, r.darkgray)
		}
		r.end_drawing()
	}
	// De-Initialization
	//--------------------------------------------------------------------------------------
	r.close_window() // Close window and OpenGL context
	//--------------------------------------------------------------------------------------
}
