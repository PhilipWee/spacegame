extends Node2D
export var NUMBER_OF_LEVELS = 9
export var REAL_ADS = true
export var BANNER_TOP = true

var level_data = {}
var current_level = 0
var logs = ""

#_ADS_ADS_ADS_ADS_ADS_ADS_ADS_ADS_ADS_ADS_ADS_ADS_ADS_ADS_ADS_ADS_ADS_ADS_ADS_ADS_ADS
var admob = null
var ad_banner_id = "ca-app-pub-9920392560386719/9085044491"
var ad_interstitial_id = "ca-app-pub-9920392560386719/1994497310"
var ad_rew_vid_id = "ca-app-pub-9920392560386719/1356288781"

func _initialise_ads():
	if Engine.has_singleton("AdMob"):
		admob = Engine.get_singleton("AdMob")
		admob.init(REAL_ADS, get_instance_id())
		admob.loadBanner(ad_banner_id, BANNER_TOP)
		admob.loadInterstitial(ad_interstitial_id)
#		admob.loadRewardedVideo(ad_rew_vid_id)
#	else:
#		logs = "No singleton Admob"
	pass

func show_rewarded_video():
	if admob:
		print('showing video')
		admob.showRewardedVideo()

func show_ad_banner():
	if admob:
		admob.showBanner()

func hide_ad_banner():
	if admob:
		admob.hideBanner()

func show_ad_interstitial():
	if admob:
		admob.showInterstitial()
	

func _on_rewarded_video_ad_closed():
	print('Rewarded video closed!')

func _on_rewarded_video_ad_failed_to_load(errorCode):
	print('Rewarded Video failed to load!')
	print(errorCode)

#_ADS_ADS_ADS_ADS_ADS_ADS_ADS_ADS_ADS_ADS_ADS_ADS_ADS_ADS_ADS_ADS_ADS_ADS_ADS_ADS_ADS


#func _ready():
#	#Populate the level data array with the players data for each level
#	for i in range(NUMBER_OF_LEVELS):
#		level_data.append({"unlocked":false,
#							"stars":0})
#	level_data[0]["unlocked"] = false

# Created by BrunoSXS
# LICENSED UNDER MIT

var save_slot = 'default_save' # Just like classic JRPs, change the slot to save in a different place



func _ready():
	_initialise_ads()
	if typeof(load_game(save_slot)) == TYPE_DICTIONARY:
		level_data = load_game(save_slot)
	else:
		#Populate the level data array with the players data for each level
		for i in range(NUMBER_OF_LEVELS):
			level_data[i] = {"unlocked":false, "stars":0}
		level_data[0]["unlocked"] = false # This is the first loading, when the game starts.
		save_game(save_slot)

func load_game(save_slot): # I used the concept of save slots to handle multiple saves, use what suits you.
	print('loading')
	var F = File.new() # We initialize the File class
	var D = Directory.new() # and the Directory class
	if D.dir_exists("user://save"): # Check if the folder 'save' exists before moving on
		if F.open(str("user://savegame.save"), File.READ_WRITE) == OK: # If the opening of the save file returns OK
			var temp_d # we create a temporary var to hold the contents of the save file
			temp_d = F.get_var() # we get the contents of the save file and store it on TEMP_D
			return temp_d # we return it to do our thing
		else: # In case the opening of the save file doesn't give an OK, we create a save file
			print("save file doesn't exist, creating one") 
			save_game(save_slot) 
	else: # If the folder doesn't exist, we create one...
		D.make_dir("user://save")
		save_game(save_slot) # and we create the save file using the save_game function

func save_game(save_slot): # This functions save the contents of level_data variable into a file 
	print('saving')
	var F = File.new()
	print(F.open(str("user://savegame.save"), File.WRITE)) # we open the file
	F.store_var(level_data) # then we store the contents of the var save inside it
	F.close() # and we gracefully close the file :)