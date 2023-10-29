package main

/* TODO: 
end game after one player scores 10 points
reset game
auto-start ball movement
*/ 


import "core:fmt"

import rl "vendor:raylib"

Clamp :: proc(value, min, max : f32) -> f32 {
    if value < min {
        return min
    }
    if value > max {
        return max
    }
    return value
}

Sign :: proc(value : f32) -> f32 {
    if value > 0{
        return 1.0
    }
    else {
        return -1.0
    }
}

Abs :: proc(value : f32) -> f32 {
    if value < 0 {
        return value * -1
    }
    return value
}

UpdateScore :: proc(display : ^cstring, score : i32) {
    display^ = fmt.ctprintf("%d", score)
}

main :: proc() {
    
    WIDTH   : i32 : 900
    HEIGHT  : i32 : 600
    FPS     : i32 : 60

    p_width     : f32 = 20.0
    p_height    : f32 = 120.0

    b_width     : f32 = 15.0
    b_height    : f32 = 15.0

    y_bounce    := [5]f32{0.6, 0.8, 1.0, 1.2, 1.4}


    player_one_score : i32 = 0
    player_cpu_score : i32 = 0

    player_one_display : cstring = "000"
    player_cpu_display : cstring = "000"

    UpdateScore(&player_one_display, player_one_score)
    UpdateScore(&player_cpu_display, player_cpu_score)
    

    start_pos : rl.Vector2 = {
                                f32(WIDTH) / 2.0 - (b_width / 2.0),
                                f32(HEIGHT) / 2.0 - (b_height / 2.0)
                             }

    Paddle :: struct{ 
        rect    : rl.Rectangle,
        color   : rl.Color
    }
    
    player_one : Paddle = {
        {0 + 40.0, f32(HEIGHT / 2), p_width, p_height}, 
        rl.LIME
    }

    player_cpu : Paddle = {
        {f32(WIDTH) - p_width - 40.0, f32(HEIGHT / 2), p_width, p_height}, 
        rl.DARKPURPLE
    }

    cpu_speed:  f32 = 5.0
    
    Ball :: struct{ 
        rect    : rl.Rectangle,
        dir_x   : f32,
        dir_y   : f32,
        speed   : f32,
        color   : rl.Color,
        move    : bool
    }
    
    ball : Ball = { 
        {f32(WIDTH / 2), f32(HEIGHT / 2 - 55), b_width, b_height}, 
        -1.0, 
        1.0, 
        10.0, 
        rl.GOLD,
        false
    }

    ResetBallPosition :: proc(ball:^Ball, pos : rl.Vector2) {
        ball.rect.x = pos.x 
        ball.rect.y = pos.y
        ball.dir_x = -1.0
        ball.dir_y = 1.0
        ball.move = false
        ball.speed -= 2.0
        if ball.speed < 8.0 {
            ball.speed = 8.0
        }
    }

    ResetBallPosition(&ball, start_pos)

    rl.InitWindow(WIDTH, HEIGHT, "ODINPONG")
    rl.SetTargetFPS(FPS)

    rl.HideCursor()
    
    for !rl.WindowShouldClose() {

        if rl.IsKeyPressed(rl.KeyboardKey(32)) {
            ball.move = true
        }

        move_paddle := rl.GetMouseDelta()
        player_one.rect.y += f32(move_paddle.y)
        player_one.rect.y  = Clamp(player_one.rect.y, 0, f32(HEIGHT) - player_one.rect.height)

        if ball.move {
            ball.rect.x += 1 * ball.dir_x * ball.speed
            ball.rect.y += 1 * ball.dir_y * ball.speed
        }

        if ball.rect.x < 0 - ball.rect.width {
            ResetBallPosition(&ball, start_pos)
            player_cpu_score += 1
            UpdateScore(&player_cpu_display, player_cpu_score)
        }
        if ball.rect.x > f32(WIDTH) {
            ResetBallPosition(&ball, start_pos)
            player_one_score += 1
            UpdateScore(&player_one_display, player_one_score)
        }

        if ball.rect.y > f32(HEIGHT) - ball.rect.height{
            ball.dir_y = -1 * Abs(ball.dir_y)
        }
        if ball.rect.y < 0 {
            ball.dir_y = 1 * Abs(ball.dir_y)
        }

        if ball.dir_x < 0 && rl.CheckCollisionRecs(ball.rect, player_one.rect) {
            ball.dir_x *= -1
            ball.dir_y = Sign(ball.dir_y) * y_bounce[rl.GetRandomValue(0,4)]
            cpu_speed = f32(rl.GetRandomValue(2, 10)) 
            ball.speed += 0.5
        }
        if ball.dir_x > 0 && rl.CheckCollisionRecs(ball.rect, player_cpu.rect) {
            ball.dir_x *= -1
            ball.dir_y = Sign(ball.dir_y) * y_bounce[rl.GetRandomValue(0,4)]
            cpu_speed = f32(rl.GetRandomValue(2, 10)) 
            ball.speed += 0.5
        }   

        difference := (ball.rect.y + b_height / 2) - (player_cpu.rect.y + p_height / 2)
        difference = Clamp(difference, -100, 100)
        if ball.dir_x > 0 {
            player_cpu.rect.y += difference * cpu_speed * 0.05
        } else {
            player_cpu.rect.y += Sign(ball.dir_y) * f32(rl.GetRandomValue(0,3))

        }
        

        player_cpu.rect.y = Clamp(player_cpu.rect.y, 0, f32(HEIGHT) - p_height)

        rl.SetMousePosition(WIDTH / 2, HEIGHT / 2)
        
        rl.BeginDrawing()

        rl.ClearBackground(rl.BLACK)

        rl.DrawLine(WIDTH / 2, 0, WIDTH / 2, HEIGHT, rl.DARKGRAY)

        rl.DrawText(player_one_display, WIDTH / 2 - 70, 25, 100, rl.DARKGRAY)
        rl.DrawText(player_cpu_display, WIDTH / 2 + 20, 25, 100, rl.DARKGRAY)

        rl.DrawRectangleRec(ball.rect, ball.color)
        rl.DrawRectangleRec(player_one.rect, player_one.color)
        rl.DrawRectangleRec(player_cpu.rect, player_cpu.color)
                    
        rl.EndDrawing()

    }

    rl.CloseWindow()
}