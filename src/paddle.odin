package PaddleBattle

import "types"
import rl "vendor:raylib"

Paddle :: struct {
	size:         rl.Vector2,
	position:     rl.Vector2,
	velocity:     f32,
	color:        rl.Color,
	baseColor:    rl.Color,
	shadowColor:  rl.Color,
	shadowOffset: rl.Vector2,
}

normalPaddle: rl.Vector2 = {20, 100}

initPaddles :: proc(game: ^types.Game) {
	startPosY = (game.screen.y * 0.5) - (normalPaddle.y * 0.5)

	paddle_l := types.Paddle {
		size         = {20, 100},
		position     = {10, startPosY},
		velocity     = paddle_velocity,
		color        = {0, 0, 255, 255},
		baseColor    = {0, 0, 255, 255},
		shadowColor  = {0, 0, 0, 255},
		shadowOffset = {3, 3},
	}

	paddle_r := types.Paddle {
		position     = {game.screen.x - 30, startPosY},
		size         = {20, 100},
		velocity     = paddle_velocity,
		color        = {255, 0, 0, 255},
		baseColor    = {255, 0, 0, 255},
		shadowColor  = {0, 0, 0, 255},
		shadowOffset = {3, 3},
	}

	game.paddles[player1] = paddle_l
	game.paddles[player2] = paddle_r
}

resetPaddles :: proc(game: ^types.Game) {
	for i in 0 ..= 1 {
		game.paddles[i].position.y = startPosY
	}
}

updatePaddleInput :: proc(game: ^types.Game, dt: f32) {
	// player 1
	if rl.IsKeyDown(.W) {
		game.paddles[player1].position.y -= game.paddles[player1].velocity * dt
	}

	if rl.IsKeyDown(.S) {
		game.paddles[player1].position.y += game.paddles[player1].velocity * dt
	}

	// player 2
	if game.mode == .Multiplayer || game.mode == .MultiplayerTimed {

		if rl.IsKeyDown(.KP_8) {
			game.paddles[player2].position.y -= game.paddles[player2].velocity * dt
		}

		if rl.IsKeyDown(.KP_5) {
			game.paddles[player2].position.y += game.paddles[player2].velocity * dt
		}
	}
}

updatePaddles :: proc(game: ^types.Game, dt: f32) {
	updatePaddleInput(game, dt)

	// clamp paddles so they stay on screen
	for i in 0 ..= 1 {
		if i == 0 {
			game.paddles[i].color = rl.ColorLerp(
				game.paddles[i].color,
				game.paddles[i].baseColor,
				dt,
			)
		}

		if i == 1 {
			game.paddles[i].color = rl.ColorLerp(
				game.paddles[i].color,
				game.paddles[i].baseColor,
				dt,
			)
		}


		game.paddles[i].position.y = clamp(
			game.paddles[i].position.y,
			0,
			game.screen.y - game.paddles[i].size.y,
		)
	}
}

renderPaddles :: proc(game: ^types.Game) {
	for playerPaddle in game.paddles {
		rl.DrawRectangleV(
			playerPaddle.position + playerPaddle.shadowOffset,
			playerPaddle.size,
			playerPaddle.shadowColor,
		)
		rl.DrawRectangleV(playerPaddle.position, playerPaddle.size, playerPaddle.color)
	}
}
