/*******************************************************************************************
*
*   raylib [core] example - 2D Camera platformer
*
*   Example originally created with raylib 2.5, last time updated with raylib 3.0
*
*   Example contributed by arvyy (@arvyy) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2019-2024 arvyy (@arvyy)
*
********************************************************************************************/
import raylibv as r
import math

const g = 400
const player_jump_spd = 350
const player_hor_spd = 200

const screen_width = 800
const screen_height = 450

// update_camera_center_smooth_follow
const min_speed = 30.0
const min_effect_length = 10.0
const fraction_speed = 0.8

// update_camera_even_out_on_landing
const even_out_speed = 700.0



struct Player {
	mut:
	position r.Vector2
	speed f32
	can_jump bool
}

struct EnvItem {
	mut:
	rec r.Rectangle
	blocking bool
	color r.Color
}

struct CameraState {
	mut:
	evening_out bool
	even_out_target f32
}


fn main() {
	
	r.init_window(screen_width, screen_height, 'raylib.v [core] example - 2d camera'.str)

	mut player := Player{
		position: r.Vector2{ 400, 280 }
		speed: 1.0
		can_jump: false
	}

	mut env_items := [
		EnvItem{ r.Rectangle{ 0, 0, 1000, 400 }, false, r.lightgray }
		EnvItem{ r.Rectangle{ 0, 400, 1000, 200 }, true, r.gray }
		EnvItem{ r.Rectangle{ 300, 200, 400, 10 }, true, r.gray }
		EnvItem{ r.Rectangle{ 250, 300, 100, 10 }, true, r.gray }
		EnvItem{ r.Rectangle{ 650, 300, 100, 10 }, true, r.gray }
	]

	mut camera := r.Camera2D{
		target: player.position
		offset: r.Vector2{ screen_width/2, screen_height/2 }
		rotation: 0.0
		zoom: 1.0
	}

	// Store pointers to the multiple update camera functions
	update_camera := [
		update_camera_center,
		update_camera_center_inside_map,
		update_camera_center_smooth_follow,
		update_camera_even_out_on_landing,
		update_camera_player_bounds_push
	]

	mut camera_option := 0
	mut camera_updaters_length := update_camera.len

	mut camera_state := CameraState{
		evening_out: false
		even_out_target: 0.0
	}

	camera_description := [
        "Follow player center",
        "Follow player center, but clamp to map edges",
        "Follow player center; smoothed",
        "Follow player center horizontally; update player center vertically after landing",
        "Player push camera on getting too close to screen edge"
	]

	r.set_target_fps(60)
	//--------------------------------------------------------------------------------------

    // Main game loop
	for !r.window_should_close() {
		// Update
        //----------------------------------------------------------------------------------
        mut delta_time := r.get_frame_time()

		update_player(mut player, mut env_items, delta_time)

		camera.zoom += r.get_mouse_wheel_move() * 0.05

		if camera.zoom > 3.0 {
			camera.zoom = 3.0
		} else if camera.zoom < 0.25 {
			camera.zoom = 0.25
		}

		if r.is_key_pressed(r.key_r) {
			camera.zoom = 1.0
			player.position = r.Vector2{ 400, 280 }
		} 

		if r.is_key_pressed(r.key_c) {
			camera_option = (camera_option + 1) % camera_updaters_length
		}

		// Call update camera function by its pointer
		update_camera[camera_option](mut camera, mut &player, mut env_items, delta_time, screen_width, screen_height, mut camera_state)

		r.begin_drawing()
		r.clear_background(r.lightgray)
		r.begin_mode_2d(camera)

		for i := 0; i < env_items.len; i++ {
			r.draw_rectangle_rec(env_items[i].rec, env_items[i].color)
		}

		player_rect := r.Rectangle{ player.position.x - 20, player.position.y - 40, 40, 40 }
		r.draw_rectangle_rec(player_rect, r.maroon)

		r.draw_circle_v(player.position, 5, r.gold)

		r.end_mode_2d()

		r.draw_text("Controls:".str, 20, 20, 10, r.black)
		r.draw_text("- Right/Left to move".str, 40, 40, 10, r.darkgray)
		r.draw_text("- Space to jump".str, 40, 60, 10, r.darkgray)
		r.draw_text("- Mouse Wheel to Zoom in-out, R to reset zoom".str, 40, 80, 10, r.darkgray)
		r.draw_text("- C to change camera mode".str, 40, 100, 10, r.darkgray)
		r.draw_text("Current camera mode:".str, 20, 120, 10, r.black)
		r.draw_text(camera_description[camera_option].str, 40, 140, 10, r.darkgray)

		r.end_drawing()
	}
	r.close_window()
}

