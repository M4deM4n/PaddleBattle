package PaddleBattle

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

makeStarfieldSquaresBackground :: proc() -> Background {
	bg: Background
	bg.id = .StarfieldSquares
	bg.name = "Starfield Rects"
	bg.shader = rl.LoadShaderFromMemory(nil, #load("../res/shader/starfield_rects.glsl", cstring))

	d := new(StarfieldData)
	d.locTime = rl.GetShaderLocation(bg.shader, "u_time")
	d.locRes = rl.GetShaderLocation(bg.shader, "u_resolution")
	d.locBgColor = rl.GetShaderLocation(bg.shader, "u_bgColor")
	d.locRectColor = rl.GetShaderLocation(bg.shader, "u_rectColor")

	d.bgColor = {0.01, 0.16, 0.42}
	d.rectColor = {0.01, 0.26, 0.57}

	bg.data = d
	bg.update = starfieldUpdate
	bg.destroy = proc(bg: ^Background) {free(bg.data)}

	return bg
}

starfieldUpdate :: proc(bg: ^Background, dt: f32) {
	ball.color = rl.WHITE

	d := cast(^StarfieldData)bg.data
	t := f32(rl.GetTime())
	res := [2]f32{gameScreenWidth, gameScreenHeight}

	rl.SetShaderValue(bg.shader, d.locTime, &t, .FLOAT)
	rl.SetShaderValue(bg.shader, d.locRes, &res, .VEC2)
	rl.SetShaderValue(bg.shader, d.locBgColor, &d.bgColor, .VEC3)
	rl.SetShaderValue(bg.shader, d.locRectColor, &d.rectColor, .VEC3)
}
