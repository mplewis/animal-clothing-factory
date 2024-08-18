class_name SizeResult

var actual_size: int
var expected_size: int

func _to_string():
	return "<SizeResult expected: %d, actual: %d>" % [expected_size, actual_size]
