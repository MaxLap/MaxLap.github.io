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


// Credits to https://stackoverflow.com/a/47203743
// Add Fisher-Yates shuffle method to Javascript's Array type, using
// window.crypto.getRandomValues as a source of randomness.
if (Uint8Array && window.crypto && window.crypto.getRandomValues) {
    console.log("hi")
    Array.prototype.cryptoShuffle = function() {
        var n = this.length;

        // If array has <2 items, there is nothing to do
        if (n < 2) return this;
        // Reject arrays with >= 2**31 items
        if (n > 0x7fffffff) throw "ArrayTooLong";

        var i, j, r=n*2, tmp, mask;
        // Fetch (2*length) random values
        var rnd_words = new Uint32Array(r);
        // Create a mask to filter these values
        for (i=n, mask=0; i; i>>=1) mask = (mask << 1) | 1;

        // Perform Fisher-Yates shuffle
        for (i=n-1; i>0; i--) {
            if ((i & (i+1)) == 0) mask >>= 1;
            do {
                if (r == n*2) {
                    // Refresh random values if all used up
                    window.crypto.getRandomValues(rnd_words);
                    r = 0;
                }
                j = rnd_words[r++] & mask;
            } while (j > i);
            tmp = this[i];
            this[i] = this[j];
            this[j] = tmp;
        }
        return this;
    }
} else {
    Array.prototype.cryptoShuffle = function() {
        throw "Unsupported browser"
    }
}