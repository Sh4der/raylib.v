/*******************************************************************************************
*
*   raylib [core] example - 2d camera split screen
*
*   Addapted from the core_3d_camera_split_screen example: 
*       https://github.com/raysan5/raylib/blob/master/examples/core/core_3d_camera_split_screen.c
*
*   Example originally created with raylib 4.5, last time updated with raylib 4.5
*
*   Example contributed by Gabriel dos Santos Sanches (@gabrielssanches) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2023 Gabriel dos Santos Sanches (@gabrielssanches)
*
********************************************************************************************/

import raylibv as r

const screen_width = 800
const screen_height = 440
const player_size = 40

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
fn main() {
	// Initialization
    //--------------------------------------------------------------------------------------
    r.init_window(screen_width, screen_height, 'raylib [core] example - 2d camera split screen'.str)

	mut player1 := r.Rectangle{
		x:      200
		y:      200
		width:  player_size
		height: player_size
	}
	mut player2 := r.Rectangle{
		x:      250
		y:      200
		width:  player_size
		height: player_size
	}

	mut camera1 := r.Camera2D{
		target:   r.Vector2{player1.x, player1.y}
		offset:   r.Vector2{200, 200}
		rotation: 0.0
		zoom:     1.0
	}
	mut camera2 := r.Camera2D{
		target:   r.Vector2{player2.x, player2.y}
		offset:   r.Vector2{200, 200}
		rotation: 0.0
		zoom:     1.0
	}

	screen_camera1 := r.load_render_texture(screen_width / 2, screen_height)
	screen_camera2 := r.load_render_texture(screen_width / 2, screen_height)

	split_screen_rect := r.Rectangle{
		x:      0
		y:      0
		width:  screen_camera1.texture.width
		height: -screen_camera1.texture.height
	}
	
	r.set_target_fps(60)

	for !r.window_should_close() {
		// Update
		if r.is_key_down(r.key_a) {
			player1.x -= 3.0
		}
		if r.is_key_down(r.key_d) {
			player1.x += 3.0
		}
		if r.is_key_down(r.key_w) {
			player1.y -= 3.0
		}
		if r.is_key_down(r.key_s) {
			player1.y += 3.0
		}

		if r.is_key_down(r.key_left) {
			player2.x -= 3.0
		}
		if r.is_key_down(r.key_right) {
			player2.x += 3.0
		}
		if r.is_key_down(r.key_up) {
			player2.y -= 3.0
		}
		if r.is_key_down(r.key_down) {
			player2.y += 3.0
		}

		camera1.target = r.Vector2{player1.x, player1.y}
		camera2.target = r.Vector2{player2.x, player2.y}

		//----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        r.begin_texture_mode(screen_camera1)
		r.clear_background(r.raywhite)
		r.begin_mode_2d(camera1)

		// Draw full scene with first camera
		for i := 0; i< screen_width/player_size + 1; i++ {
			r.draw_line_v(r.Vector2{f32(i * player_size), 0}, r.Vector2{f32(i * player_size), screen_height}, r.lightgray)
		}
		
		for i := 0; i< screen_height/player_size + 1; i++ {
			r.draw_line_v(r.Vector2{0, f32(i * player_size)}, r.Vector2{screen_width, f32(i * player_size)}, r.lightgray)
		}

		for i := 0; i < screen_width/player_size + 1; i++ {
			for j := 0; j < screen_height/player_size + 1; j++ {
				r.draw_text("${i}, ${j}".str, int(i * player_size + 5), int(j * player_size + 5), 10, r.gray)
			}
		}

		r.draw_rectangle_rec(player2, r.blue)
		r.draw_rectangle_rec(player1, r.red)


		r.end_mode_2d()

		r.draw_rectangle(0, 0, r.get_screen_width()/2, 30, r.fade(r.raywhite, 0.6))
		r.draw_text("PLAYER1: W/A/S/D to move".str, 10, 10, 10, r.maroon)

		r.end_texture_mode()

		r.begin_texture_mode(screen_camera2)
		r.clear_background(r.raywhite)
		r.begin_mode_2d(camera2)

		// Draw full scene with second camera
		for i := 0; i< screen_width/player_size + 1; i++ {
			r.draw_line_v(r.Vector2{f32(i * player_size), 0}, r.Vector2{f32(i * player_size), screen_height}, r.lightgray)
		}

		for i := 0; i< screen_height/player_size + 1; i++ {
			r.draw_line_v(r.Vector2{0, f32(i * player_size)}, r.Vector2{screen_width, f32(i * player_size)}, r.lightgray)
		}

		for i := 0; i < screen_width/player_size + 1; i++ {
			for j := 0; j < screen_height/player_size + 1; j++ {
				r.draw_text("${i}, ${j}".str, int(i * player_size + 5), int(j * player_size + 5), 10, r.gray)
			}
		}

		r.draw_rectangle_rec(player1, r.red)
		r.draw_rectangle_rec(player2, r.blue)

		r.end_mode_2d()

		r.draw_rectangle(r.get_screen_width()/2, 0, r.get_screen_width()/2, 30, r.fade(r.raywhite, 0.6))
		r.draw_text("PLAYER2: Arrow keys to move".str, r.get_screen_width()/2 + 10, 10, 10, r.darkblue)

		r.end_texture_mode()

		// Draw render texture to screen
		r.begin_drawing()
		r.clear_background(r.black)

		r.draw_texture_rec(screen_camera1.texture, split_screen_rect, r.Vector2{0, 0}, r.white)
		r.draw_texture_rec(screen_camera2.texture, split_screen_rect, r.Vector2{r.get_screen_width()/2, 0}, r.white)

		r.draw_rectangle(r.get_screen_width()/2 - 2, 0, 4, r.get_screen_height(), r.lightgray)

		r.end_drawing()
		
	}
	 // De-Initialization
    //--------------------------------------------------------------------------------------
    r.unload_render_texture(screen_camera1)
	r.unload_render_texture(screen_camera2)

	r.close_window()
}