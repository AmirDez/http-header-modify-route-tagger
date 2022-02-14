# Add HTTP header based on client Remote address

In a scenario we needed to add a custom http header to client http-request based on his IP address.

## NGINX

This can be accomplished in two ways: the short and easily accessible approach is spine up a NGINX server with config (`proxy.conf`) you may find in the nginx directory.
For more ease, you can run this command to run the new container for this propose.

You can find another config (`default.conf`) in the nginx directory which has a custom logging activated which will add this new custom HTTP header (`route-tag`) to the logs.
I used this config for testing the scenario.

```bash
docker run -it -v  proxy.conf:/etc/nginx/conf.d/default.conf --rm -d -p 8081:80 --name proxy nginx
```

`default.conf`

```bash

log_format  debug     '$remote_addr - $http_route_tag - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for" "$http_x_xsrf_token"';


server {
    .
    .

    access_log /var/log/nginx/access.log  debug;
    .
    .
```

## AWS Cloud Front by Terraform

But you may know about the limitations of this approach (scaling, CDN friendly, integrated in cloud...).
So you may find aws-terraform directory
Which will do the same in `AWS CDN CloudFront`. With a `Cloudfront function` for `Viewer request` the function is some line of code is JS as this is the default way to manipulate the HTTP Headers on the fly in CF.
I didn't use Lambda@Edge because of its price, and of course It was nice handled by `Cloudfront function`.
