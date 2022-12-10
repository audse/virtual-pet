class_name Benchmark
extends Object


static func run(call: Callable) -> int:
	var start := Time.get_ticks_usec()
	await call.call()
	var end := Time.get_ticks_usec()
	return end - start


## Returns average time (in usec) to complete operation, over an arbitrary amount of iterations
static func bench(call: Callable, iterations := 100) -> float:
	var time := 0.0
	var i := 0
	while i < iterations:
		time += await Benchmark.run(call)
		i += 1
	return time / iterations


static func print_bench(call: Callable, iterations := 100, target = null) -> void:
	var delta: float = await Benchmark.bench(call, iterations)
	var fps := Performance.get_monitor(Performance.TIME_FPS)
	print("[Bench `{callable}`]: ~ {time} usec ({frame} frames at {fps} fps)\n\t- tested {iterations} times".format({
		callable = call.get_method(),
		time = delta,
		frame = snappedf((delta / 1e6) * fps, 0.0001),
		fps = fps,
		iterations = iterations
	}))
	if target and delta <= target: print("\t- under target time!")
	if target and delta  > target: print("\t- exceeded target time.")
