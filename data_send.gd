extends HTTPRequest

var dir = Directory.new()
var file_name
var ip_url = "http://95.179.179.188"
var upload = "/upload/gd.php"
var download = "/upload/score.php"
var header
var query

var data = String()
var dl_data

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func send_data():
	data = String(global.hdt)
	header = ["Content-Type: application/json"]
	var _err = request(ip_url+upload, header,false,HTTPClient.METHOD_POST,to_json(data))


func get_data():
	header = ["Content-Type: application/json"]
	var _err = request(ip_url+download, header,false,HTTPClient.METHOD_GET)
	

