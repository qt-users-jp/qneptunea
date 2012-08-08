import QNeptunea.Service 1.0

ServicePlugin {
    id: root
    service: '+ Pocket'
    icon: 'getpocket.png'

    property string api: 'https://readitlaterlist.com/v2/add'
    property string apikey: 'c95TIV28g7177l4f1bda1b9v7dp3q62b'

    function matches(url) {
        return settings.readData('getpocket.com/username', '').length > 0 && settings.readData('getpocket.com/password', '').length > 0
    }

    function open(link, parameters, feedback) {
        var username = settings.readData('getpocket.com/username', '')
        var password = settings.readData('getpocket.com/password', '')
        if (username.length == 0 || password.length == 0) {
            pageStack.push(settingsPage, {'state': 'plugins'})
            return
        }

        root.loading = true
        var url = api.concat('?apikey=').concat(apikey).concat('&username=').concat(username).concat('&password=').concat(password).concat('&url=').concat(link).concat('&title=').concat('@').concat(parameters.user.screen_name).concat(' ').concat(parameters.text)
        if (typeof parameters.id_str !== 'undefined')
            url = url.concat('&ref_id=').concat(parameters.id_str)
        var request = new XMLHttpRequest();
        request.open('GET', url);
        request.onreadystatechange = function() {
                    request.onreadystatechange = function() {
                                switch (request.readyState) {
                                case XMLHttpRequest.HEADERS_RECEIVED:
                                    break
                                case XMLHttpRequest.LOADING:
                                    break
                                case XMLHttpRequest.DONE: {
                                    root.result = (request.status == 200)
                                    if (root.result) {
                                        root.message = 'Done!'
                                    } else {
                                        root.message = request.responseText
                                    }
                                    root.loading = false
                                    break }
                                case XMLHttpRequest.ERROR: {
                                    root.result = false
                                    root.message = request.responseText
                                    root.loading = false
                                    break }
                                }
                            }
                }
        request.send();
    }
}
