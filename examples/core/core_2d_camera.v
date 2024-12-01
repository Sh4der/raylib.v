/*******************************************************************************************
*
*   raylib [core] example - 2D Camera system
*
*   Example originally created with raylib 1.5, last time updated with raylib 3.0
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2016-2024 Ramon Santamaria (@raysan5)
*
********************************************************************************************/

import raylibv as r

const max_buildings = 100

const screen_width = 800
const screen_height = 450

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
fn main()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    r.init_window(screen_width, screen_height, "raylib [core] example - 2d camera".str);

    mut player := r.Rectangle{ 400.0, 280.0, 40.0, 40.0 }
    mut buildings := [max_buildings]r.Rectangle{}
    mut build_colors := [max_buildings]r.Color{}

    mut spacing := 0

    for i in 0..max_buildings
    {
        buildings[i].width = r.get_random_value(50, 200)
        buildings[i].height = r.get_random_value(100, 800)
        buildings[i].y = screen_height - 130 - buildings[i].height
        buildings[i].x = -6000 + spacing

        spacing += int(buildings[i].width)

        build_colors[i] = r.Color{ u8(r.get_random_value(200, 240)), u8(r.get_random_value(200, 240)), u8(r.get_random_value(200, 250)), 255 }
    }

    mut camera := r.Camera2D{}
    camera.target = r.Vector2{ player.x + 20, player.y + 20 }
    camera.offset = r.Vector2{ screen_width/2, screen_height/2 }
    camera.rotation = 0.0
    camera.zoom = 1.0

    r.set_target_fps(60); // Set our game to run at 60 frames-per-second
    //---------------------------------------------------------------------------------------

    // Main game loop
    for !r.window_should_close(){
        // Update
        //----------------------------------------------------------------------------------
        // Player movement
        if r.is_key_down(r.key_right) { player.x += 2 }
        else if r.is_key_down(r.key_left) { player.x -= 2 }

        // Camera target follows player
        camera.target = r.Vector2{ player.x + 20, player.y + 20 }

        // Camera rotation controls
        if r.is_key_down(r.key_a) { camera.rotation-- }
        else if r.is_key_down(r.key_d) { camera.rotation++ }

        // Limit camera rotation to 80 degrees (-40 to 40)
        if camera.rotation > 40 { camera.rotation = 40 }
        else if camera.rotation < -40 { camera.rotation = -40 }

        // Camera zoom controls
        camera.zoom += r.get_mouse_wheel_move()*0.05

        if camera.zoom > 3.0 { camera.zoom = 3.0 }
        else if camera.zoom < 0.1 { camera.zoom = 0.1 }

        // Camera reset (zoom and rotation)
        if r.is_key_pressed(r.key_r)
        {
            camera.zoom = 1.0
            camera.rotation = 0.0
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        r.begin_drawing()
        r.clear_background(r.raywhite)
        r.begin_mode_2d(camera)
        r.draw_rectangle(-6000, 320, 13000, 8000, r.darkgray)

        for i in 0..max_buildings
        {
            r.draw_rectangle_rec(buildings[i], build_colors[i])
        }

        r.draw_rectangle_rec(player, r.red)

        r.draw_line(int(camera.target.x), -screen_height*10, int(camera.target.x), screen_height*10, r.green)
        r.draw_line(-screen_width*10, int(camera.target.y), screen_width*10, int(camera.target.y), r.green)

        r.end_mode_2d()

        r.draw_text("SCREEN AREA".str, 640, 10, 20, r.red)

        r.draw_rectangle(0, 0, screen_width, 5, r.red)
        r.draw_rectangle(0, 5, 5, screen_height - 10, r.red)
        r.draw_rectangle(screen_width - 5, 5, 5, screen_height - 10, r.red)
        r.draw_rectangle(0, screen_height - 5, screen_width, 5, r.red)

        r.draw_rectangle(10, 10, 250, 113, r.fade(r.skyblue, 0.5))
        r.draw_rectangle_lines(10, 10, 250, 113, r.blue)

        r.draw_text("Free 2d camera controls:".str, 20, 20, 10, r.black)
        r.draw_text("- Right/Left to move Offset".str, 40, 40, 10, r.darkgray)
        r.draw_text("- Mouse Wheel to Zoom in-out".str, 40, 60, 10, r.darkgray)
        r.draw_text("- A/D to Rotate".str, 40, 80, 10, r.darkgray)
        r.draw_text("- R to reset Zoom and Rotation".str, 40, 100, 10, r.darkgray)

        r.end_drawing()
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    r.close_window(); // Close window and OpenGL context
    //--------------------------------------------------------------------------------------


}