.pragma library

var httpPattern = new RegExp(/^http:\/\/[-_.!~*'()a-zA-Z0-9;/?:@&=+$,%#]+$/)
var httpsPattern = new RegExp(/^https:\/\/[-_.!~*'()a-zA-Z0-9;/?:@&=+$,%#]+$/)

function count(text, max, http_length, https_length) {
    var length = max - text.length
    var chunk = text.split(/[^-_.!~*'()a-zA-Z0-9;/?:@&=+$,%#]/)
//    console.debug(chunk)
    for (var i = 0; i < chunk.length; i++) {
        var http = httpPattern.exec(chunk[i]);
        if (http !== null) {
            length = length + http[0].length - http_length
        }
        var https = httpsPattern.exec(chunk[i]);
        if (https !== null) {
            length = length + https[0].length - https_length
        }
    }

    return length
}
