tool
class_name MathPlot
extends ColorRect

export(Array, Vector2) var plot_extent = [Vector2(-1.0,-1.0), Vector2(1.0,1.0)]
export(Vector2) var grid_spacing = Vector2(0.2,0.2)

export(float) var spline_length = 0.2

var gridLines = []
var tickLabels = []


var transT = Vector2(0,0)
var scaleT = Transform2D(Vector2(0,0),Vector2(0,0),Vector2(0,0))

var drawnLines = []
var drawnPoints = []
var labelPoints = []

signal mouse_click(pos)


func rangef(start: float, end: float, step: float):
	var res = Array()
	var i = start
	while i < end:
		res.push_back(i)
		i += step
	return res


func _ready():
	setUpTransforms()
	addGridLines()
	addTickLabels()
	
	update()

func setUpTransforms():
	var _curPos = self.get_rect().position
	var curSize = self.get_rect().size
	scaleT.x.x = (curSize.x/(plot_extent[1].x - plot_extent[0].x))
	scaleT.y.y = -(curSize.y/(plot_extent[1].y - plot_extent[0].y))
	transT = scaleT*Vector2(plot_extent[0].x,plot_extent[1].y)*-1.0

func plotToGlobal(start):
	start = scaleT * start
	start = start + transT
	return start

func globalToPlot(start):
	start =  start - (self.get_rect().position + transT)
	start = scaleT.affine_inverse() * start
	return start

func addGridLines():
	for child in gridLines:
		child.free()
	gridLines.clear()
	
	setUpTransforms()
	
	var xLines = rangef(plot_extent[0].x,plot_extent[1].x, grid_spacing.x)
	var yLines = rangef(plot_extent[0].y,plot_extent[1].y, grid_spacing.y)
	
	if not (0.0 in xLines) and (plot_extent[0].x < 0) and (plot_extent[1].x > 0):
		xLines.append(0.0)
	
	if not (0.0 in yLines) and (plot_extent[0].y < 0) and (plot_extent[1].y > 0):
		yLines.append(0.0)

	for xLine in xLines:
		var curLine = Line2D.new()
		curLine.set_default_color(Color(0,0,0,0.1))
		if xLine == 0.0:
			curLine.set_width(5)
		else:
			curLine.set_width(2)
		curLine.add_point(plotToGlobal(Vector2(xLine,plot_extent[0].y)))
		curLine.add_point(plotToGlobal(Vector2(xLine,plot_extent[1].y)))
		self.add_child(curLine)
		gridLines.append(curLine)
	
	for yLine in yLines:
		var curLine = Line2D.new()
		curLine.set_default_color(Color(1,1,1,0))
		if yLine == 0.0:
			curLine.set_width(5)
		else:
			curLine.set_width(2)
		curLine.add_point(plotToGlobal(Vector2(plot_extent[0].x,yLine)))
		curLine.add_point(plotToGlobal(Vector2(plot_extent[1].x,yLine)))
		self.add_child(curLine)
		gridLines.append(curLine)

func addTickLabels():
	for child in tickLabels:
		child.free()
	tickLabels.clear()
	
	var xLines = rangef(plot_extent[0].x,plot_extent[1].x,grid_spacing.x)
	var yLines = rangef(plot_extent[0].y,plot_extent[1].y, grid_spacing.y)
	
	for xLine in xLines:
		var curLabel = Label.new()
		curLabel.self_modulate = Color.black
		curLabel.text = str(xLine)
		var lineSize = curLabel.get_font("font").get_string_size(str(xLine))
		curLabel.set_position(plotToGlobal(Vector2(xLine,0)) + Vector2(lineSize.x,lineSize.y))
		self.add_child(curLabel)
		tickLabels.append(curLabel)
	
	for yLine in yLines:
		var curLabel = Label.new()
		curLabel.self_modulate = Color.black
		curLabel.text = str(yLine)
		var lineSize = curLabel.get_font("font").get_string_size(str(yLine))
		curLabel.set_position(plotToGlobal(Vector2(0,yLine)) - 1.5*Vector2(lineSize.x,lineSize.y))
		self.add_child(curLabel)
		tickLabels.append(curLabel)

func createSimpleLine(pointList):
	drawnLines.append(pointList)

func createScatterPlot(pointList):
	for pt in pointList:
		drawnPoints.append(pt)

func createLabels(labelList):
	for label in labelList:
		labelPoints.append([label["label"],label["pos"],label["color"]])

func _input(event):
	if event.is_action_pressed("ui_accept"):
		var curMouse = get_global_mouse_position()
		if self.get_rect().has_point(curMouse):
			emit_signal("mouse_click",globalToPlot(curMouse))
			

func _draw():
	for listPts in drawnLines:
		var line = SmoothPath.new()
		
		for v in listPts:
			line._add_point(plotToGlobal(v))
		line.spline_length = spline_length
		line.smooth(1)
		draw_polyline(line.curve.get_baked_points(), Color.black, 2, true)
	
	#draw points
	var i = 0
	for point in drawnPoints:
		i+=0.2
		draw_circle(plotToGlobal(point),4.0,Color.green.lightened(i))
		
	
	for label in labelPoints:
		var curLabel = Label.new()
		draw_string(curLabel.get_font("font"),plotToGlobal(label[1]),label[0],label[2])
