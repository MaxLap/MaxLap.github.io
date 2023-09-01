function dayOfYear(date) {
    return (Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()) - Date.UTC(date.getFullYear(), 0, 0)) / 24 / 60 / 60 / 1000
}

function dateStringWithoutYear(date) {
    return date.getDate() + ' ' + date.toLocaleString('en-US', { month: 'long'})
}

function hourStringFromHourFloat(hour_float) {
    var minutes_part_float = hour_float % 1
    var minutes_part_int = Math.round(minutes_part_float * 60)

    if (minutes_part_int == 0) {
        minutes_part_int = '00'
    }

    return Math.round(hour_float - minutes_part_float) + ':' + minutes_part_int
}

function dupMergeOptions(base, _extra_vararg) {
    let result = _.cloneDeep(base)

    for (var i = 1; i < arguments.length; i++) {
        _.mergeWith(result, arguments[i], function(existingValue, newValue) {
            if (_.isArray(existingValue)) {
                return newValue;
            }
        })
    }

    return result
}


function refreshableArray(func, infos) {
    let data = func(infos)
    data.refresh_func = func

    return data
}

function refreshArray(refreshable_array) {
    let new_content = refreshable_array.refresh_func()
    for (var i = 0; i < refreshable_array.length; i++) {
        refreshable_array[i] = new_content[i]
    }
}

function updateRefreshableCharts() {
    Chart.helpers.each(Chart.instances, function(chart) {
        let datasets = chart.data.datasets
        let updated_something = false

        for (var i = 0; i < datasets.length; i++) {
            let chart_data = datasets[i].data
            if (!chart_data.refresh_func) {
                continue
            }
            refreshArray(chart_data)
            updated_something = true
        }

        if (updated_something) {
            chart.config._config.options.animation = true
            chart.update()
        }
    })
}
