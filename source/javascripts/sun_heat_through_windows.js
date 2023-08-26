
// https://www.newport.com/t/introduction-to-solar-radiation
// https://en.wikipedia.org/wiki/Solar_irradiance
// Solar irradiance (sunlight that reaches the ground from directly above) is approx
//   1050W For direct sunlight
//   1120W For global illumination
// this is reduced based on the angle of the sun both by increased absorption from the atmosphere effect and projection effect
// projection effect is part of sunStrengthProjectionMultiplier() below
// I couldn't find details on absorption effect absorption is not and I failed to find details about it.

solar_constant_w = 1361 // Watts before
atmosphere_absorption_thickness_km = 100
atmosphere_base_absorption_rate = 0.772 // Just a number that turns 1361 into the accepted 1050W

earth_radius_km = 6371
earth_tilt = 23.44

d2r = Math.PI / 180

// The declination is basically the effective tilt of the earth at that date.
// Tilt goes +x to -x and back over the year during the orbit.
// This is the angle of the sun
// https://solarsena.com/solar-declination-angle-calculator/
// This is a pretty close estimation
function dateToDeclinationAngle(date) {
    return -earth_tilt * Math.cos(360.0 / 365 * (dayOfYear(date) + 10) * d2r)
}

function localHourAngle(hour) {
    return 15 * (hour - 12)
}

// Returns [altitude_angle, azimuth_angle]
function solarAngles(date, solar_hour, latitude) {
    let declination_rad = dateToDeclinationAngle(date) * d2r
    let solar_hour_rad = localHourAngle(solar_hour) * d2r
    let latitude_rad = latitude * d2r

    let sin_declination = Math.sin(declination_rad)
    let cos_declination = Math.cos(declination_rad)
    let sin_latitude = Math.sin(latitude_rad)
    let cos_latitude = Math.cos(latitude_rad)
    let cos_solar_hour = Math.cos(solar_hour_rad)

    let altitude_rad = Math.asin(sin_declination * sin_latitude
        + cos_declination * cos_latitude * cos_solar_hour)

    let to_acos = (sin_declination * cos_latitude - cos_declination * sin_latitude * cos_solar_hour) / Math.cos(altitude_rad)

    if (to_acos < -1.01) {
        throw 'Bug1'
    } else if (to_acos < -1) {
        to_acos = -1
    } else if (to_acos > 1.01) {
        throw 'Bug2'
    } else if (to_acos > 1) {
        to_acos = 1
    }
    let azimuth_angle = Math.acos(to_acos) / d2r

    if (solar_hour_rad >= 0) {
        azimuth_angle = 360 - azimuth_angle
    }

    return [altitude_rad / d2r, azimuth_angle]
}

// The actual position of the sun is not where we see it, it refraction in the atmosphere makes it not show
// exactly where it is. The effect is small enough to ignore.
// Approximation from https://britastro.org/2019/atmospheric-refraction
// Higher refraction the lower the sun actually is.
// Even at 20 degrees, the result is minimal... no need to use this.
function atmosphericRefraction(angle) {
    return 57 / Math.tan(angle * d2r) / 3600
}

function atmosphereDistance(radius, thickness, altitude_angle) {
    var slope = Math.tan(altitude_angle * d2r)

    if (Math.abs(slope) > 100000) {
        // With that slope, the real value is tiny, meaningless compared to the sizes we are talking about
        return thickness
    }

    var roots = lineCrossingCircleRoots(radius + thickness, slope, radius)

    var x_pos;
    // We care about the root closest to zero, since that's the one not going through earth
    if (Math.abs(roots[0]) < Math.abs(roots[1])) {
        x_pos = roots[0]
    } else {
        x_pos = roots[1]
    }

    var y_pos = radius + slope * x_pos

    return Math.sqrt(x_pos*x_pos + Math.pow(y_pos - radius, 2))
}

function atmosphereAbsorptionExponent(altitude_angle) {
    return atmosphereDistance(earth_radius_km, atmosphere_absorption_thickness_km, altitude_angle) / atmosphere_absorption_thickness_km
}

function sunStrengthProjectionMultiplier(altitude_angle) {
    var multiplier = Math.sin(altitude_angle * d2r)
    return multiplier < 0 ? 0 : multiplier
}

function sunStrengthAbsorptionMultiplier(altitude_angle) {
    return atmosphere_base_absorption_rate ** atmosphereAbsorptionExponent(altitude_angle)
}

