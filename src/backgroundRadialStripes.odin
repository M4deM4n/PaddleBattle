package PaddleBattle

import "core:c"
import rl "vendor:raylib"

RadialStripesData :: struct {
	locTime:           c.int,
	locRes:            c.int,
	locRotationSpeed:  c.int,
	locStripeColorA:   c.int,
	locStripeColorB:   c.int,
	locHighlightColor: c.int,
	rotationSpeed:     f32,
	stripeColorA:      [3]f32,
	stripeColorB:      [3]f32,
	highlightColor:    [3]f32,
	lastBallDir:       i8,
	curBallDir:        i8,
	primaryColor:      [3]f32,
	secondaryColor:    [3]f32,
	paddle1Color:      [3]f32,
	paddle2Color:      [3]f32,
}

makeRadialStripesBackground :: proc() -> Background {
	bg: Background
	bg.id = .RadialStripes
	bg.name = "Radial Stripes"
	bg.shader = rl.LoadShaderFromMemory(nil, #load("../res/shader/radial_stripes.glsl", cstring))

	d := new(RadialStripesData)
	d.locTime = rl.GetShaderLocation(bg.shader, "u_time")
	d.locRes = rl.GetShaderLocation(bg.shader, "u_resolution")
	d.locRotationSpeed = rl.GetShaderLocation(bg.shader, "u_rotationSpeed")
	d.locStripeColorA = rl.GetShaderLocation(bg.shader, "u_stripeColorA")
	d.locStripeColorB = rl.GetShaderLocation(bg.shader, "u_stripeColorB")
	d.locHighlightColor = rl.GetShaderLocation(bg.shader, "u_highlightColor")

	d.rotationSpeed = (ball.velocity.x * 0.25) / 25000.0
	d.stripeColorA = rl.ColorNormalize(paddles[0].color).xyz
	d.stripeColorB = rl.ColorNormalize(paddles[1].color).xyz
	d.primaryColor = d.stripeColorA
	d.secondaryColor = d.stripeColorB

	d.paddle1Color = rl.ColorNormalize(paddles[0].color).xyz
	d.paddle2Color = rl.ColorNormalize(paddles[1].color).xyz

	// d.highlightColor = {1.000, 0.984, 0.941}
	d.highlightColor = {0.0, 0.0, 0.0}

	bg.data = d
	bg.reset = resetRadialStripes
	bg.update = radialStripesUpdate
	bg.destroy = proc(bg: ^Background) {free(bg.data)}
	return bg
}

resetRadialStripes :: proc(bg: ^Background) {
	d := cast(^RadialStripesData)bg.data
	d.rotationSpeed = (ball.velocity.x * 0.25) / 25000.0
	bg.data = d

}

radialStripesUpdate :: proc(bg: ^Background, dt: f32) {
	d := cast(^RadialStripesData)bg.data
	t := f32(rl.GetTime())
	res := [2]f32{gameScreenWidth, gameScreenHeight}

	d.lastBallDir = d.curBallDir
	d.curBallDir = (ball.velocity.x > 0 ? 1 : -1)

	if d.lastBallDir != 0 && d.lastBallDir != d.curBallDir {
		d.primaryColor = (d.curBallDir > 0 ? d.paddle1Color.xyz : d.paddle2Color.xyz)
		d.secondaryColor = (d.curBallDir > 0 ? d.paddle2Color.xyz : d.paddle1Color.xyz)
		d.stripeColorA = {1.0, 1.0, 1.0}
		d.stripeColorB = {1.0, 1.0, 1.0}
	}

	lerpSpeed: f32 = 4.0
	a := min(dt * lerpSpeed, 1.0)
	d.stripeColorA.x += (d.primaryColor.x - d.stripeColorA.x) * a
	d.stripeColorA.y += (d.primaryColor.y - d.stripeColorA.y) * a
	d.stripeColorA.z += (d.primaryColor.z - d.stripeColorA.z) * a

	d.stripeColorB.x += (d.secondaryColor.x - d.stripeColorB.x) * a
	d.stripeColorB.y += (d.secondaryColor.y - d.stripeColorB.y) * a
	d.stripeColorB.z += (d.secondaryColor.z - d.stripeColorB.z) * a


	d.rotationSpeed = rl.Lerp(d.rotationSpeed, ((ball.velocity.x * 0.25) / 25000.0), dt)

	rl.SetShaderValue(bg.shader, d.locTime, &t, .FLOAT)
	rl.SetShaderValue(bg.shader, d.locRes, &res, .VEC2)
	rl.SetShaderValue(bg.shader, d.locRotationSpeed, &d.rotationSpeed, .FLOAT)
	rl.SetShaderValue(bg.shader, d.locStripeColorA, &d.stripeColorA, .VEC3)
	rl.SetShaderValue(bg.shader, d.locStripeColorB, &d.stripeColorB, .VEC3)
	rl.SetShaderValue(bg.shader, d.locHighlightColor, &d.highlightColor, .VEC3)

	ball.color = rl.WHITE
}
