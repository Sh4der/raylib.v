/*******************************************************************************************
*
*   raylib [core] example - World to screen
*
*   Example originally created with raylib 1.3, last time updated with raylib 1.4
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2015-2024 Ramon Santamaria (@raysan5)
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
    
	r.init_window(screen_width, screen_height, 'raylib [core] example - core world screen'.str)

	// Define the camera to look into our 3d world
	mut camera := r.Camera{}
	camera.position = r.Vector3{ 10.0, 10.0, 10.0 } // Camera position
	camera.target = r.Vector3{ 0.0, 0.0, 0.0 }      // Camera looking at point
	camera.up = r.Vector3{ 0.0, 1.0, 0.0 }          // Camera up vector (rotation towards target)
	camera.fovy = 45.0                              // Camera field-of-view Y
	camera.projection = r.camera_perspective // Camera mode type

	mut cube_position := r.Vector3{ 0.0, 0.0, 0.0 }
	mut cube_screen_position := r.Vector2{ 0.0, 0.0 }

	r.disable_cursor() // Disable cursor for first person camera

	r.set_target_fps(60) // Set our game to run at 60 frames-per-second
	//--------------------------------------------------------------------------------------

	// Main game loop
	for !r.window_should_close()
	{
		// Update
        //----------------------------------------------------------------------------------
        r.update_camera(&camera, r.camera_third_person) // Update camera

        // Calculate cube screen space position (with a little offset to be in top)
		cube_screen_position = r.get_world_to_screen(r.Vector3{ cube_position.x, cube_position.y + 2.5, cube_position.z }, camera)
	
		// Draw
        //----------------------------------------------------------------------------------
        r.begin_drawing()
			r.clear_background(r.raywhite)
			r.begin_mode_3d(camera)
				r.draw_cube(cube_position, 2.0, 2.0, 2.0, r.red)
				r.draw_cube_wires(cube_position, 2.0, 2.0, 2.0, r.maroon)
				r.draw_grid(10, 1.0)
			r.end_mode_3d()

			r.draw_text('Enemy: 100 / 100'.str, int(cube_screen_position.x - r.measure_text('Enemy: 100 / 100'.str, 20) / 2), int(cube_screen_position.y), 20, r.black)

			r.draw_text('Cube position in screen space coordinates: (${cube_screen_position.x},${cube_screen_position.y})'.str, 5, 10, 20, r.lime)
			r.draw_text('Text 2d should be always on top of the cube'.str, 10, 40, 20, r.gray)

		r.end_drawing()
		//----------------------------------------------------------------------------------
	}
	// De-Initialization
    //--------------------------------------------------------------------------------------
    r.close_window();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------

}
