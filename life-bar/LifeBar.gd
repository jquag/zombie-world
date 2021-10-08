extends TextureProgress


func _ready():
	var _ignore = $VisibleTimer.connect('timeout', self, '_on_VisibleTimer_timeout')


func updateLife(val):
	self.visible = true
	self.value = val
	$VisibleTimer.start()


func _on_VisibleTimer_timeout():
	self.visible = false