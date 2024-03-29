class_name DatetimeData
extends Resource

# The amount of time (sec) that corresponds to `UNIT` in-game minutes
const INTERVAL_TIME := 10.0
const UNIT := 10

signal time_paused
signal time_unpaused

signal time_changed(value: int)
signal hour_changed(value: int)
signal day_changed(value: Dates.Day)
signal week_changed(value: int)
signal season_changed(value: Dates.Season)
signal year_changed(value: int)

var prev_pause_state: bool = false
var paused: bool = false:
	set(value):
		prev_pause_state = paused
		paused = value
		if paused != prev_pause_state:
			if paused: time_paused.emit()
			else: time_unpaused.emit()

@export var day: Dates.Day = Dates.Day.MON:
	set(value):
		day = clamp(value, Dates.Day.MON, Dates.Day.SUN) as Dates.Day
		
		# reset week after sunday
		if value > 6:
			day = Dates.Day.MON
			week += 1
		
		day_changed.emit(day)

# Time is incremented by 10 minutes
@export_range(0, 1439, 10) var time: int = 0:
	set(value):
		time = snapped(value, 10) as int
		
		# emit signal for turn of the hour
		if time % 60 == 0:
			hour_changed.emit(int(float(time) / 60.0))
		
		# reset day after 1440 minutes
		if time > 1439:
			time = 0
			day = (day + 1) as Dates.Day
		
		time_changed.emit(time)

@export var week: int = 0:
	set(value):
		week = clamp(value, 0, 16)
		
		# reset weeks after 16 (4 weeks per season, 4 seasons)
		if value > 16:
			week = 0
			year += 1
		
		if week in [0, 4, 8, 12]: season_changed.emit(season)
		
		week_changed.emit(week)

@export var year: int = 0:
	set(value):
		year = value
		year_changed.emit(year)

var now: int:
	get: return (
		time
		+ day * Dates.MINS_IN_DAY
		+ week * Dates.MINS_IN_WEEK
		+ year * Dates.MINS_IN_YEAR
	)

var day_name: String:
	get: return Dates.get_day_name(day)

var day_name_short: String:
	get: return Dates.get_short_day_name(day)

var season: int:
	get: return Dates.get_season(week)

var season_name: String:
	get: return Dates.get_season_name(season)

var display_time: String:
	get:
		# military-time hour
		var hour: int = floori(time as float / 60.0)
		var minute: int = time % (hour * 60)
		
		# non-military-time hour
		var local_hour: int = hour - (12 if hour >= 12 else 0)
		var am_pm: String = (
			("am" if hour < 12 else "pm") if not Settings.data.use_24_hour_clock
			else ""
		)
		
		var local_hour_string: String = (
			# convert "00:00" to "12:00"
			str(local_hour if local_hour != 0 else 12) if not Settings.data.use_24_hour_clock
			# convert "1:00" to "01:00"
			else str(hour).lpad(2, "0")
		)
		
		return "{hour}:{minute}{am_pm}".format({ 
			hour = local_hour_string,
			minute = str(minute).lpad(2, "0"),
			am_pm = am_pm
		})

var day_completeness: float:
	get: return float(time) / float(1440)
