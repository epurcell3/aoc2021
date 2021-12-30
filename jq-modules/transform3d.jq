# input: a 3d vector to be filtered and 3d vector as a parameter
# output: a 3d vector of the distance between the two
def dist3d($from):
	[(.[0] - $from[0]), (.[1] - $from[1]), (.[2] - $from[2])];

def add($adjustment):
	[.[0] + $adjustment[0], .[1] + $adjustment[1], .[2] + $adjustment[2]];

def sub($adjustment):
	[.[0] - $adjustment[0], .[1] - $adjustment[1], .[2] - $adjustment[2]];

def invert: [-.[0], -.[1], -.[2]];

# input: a 3d vector
# output: a list of 3d vectors with all possible facings and up directions and the rotation
def axes_rotations:
	.[0] as $x | .[1] as $y | .[2] as $z |
	[ . + ["+x+y"],    # assume facing +x, up +y
	 [ $x, -$y, -$z, "+x-y"], # facing +x, up -y
	 [-$x,  $y, -$z, "-x+y"], # facing -x, up +y
	 [-$x, -$y,  $z, "-x-y"], # facing -x, up -y

	 [ $x,  $z, -$y, "+x+z"], # facing +x, up +z
	 [ $x, -$z,  $y, "+x-z"], # facing +x, up -z
	 [-$x,  $z,  $y, "-x+z"], # facing -x, up +z
	 [-$x, -$z, -$y, "-x-z"], # facing -x, up -z

	 [ $y,  $x, -$z, "+y+x"], # facing +y, up +x
	 [ $y, -$x,  $z, "+y-x"], # facing +y, up -x
	 [-$y,  $x,  $z, "-y+x"], # facing -y, up +x
	 [-$y, -$x, -$z, "-y-x"], # facing -y, up -x

	 [ $y,  $z,  $x, "+y+z"], # facing +y, up +z
	 [ $y, -$z, -$x, "+y-z"], # facing +y, up -z
	 [-$y,  $z, -$x, "-y+z"], # facing -y, up +z
	 [-$y, -$z,  $x, "-y-z"], # facing -y, up -z

	 [ $z,  $x,  $y, "+z+x"], # facing +z, up +x
	 [ $z, -$x, -$y, "+z-x"], # facing +z, up -x
	 [-$z,  $x, -$y, "-z+x"], # facing -z, up +x
	 [-$z, -$x,  $y, "-z-x"], # facing -z, up -x

	 [ $z,  $y, -$x, "+z+y"], # facing +z, up +y
	 [ $z, -$y,  $x, "+z-y"], # facing +z, up -y
	 [-$z,  $y,  $x, "-z+y"], # facing -z, up +y
	 [-$z, -$y, -$x, "-z-y"] # facing -z, up -y
	];

def rotate($rotation):
	.[0] as $x | .[1] as $y | .[2] as $z |
	if $rotation == "+x+y" then   [ $x,  $y,  $z]
	elif $rotation == "+x-y" then [ $x, -$y, -$z]
	elif $rotation == "-x+y" then [-$x,  $y, -$z]
	elif $rotation == "-x-y" then [-$x, -$y,  $z]

	elif $rotation == "+x+z" then [ $x,  $z, -$y]
	elif $rotation == "+x-z" then [ $x, -$z,  $y]
	elif $rotation == "-x+z" then [-$x,  $z,  $y]
	elif $rotation == "-x-z" then [-$x, -$z, -$y]

	elif $rotation == "+y+x" then [ $y,  $x, -$z]
	elif $rotation == "+y-x" then [ $y, -$x,  $z]
	elif $rotation == "-y+x" then [-$y,  $x,  $z]
	elif $rotation == "-y-x" then [-$y, -$x, -$z]

	elif $rotation == "+y+z" then [ $y,  $z,  $x]
	elif $rotation == "+y-z" then [ $y, -$z, -$x]
	elif $rotation == "-y+z" then [-$y,  $z, -$x]
	elif $rotation == "-y-z" then [-$y, -$z,  $x]

	elif $rotation == "+z+x" then [ $z,  $x,  $y]
	elif $rotation == "+z-x" then [ $z, -$x, -$y]
	elif $rotation == "-z+x" then [-$z,  $x, -$y]
	elif $rotation == "-z-x" then [-$z, -$x,  $y]

	elif $rotation == "+z+y" then [ $z,  $y, -$x]
	elif $rotation == "+z-y" then [ $z, -$y,  $x]
	elif $rotation == "-z+y" then [-$z,  $y,  $x]
	elif $rotation == "-z-y" then [-$z, -$y, -$x]
	else 99 | halt_error end;

# input: a list of 3d vectors
# output: a list of 3d vector lists, each list being a different rotation of the points
def axes_rotations_list:
	{
		"+x+y": map(rotate("+x+y")),
		"+x-y": map(rotate("+x-y")),
		"-x+y": map(rotate("-x+y")),
		"-x-y": map(rotate("-x-y")),

		"+x+z": map(rotate("+x+z")),
		"+x-z": map(rotate("+x-z")),
		"-x+z": map(rotate("-x+z")),
		"-x-z": map(rotate("-x-z")),

		"+y+x": map(rotate("+y+x")),
		"+y-x": map(rotate("+y-x")),
		"-y+x": map(rotate("-y+x")),
		"-y-x": map(rotate("-y-x")),

		"+y+z": map(rotate("+y+z")),
		"+y-z": map(rotate("+y-z")),
		"-y+z": map(rotate("-y+z")),
		"-y-z": map(rotate("-y-z")),

		"+z+x": map(rotate("+z+x")),
		"+z-x": map(rotate("+z-x")),
		"-z+x": map(rotate("-z+x")),
		"-z-x": map(rotate("-z-x")),

		"+z+y": map(rotate("+z+y")),
		"+z-y": map(rotate("+z-y")),
		"-z+y": map(rotate("-z+y")),
		"-z-y": map(rotate("-z-y"))
	};
