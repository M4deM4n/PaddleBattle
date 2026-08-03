package PaddleBattle

import "core:c"
import "core:fmt"
import rl "vendor:raylib"

MAGIC :: 0.003921568627451

HexScrollData :: struct {
	locTime:      c.int,
	locRes:       c.int,
	locHexColor:  c.int,
	locBgColor:   c.int,
	hexColor:     [3]f32,
	curHexColor:  [3]f32,
	bgColor:      [3]f32,
	lastBallDir:  i8,
	curBallDir:   i8,
	paddle1Color: [3]f32,
	paddle2Color: [3]f32,
}

makeHexScrollBackground :: proc() -> Background {
	bg: Background
	bg.id = .HexScroll
	bg.name = "Hex Scroll"
	bg.shader = rl.LoadShaderFromMemory(nil, #load("../res/shader/hex_scroll.glsl", cstring))

	d := new(HexScrollData)
	d.locTime = rl.GetShaderLocation(bg.shader, "u_time")
	d.locRes = rl.GetShaderLocation(bg.shader, "u_resolution")
	d.locHexColor = rl.GetShaderLocation(bg.shader, "u_hexColor")
	d.locBgColor = rl.GetShaderLocation(bg.shader, "u_bgColor")
	d.hexColor = {0.0, 0.0, 0.18}
	d.curHexColor = {0.0, 0.0, 0.18}
	d.bgColor = {0.0, 0.0, 0.0}
	d.paddle1Color = rl.ColorNormalize(paddles[0].color).xyz
	d.paddle2Color = rl.ColorNormalize(paddles[1].color).xyz

	bg.data = d
	bg.update = hexScrollUpdate
	bg.destroy = proc(bg: ^Background) {free(bg.data)}
	return bg
}

hexScrollUpdate :: proc(bg: ^Background, dt: f32) {
	d := cast(^HexScrollData)bg.data
	t := f32(rl.GetTime())
	res := [2]f32{gameScreenWidth, gameScreenHeight}

	d.lastBallDir = d.curBallDir
	d.curBallDir = (ball.velocity.x > 0 ? 1 : -1)

	if d.lastBallDir != 0 && d.lastBallDir != d.curBallDir {
		d.hexColor = d.curBallDir > 0 ? d.paddle1Color : d.paddle2Color
		d.curHexColor = {1.0, 1.0, 1.0}
	}

	lerpSpeed: f32 = 4.0
	a := min(dt * lerpSpeed, 1.0)
	d.curHexColor.x += (d.hexColor.x - d.curHexColor.x) * a
	d.curHexColor.y += (d.hexColor.y - d.curHexColor.y) * a
	d.curHexColor.z += (d.hexColor.z - d.curHexColor.z) * a


	rl.SetShaderValue(bg.shader, d.locTime, &t, .FLOAT)
	rl.SetShaderValue(bg.shader, d.locRes, &res, .VEC2)
	rl.SetShaderValue(bg.shader, d.locHexColor, &d.curHexColor, .VEC3)
	rl.SetShaderValue(bg.shader, d.locBgColor, &d.bgColor, .VEC3)

	ball.color = rl.WHITE
}
