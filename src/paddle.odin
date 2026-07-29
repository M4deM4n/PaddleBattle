package PaddleBattle

import rl "vendor:raylib"

Paddle :: struct {
	size:     rl.Vector2,
	position: rl.Vector2,
	velocity: f32,
	color:    rl.Color,
}

normalPaddle: rl.Vector2 = {20, 100}

initPaddles :: proc() {
	startPosY = (gameScreenHeight * 0.5) - (normalPaddle.y * 0.5)

	paddle_l := Paddle {
		size     = {20, 100},
		position = {10, startPosY},
		velocity = paddle_velocity,
		color    = {0, 0, 255, 255},
	}

	paddle_r := Paddle {
		position = {gameScreenWidth - 30, startPosY},
		size     = {20, 100},
		velocity = paddle_velocity,
		color    = {255, 0, 0, 255},
	}

	paddles[player1] = paddle_l
	paddles[player2] = paddle_r
}

resetPaddles :: proc() {
	for i in 0 ..= 1 {
		paddles[i].position.y = startPosY
	}
}
