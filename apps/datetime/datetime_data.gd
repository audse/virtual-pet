class_name DatetimeData
extends Resource

enum Day {
	MON = 0,
	TUE = 1,
	WED = 2,
	THU = 3,
	FRI = 4,
	SAT = 5,
	SUN = 6
}

enum Season {
	SPRING,
	SUMMER,
	FALL,
	WINTER
}

# The amount of time (sec) that corresponds to `UNIT` in-game minutes
const INTERVAL_TIME := 10.0
const UNIT := 10

signal time_paused
signal time_unpaused

signal time_changed(value: int)
signal day_changed(value: Day)
signal week_changed(value: int)
signal season_changed(value: Season)
signal year_changed(value: int)

var prev_pause_state: bool = false
var paused: bool = false:
	set(value):
		prev_pause_state = paused
		paused = value
		if paused != prev_pause_state:
			if paused: time_paused.emit()
			else: time_unpaused.emit()

@export var day: Day = Day.MON:
	set(value):
		day = clamp(value, Day.MON, Day.SUN) as Day
		
		# reset week after sunday
		if value > 6:
			day = Day.MON
		
		day_changed.emit(day)


# Time is incremented by 10 minutes
@export_range(0, 1439, 10) var time: int = 0:
	set(value):
		time = snapped(value, 10) as int
		
		# reset day after 1440 minutes
		if time > 1439:
			time = 0
			day = (day + 1) as Day
		
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

var day_name: String:
	get: return {
		Day.MON: "Monday",
		Day.TUE: "Tuesday",
		Day.WED: "Wednesday",
		Day.THU: "Thursday",
		Day.FRI: "Friday",
		Day.SAT: "Saturday",
		Day.SUN: "Sunday"
	}[day]

var day_name_short: String:
	get: return {
		Day.MON: "Mon",
		Day.TUE: "Tue",
		Day.WED: "Wed",
		Day.THU: "Thu",
		Day.FRI: "Fri",
		Day.SAT: "Sat",
		Day.SUN: "Sun"
	}[day]


var season: Season:
	get: return (
		Season.WINTER if week > 12
		else Season.FALL if week > 8
		else Season.SUMMER if week > 4
		else Season.SPRING
	)


var season_name: String:
	get: return {
		Season.WINTER: "Winter",
		Season.FALL: "Fall",
		Season.SUMMER: "Summer",
		Season.SPRING: "Spring",
	}[season]


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
