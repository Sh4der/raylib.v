/*******************************************************************************************
*
*   raylib [core] example - Basic window
*
*   Welcome to raylib!
*
*   To test examples, just press F6 and execute 'raylib_compile_execute' script
*   Note that compiled executable is placed in the same folder as .c file
*
*   To test the examples on Web, press F6 and execute 'raylib_compile_execute_web' script
*   Web version of the program is generated in the same folder as .c file
*
*   You can find all basic examples on C:\raylib\raylib\examples folder or
*   raylib official webpage: www.raylib.com
*
*   Enjoy using raylib. :)
*
*   Example originally created with raylib 1.0, last time updated with raylib 1.0
*
*   Example licensed under an unmodifiC.TextJoined zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2013-2024 Ramon Santamaria (@raysan5)
*
********************************************************************************************/
import raylibv as r

const screen_width = 800
const screen_height = 450

fn main() {
	r.init_window(screen_width, screen_height, 'raylib.v [core] example - basic window'.str)
	r.set_target_fps(60)
	for !r.window_should_close() {
		r.begin_drawing()
		r.clear_background(r.Color{ r: 245, g: 245, b: 245, a: 255 })
		r.draw_text('Congrats! You created your first window in V!'.str, 190, 200, 20,
			r.Color{
			r: 0
			g: 0
			b: 0
			a: 255
		})
		r.end_drawing()
	}
	r.close_window()
}
