extends Node2D


var today = Array()
var week = Array()
var future = Array()
var dot
var td
var we
var tm

func _ready():
	td = 3
	we = 3
	tm = 3
	update_values()
	$Control/get_dt.set_visible(0)


func update_values():
	global.dt = [Vector2(td,1),Vector2(we,1),Vector2(tm,1)]
	global.hdt = str(td,',',we,',',tm)
	print(global.hdt)
	
func _on_today_value_changed(value):
	td = value
	update_values()

func _on_week_value_changed(value):
	we = value
	update_values()

func _on_future_value_changed(value):
	tm = value
	update_values()


func _on_Button_pressed():
	$HTTPRequest.send_data()
	
	$Control/Button.set_visible(0)
	$Control/get_dt.set_visible(1)
	



func _on_get_dt_pressed():
	$HTTPRequest.get_data()




func _on_HTTPRequest_request_completed(_result, _response_code, _headers, body):
	if body.get_string_from_utf8() == "upload successful":
			print("upload")
			$HTTPRequest.get_data()
			
	elif body.get_string_from_utf8() == "error":
			print("error")
			
	else:
		global.dl = body.get_string_from_utf8()
		var js = parse_json(global.dl)
		today = Array()
		week = Array()
		future = Array()
		#print(js)
		for i in range(0,len(js)):
			#get today
			if int(js[i]["TIMESTAMP"].substr(8,2)) == OS.get_date()["day"] && int(js[i]["TIMESTAMP"].substr(5,2)) == OS.get_date()["month"] && int(js[i]["TIMESTAMP"].substr(0,4)) == OS.get_date()["year"]: #get day
				var st = js[i]["DATA"]
				var cl = st.substr(1,-1)
				var clean = cl.split_floats(",")
				today.append(clean[0])
				week.append(clean[1])
				future.append(clean[2])
		update_values()
		draw_hist(today,1)
		
func draw_hist(dt,id):
	var hist_dt = Array()
	print(dt)
	print(dt.count(float(3)))
	for i in range(0,7):
		hist_dt.append(dt.count(float(i)))
		#print(i+1)
		get_node(str('ht',id,'/h',i+1)).scale = Vector2(1,-(0.25*hist_dt[i]))
		get_node(str('ht',id,'/v',i+1)).text = str(hist_dt[i])
		
		
		#$ht/h1.scale.x = hist_dt(1)

#	else:
#		#print(body.get_string_from_utf8())
#		global.dl = body.get_string_from_utf8()
#
#		var js = parse_json(global.dl)
#
#
#		for i in range(0,len(js)):
#			if int(js[i]["TIMESTAMP"].substr(8,2)) == OS.get_date()["day"] && int(js[i]["TIMESTAMP"].substr(5,2)) == OS.get_date()["month"] && int(js[i]["TIMESTAMP"].substr(0,4)) == OS.get_date()["year"]: #get day
#				var x = float(js[i]["DATA"].substr(3,1))
#				var y = float(js[i]["DATA"].substr(6,1))
#				print(x,y)
#				if today.has(Vector2(x,y)):
#					y+=i*0.18
#					today.append(Vector2(x,y))
#				else:
#					today.append(Vector2(x,y))
#		update_values()
#		$Control/MathPlot.createScatterPlot(today)
#		$Control/MathPlot.update()

