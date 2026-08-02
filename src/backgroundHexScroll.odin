package PaddleBattle

import "core:c"
import rl "vendor:raylib"

HexScrollData :: struct {
	locTime:     c.int,
	locRes:      c.int,
	locHexColor: c.int,
	locBgColor:  c.int,
	hexColor:    [3]f32,
	bgColor:     [3]f32,
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
	d.bgColor = {0.0, 0.0, 0.0}

	bg.data = d
	bg.update = hexScrollUpdate
	bg.destroy = proc(bg: ^Background) {free(bg.data)}
	return bg
}

hexScrollUpdate :: proc(bg: ^Background, dt: f32) {
	d := cast(^HexScrollData)bg.data
	t := f32(rl.GetTime())
	res := [2]f32{gameScreenWidth, gameScreenHeight}

	rl.SetShaderValue(bg.shader, d.locTime, &t, .FLOAT)
	rl.SetShaderValue(bg.shader, d.locRes, &res, .VEC2)
	rl.SetShaderValue(bg.shader, d.locHexColor, &d.hexColor, .VEC3)
	rl.SetShaderValue(bg.shader, d.locBgColor, &d.bgColor, .VEC3)

	ball.color = rl.WHITE
}
