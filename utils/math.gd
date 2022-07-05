class_name Math
extends Object


## Returns an integer of the initial float converted to a MULTIPLIED integer
## This retains the original precision while still being an integer (useful for
## comparison)
static func round_and_multiply_precision(a: float, precision: int) -> int:
	@warning_ignore(narrowing_conversion)
	var multiplier: int = pow(10, precision)
	return int(round(a * multiplier))


## Rounds a float using a specified precision exponent (number of zeroes)
## e.g. (a = 3.14159, precision = 2) returns 3.14
static func round_precision(a: float, precision: int) -> float:
	@warning_ignore(narrowing_conversion)
	var multiplier: int = pow(10, precision)
	return float(round_and_multiply_precision(a, precision)) / multiplier


static func is_float_equal_approx(a: float, b: float, precision: int = 3) -> bool:
	var a_rounded := round_and_multiply_precision(a, precision) 
	var b_rounded := round_and_multiply_precision(b, precision)
	
	return a_rounded == b_rounded
