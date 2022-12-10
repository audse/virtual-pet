class_name Dates
extends Object

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

const MINS_IN_DAY: int = 60 * 24
const MINS_IN_WEEK: int = MINS_IN_DAY * 7
const MINS_IN_SEASON: int = MINS_IN_WEEK * 4
const MINS_IN_YEAR: int = MINS_IN_SEASON * 4


static func to_date_string(mins: int) -> String:
	var years := Dates.to_years(mins)
	mins -= years * MINS_IN_YEAR
	
	var season := Dates.to_seasons(mins)
	mins -= season * MINS_IN_SEASON
	
	var days := Dates.to_days(mins)
	
	return "{season} {days}, Year {year}".format({
		days = days + 1,
		season = Dates.get_season_name(season),
		year = years + 1
	})


static func to_relative_date_string(mins: int) -> String:
	var current: int = Datetime.data.now
	var delta := current - mins
	
	var years := Dates.to_years(delta)
	if years > 0: return "{y} year{s}".format({
		y = years,
		s = "s" if years != 1 else ""
	})
	
	var weeks := Dates.to_weeks(delta)
	if weeks > 0: return "{w} week{s}".format({
		w = weeks,
		s = "s" if weeks != 1 else ""
	})
	
	var days := Dates.to_days(delta)
	if days > 0: return "{d} day{s}".format({
		d = days,
		s = "s" if days != 1 else ""
	})
	
	var hours := Dates.to_hours(delta)
	if hours > 0: return "{h} hour{s}".format({
		h = hours,
		s = "s" if hours != 1 else ""
	})
	
	return "{m} minute{s}".format({
		m = delta,
		s = "s" if delta != 1 else ""
	})


static func to_years(mins: int) -> int:
	return floori(mins as float / MINS_IN_YEAR as float)


static func to_seasons(mins: int) -> int:
	return floori(mins as float / MINS_IN_SEASON as float)


static func to_weeks(mins: int) -> int:
	return floori(mins as float / MINS_IN_WEEK as float)


static func to_days(mins: int) -> int:
	return floori(mins as float / MINS_IN_DAY as float)


static func to_hours(mins: int) -> int:
	return floori(mins as float / 60.0)


static func get_day_name(day: Dates.Day) -> String:
	return {
		Dates.Day.MON: "Monday",
		Dates.Day.TUE: "Tuesday",
		Dates.Day.WED: "Wednesday",
		Dates.Day.THU: "Thursday",
		Dates.Day.FRI: "Friday",
		Dates.Day.SAT: "Saturday",
		Dates.Day.SUN: "Sunday"
	}[day]


static func get_short_day_name(day: Dates.Day) -> String:
	return Dates.get_day_name(day).substr(3)


static func get_season(week: int) -> int:
	return (
		Dates.Season.WINTER if week > 12
		else Dates.Season.FALL if week > 8
		else Dates.Season.SUMMER if week > 4
		else Dates.Season.SPRING
	)


static func get_season_name(season: Dates.Season) -> String:
	return {
		Dates.Season.WINTER: "Winter",
		Dates.Season.FALL: "Fall",
		Dates.Season.SUMMER: "Summer",
		Dates.Season.SPRING: "Spring",
	}[season]


static func get_date_suffix(day_of_month: int) -> String:
	match day_of_month:
		1, 21: return "st"
		2, 22: return "nd"
		3, 23: return "rd"
		_: return "th"


static func get_timestamp(args := {}) -> int:
	var mins := 0
	match args:
		{ "years", .. }:
			mins += args.years * MINS_IN_YEAR
			continue
		{ "seasons", .. }:
			mins += args.seasons * MINS_IN_SEASON
			continue
		{ "weeks", .. }:
			mins += args.weeks * MINS_IN_WEEK
			continue
		{ "days", .. }:
			mins += args.days * MINS_IN_DAY
			continue
		{ "hours", .. }:
			mins += args.hours * 60
			continue
		{ "minutes", .. }:
			mins += args.minutes
	return mins


static func from_timestamp(mins: int) -> Dictionary:
	var date := {
		years = 0,
		seasons = 0,
		weeks = 0,
		days = 0,
		hours = 0,
		minutes = 0,
	}
	date.years = Dates.to_years(mins)
	mins -= date.years * MINS_IN_YEAR
	
	date.seasons = Dates.to_seasons(mins)
	mins -= date.seasons * MINS_IN_SEASON
	
	date.weeks = Dates.to_weeks(mins)
	mins -= date.weeks * MINS_IN_WEEK
	
	date.days = Dates.to_days(mins)
	mins -= date.days * MINS_IN_DAY
	
	date.hours = Dates.to_hours(mins)
	mins -= date.hours * 60
	
	date.minutes = mins
	return date


static func from_unix_timestamp(time: int, options = { reset_year = true }) -> Dictionary:
	var date := Time.get_datetime_dict_from_unix_time(time)
	for key in date.keys(): date[key + "s"] = date[key]
	if options.reset_year: date.years -= 1970
	date.seasons = 0
	date.months -= 1
	date.days -= 1
	return date