fn update_camera_center(mut camera r.Camera2D, mut player Player, mut env_items []EnvItem,  delta_time f32, width int, height int, mut camera_state CameraState) {
	camera.offset = r.Vector2{ width/2, height/2 }
	camera.target = player.position
}
fn update_camera_center_inside_map(mut camera r.Camera2D, mut player Player, mut env_items []EnvItem,  delta_time f32, width int, height int, mut camera_state CameraState) {
	camera.target = player.position
	camera.offset = r.Vector2{ width/2, height/2 }
	mut min_x := 1000
	mut min_y := 1000
	mut max_x := -1000
	mut max_y := -1000

	for i := 0; i < env_items.len; i++ {
		if env_items[i].rec.x < min_x {
			min_x = int(env_items[i].rec.x)
		}
		if env_items[i].rec.y < min_y {
			min_y = int(env_items[i].rec.y)
		}
		if env_items[i].rec.x + env_items[i].rec.width > max_x {
			max_x = int(env_items[i].rec.x) + int(env_items[i].rec.width)
		}
		if env_items[i].rec.y + env_items[i].rec.height > max_y {
			max_y = int(env_items[i].rec.y) + int(env_items[i].rec.height)
		} 
	}

	max := r.get_world_to_screen_2d(r.Vector2{ max_x, max_y }, camera)
	min := r.get_world_to_screen_2d(r.Vector2{ min_x, min_y }, camera)

	if min.x < width {
		camera.offset.x = width - (max.x - width/2)
	} 
	if min.y < height {
		camera.offset.y = height - (max.y - height/2)
	}
	if max.x > 0 {
		camera.offset.x = width/2 - min.x
	}
	if max.y > 0 {
		camera.offset.y = height/2 - min.y
	}
}
fn update_camera_center_smooth_follow(mut camera r.Camera2D, mut player Player, mut env_items []EnvItem, delta_time f32, width int, height int, mut camera_state CameraState) {

    camera.offset = r.Vector2{ width / 2, height / 2 }
    diff := r.Vector2{ player.position.x - camera.target.x, player.position.y - camera.target.y }
    length := r.vector2_length(diff)

    if length > min_effect_length {
        speed := math.max(fraction_speed * length, min_speed)
        camera.target = r.Vector2{
            x: camera.target.x + diff.x * speed * delta_time / length
            y: camera.target.y + diff.y * speed * delta_time / length
        }
    }
}
fn update_camera_even_out_on_landing(mut camera r.Camera2D, mut player Player, mut env_items []EnvItem, delta_time f32, width int, height int, mut camera_state CameraState) {

    camera.offset = r.Vector2{ width / 2, height / 2 }
    camera.target.x = player.position.x

    if camera_state.evening_out {
        if camera_state.even_out_target > camera.target.y {
            camera.target.y += even_out_speed * delta_time

            if camera.target.y > camera_state.even_out_target {
                camera.target.y = camera_state.even_out_target
                camera_state.evening_out = false
            }
        } else {
            camera.target.y -= even_out_speed * delta_time

            if camera.target.y < camera_state.even_out_target {
                camera.target.y = camera_state.even_out_target
                camera_state.evening_out = false
            }
        }
    } else {
        if player.can_jump && (player.speed == 0) && (player.position.y != camera.target.y) {
            camera_state.evening_out = true
            camera_state.even_out_target = player.position.y
        }
    }
}
fn update_camera_player_bounds_push(mut camera r.Camera2D, mut player Player, mut env_items []EnvItem, delta_time f32, width int, height int, mut camera_state CameraState) {

    bbox := r.Vector2{ 0.2, 0.2 }

    bbox_world_min := r.get_screen_to_world_2d(r.Vector2{ (1 - bbox.x) * 0.5 * width, (1 - bbox.y) * 0.5 * height }, camera)
    bbox_world_max := r.get_screen_to_world_2d(r.Vector2{ (1 + bbox.x) * 0.5 * width, (1 + bbox.y) * 0.5 * height }, camera)
    camera.offset = r.Vector2{ (1 - bbox.x) * 0.5 * width, (1 - bbox.y) * 0.5 * height }

    if player.position.x < bbox_world_min.x {
        camera.target.x = player.position.x
    }
    if player.position.y < bbox_world_min.y {
        camera.target.y = player.position.y
    }
    if player.position.x > bbox_world_max.x {
        camera.target.x = bbox_world_min.x + (player.position.x - bbox_world_max.x)
    }
    if player.position.y > bbox_world_max.y {
        camera.target.y = bbox_world_min.y + (player.position.y - bbox_world_max.y)
    }
}

fn update_player(mut player Player, mut env_items []EnvItem, delta_time f32) {
    if r.is_key_down(r.key_left) {
        player.position.x -= player_hor_spd * delta_time
    }
    if r.is_key_down(r.key_right) {
        player.position.x += player_hor_spd * delta_time
    }
    if r.is_key_down(r.key_space) && player.can_jump {
        player.speed = -player_jump_spd
        player.can_jump = false
    }

    mut hit_obstacle := false
    for i in 0 .. env_items.len {
        ei := env_items[i]
        mut p := &player.position
        if ei.blocking &&
            ei.rec.x <= p.x &&
            ei.rec.x + ei.rec.width >= p.x &&
            ei.rec.y >= p.y &&
            ei.rec.y <= p.y + player.speed * delta_time {
            hit_obstacle = true
            player.speed = 0.0
            p.y = ei.rec.y
            break
        }
    }

    if !hit_obstacle {
        player.position.y += player.speed * delta_time
        player.speed += g * delta_time
        player.can_jump = false
    } else {
        player.can_jump = true
    }
}