function sunStrengthOverallMultiplierAt(date, solar_hour, latitude) {
    let alti_azi = solarAngles(date, solar_hour, latitude)

    return sunStrengthOverallMultiplier(alti_azi[0])
}

function sunStrengthOverallMultiplier(altitude_angle) {
    return sunStrengthAbsorptionMultiplier(altitude_angle) * sunStrengthProjectionMultiplier(altitude_angle)
}

// altitude_angle is the angle of the sun off the ground.
function frameToShadowProjectionEffectMultiplier(altitude_angle) {
    var multiplier = 1 / Math.tan(altitude_angle * d2r)
    return multiplier < 0 ? 0 : multiplier
}

// Angle around the frame the north/west/etc effect
// offset_angle is the offset from being perpendicular to the sun. So if frame is lined up exactly, offset_angle is 0
function frameToShadowAzimuthEffectMultiplier(horizontal_offset_angle) {
    var multiplier = Math.sin((90 + horizontal_offset_angle) * d2r)
    return multiplier < 0 ? 0 : multiplier
}

function frameToShadowOverallMultiplier(altitude_angle, horizontal_offset_angle) {
    return frameToShadowProjectionEffectMultiplier(altitude_angle) * frameToShadowAzimuthEffectMultiplier(horizontal_offset_angle)
}

function overallSunStrengthThroughFrameMultiplierAt(date, solar_hour, latitude, frame_orientation_angle) {
    let alti_azi = solarAngles(date, solar_hour, latitude)

    return overallSunStrengthThroughFrameMultiplier(alti_azi[0], alti_azi[1], frame_orientation_angle)
}

function overallSunStrengthThroughFrameMultiplier(altitude_angle, azimuth_angle, frame_orientation_angle) {
    let orientation_offset = azimuth_angle - frame_orientation_angle

    return sunStrengthOverallMultiplier(altitude_angle) * frameToShadowOverallMultiplier(altitude_angle, orientation_offset);
}

function totalSunEnergyThroughWindowMultiplierAt(date, latitude, frame_orientation_angle) {
    let sum = 0
    hoursOfDayBy15MinsDataset(function(solar_hour) {
        sum += overallSunStrengthThroughFrameMultiplierAt(date, solar_hour, latitude, frame_orientation_angle)
    })

    // Dividing by 4 because the values are taken per 15 mins
    return sum / 4
}

// Not meant to be fully general. Expects the line to cross in 2 points. Returns the two roots
function lineCrossingCircleRoots(radius, line_slope, line_y_at_0) {
    // Line is y = ax + b
    var a = line_slope;
    var b = line_y_at_0;

    var r = radius;

    var plus_minus = Math.sqrt(4 * a*a * b*b - 4 * (1 + a*a) * (b*b - r*r))
    var first_part = -2 * a * b
    var divider = 2 + 2 * a*a

    return [(first_part + plus_minus) / divider, (first_part - plus_minus) / divider]
}

function daysOfYearDataset(func) {
    let data = []
    for (let i=1; i <= 365; i++) {
        data.push(func(new Date(2023, 0, i)))
    }
    return data
}

let days_of_year_labels = daysOfYearDataset(dateStringWithoutYear)

function ticksCallbackFirstOfEachMonth(value, index, ticks) {
    let label = this.getLabelForValue(value)
    if (label.startsWith('1 ') || label.startsWith('31 Dec')) {
        return label
    } else {
        return undefined
    }
}

function hoursOfDayBy15MinsDataset(func, wrap) {
    let data = []
    for (let i=0; i <= 95; i++) {
        data.push(func(i * 0.25))
    }

    if (wrap) {
        data.push(func(96))
    }
    return data
}


let hours_of_day_by_15_mins_labels = hoursOfDayBy15MinsDataset(hourStringFromHourFloat)

function hoursOfDayDataset(func, wrap) {
    let data = []
    for (let i=0; i <= 23; i++) {
        data.push(func(i))
    }

    if (wrap) {
        data.push(func(24))
    }

    return data
}

let hours_of_day_labels = hoursOfDayDataset(hourStringFromHourFloat)

function ticksCallbackRoundHours(value, index, ticks) {
    let label = this.getLabelForValue(value)
    if (label.endsWith('00')) {
        return label
    } else {
        return undefined
    }
}

function ticksCallbackRoundValues(value, index, ticks) {
    if (value < 10) {
        return Math.round(value * 100) / 100
    } else if (value < 10) {
        return Math.round(value * 10) / 10
    } else {
        return value
    }
}