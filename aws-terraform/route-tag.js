function handler(event) {
    var request = event.request;
    var clientIP = event.viewer.ip;
    var routeTag = "B"
    if (clientIP == "84.152.79.126")
    {
        routeTag = "C"
    }
    
    //Add the true-client-ip header to the incoming request
    request.headers['route-tag'] = {value: routeTag};

    return request;
}