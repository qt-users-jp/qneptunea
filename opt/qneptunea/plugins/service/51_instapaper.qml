import QNeptunea.Service 1.0

ServicePlugin {
    id: root
    service: 'Instapaper'
    icon: 'instapaper.png'

    property string api: 'https://www.instapaper.com/api/add'

    function matches(url) {
        return settings.readData('instapaper.com/username', '').length > 0 && settings.readData('instapaper.com/password', '').length > 0
    }

    function open(link, parameters) {
        var username = settings.readData('instapaper.com/username', '')
        var password = settings.readData('instapaper.com/password', '')
        if (username.length == 0 || password.length == 0) {
            pageStack.push(settingsPage, {'state': 'plugins'})
            return
        }

        root.loading = true
        var url = api.concat('?username=').concat(username).concat('&password=').concat(password).concat('&url=').concat(link)
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
                                    root.result = (request.status == 201)
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
