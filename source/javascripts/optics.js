
window.Path = paper.Path
window.Point = paper.Point
window.PointText = paper.PointText
window.Shape = paper.Shape
window.Size = paper.Size

window.pixelToMeter = function(paper, pixels) {
    return pixels / paper.view.viewSize.width * 4.5
}

window.meterToPixel = function(paper, meters) {
    return meters / 4.5 * paper.view.viewSize.width
}

window.makeDiopterRuler = function(paper, centerY, nb_meters, diopter_interval, max_diopter) {
    let width = meterToPixel(paper, nb_meters)

    new Path.Line(new Point(0, centerY), new Point(width, centerY));
    let units_done = false;

    for (var d = diopter_interval; d <= max_diopter; d += diopter_interval) {
        var x = meterToPixel(paper, 1) * 1 / d
        new Path.Line(new Point(x, centerY - 10), new Point(x, centerY + 10));

        if (!units_done) {
            let x2 = meterToPixel(paper, 1) * 1 / (d - diopter_interval)

            var label = new PointText(new Point((x + x2) / 2, centerY + 15))
            if (x2 - x < 50) {
                label.content = '...'
                units_done = true
            } else {
                label.content = diopter_interval.toFixed(2) + 'dpt'
            }

            label.justification = 'center'
        }
    }
}

window.makeMeterRuler = function(paper, centerY, nb_meters) {
    let width = meterToPixel(paper, nb_meters)
    let meter_in_pixels = meterToPixel(paper, 1)

    new Path.Line(new Point(0, centerY), new Point(width, centerY));
    for (var x = 0; x <= width; x += meter_in_pixels) {
        new Path.Line(new Point(x, centerY - 10), new Point(x, centerY + 10));
        var label = new PointText(new Point(x, centerY + 20))
        label.content = (x / meter_in_pixels).toFixed(0) + 'm'
        label.justification = 'center'
    }
}

window.shiftMeterByDiopter = function(meter, diopter) {
    var meter_as_diopter = (1.0 / meter)
    var final_diopter = meter_as_diopter + diopter
    if (final_diopter <= 0) {
        return 100
    }

    final_meter = 1.0 / final_diopter
    if (final_meter > 100) {
        final_meter = 100
    }
    return final_meter
}

window.shiftPixelByDiopter = function(paper, pixel_center, diopter) {
    return meterToPixel(paper, shiftMeterByDiopter(pixelToMeter(paper, pixel_center), diopter))
}

window.makeVisionArea = function(paper, diopter_area_layer, y, height, color) {
    var rect = new Shape.Rectangle(new Point(-100, y), new Size(0, height));
    rect.fillColor = color;
    diopter_area_layer.addChild(rect)
    return rect
}

window.updateVisionAreaWithShiftPixelByDiopter = function(paper, rectangle, x, diopter1, diopter2) {
    let x1 = shiftPixelByDiopter(paper, x, diopter1)
    let x2 = shiftPixelByDiopter(paper, x, diopter2)

    rectangle.size.width = Math.abs(x2 - x1)
    rectangle.position.x = (x2 + x1) / 2

    return [x1, x2]
}

window.updateVisionAreaSetMeters = function(paper, rectangle, meter1, meter2) {
    let x1 = meterToPixel(paper, meter1)
    let x2 = meterToPixel(paper, meter2)

    rectangle.size.width = Math.abs(x1 - x2)
    rectangle.position.x = (x2 + x1) / 2

    return [x1, x2]
}
