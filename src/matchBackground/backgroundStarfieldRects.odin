package MatchBackground

import "../types"
import "core:c"
import rl "vendor:raylib"

StarfieldData :: struct {
	locTime:      c.int,
	locRes:       c.int,
	locBgColor:   c.int,
	locRectColor: c.int,
	bgColor:      [3]f32,
	rectColor:    [3]f32,
}

StarfieldTimer: f32
lastStarFieldDirection: f32
currentStarFieldDirection: f32
timeSinceChange: f32

makeStarfieldSquaresBackground :: proc(game: ^types.Game) -> Background {
	bg: Background
	bg.id = .StarfieldSquares
	bg.name = "Starfield Rects"
	bg.shader = rl.LoadShaderFromMemory(
		nil,
		#load("../../res/shader/starfield_rects.glsl", cstring),
	)

	d := new(StarfieldData)
	d.locTime = rl.GetShaderLocation(bg.shader, "u_time")
	d.locRes = rl.GetShaderLocation(bg.shader, "u_resolution")
	d.locBgColor = rl.GetShaderLocation(bg.shader, "u_bgColor")
	d.locRectColor = rl.GetShaderLocation(bg.shader, "u_rectColor")

	d.bgColor = rl.ColorNormalize(game.paddles[0].baseColor).xyz
	d.rectColor = rl.ColorNormalize(rl.ColorLerp(game.paddles[0].color, rl.WHITE, 0.2)).xyz

	bg.data = d
	bg.update = starfieldUpdate
	bg.destroy = proc(bg: ^Background) {free(bg.data)}

	return bg
}

starfieldUpdate :: proc(game: ^types.Game, bg: ^Background, dt: f32) {
	StarfieldTimer += dt
	timeSinceChange += dt

	lastStarFieldDirection = currentStarFieldDirection
	currentStarFieldDirection = game.ball.velocity.x > 0 ? 1 : -1

	if currentStarFieldDirection != lastStarFieldDirection {
		StarfieldTimer -= timeSinceChange
		timeSinceChange = 0
	}

	d := cast(^StarfieldData)bg.data
	t := StarfieldTimer
	res := game.screen

	t = game.ball.velocity.x >= 0 ? t * -1 : t

	d.bgColor =
		game.ball.velocity.x >= 0 ? rl.ColorNormalize(game.paddles[0].color).xyz : rl.ColorNormalize(game.paddles[1].color).xyz

	d.rectColor =
		game.ball.velocity.x >= 0 ? rl.ColorNormalize(rl.ColorLerp(game.paddles[0].color, rl.WHITE, 0.2)).xyz : rl.ColorNormalize(rl.ColorLerp(game.paddles[1].color, rl.WHITE, 0.2)).xyz

	rl.SetShaderValue(bg.shader, d.locTime, &t, .FLOAT)
	rl.SetShaderValue(bg.shader, d.locRes, &res, .VEC2)
	rl.SetShaderValue(bg.shader, d.locBgColor, &d.bgColor, .VEC3)
	rl.SetShaderValue(bg.shader, d.locRectColor, &d.rectColor, .VEC3)

	game.ball.color = rl.WHITE
}
