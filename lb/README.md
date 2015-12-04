##nginx
```Dockerfile
FROM nginx

RUN rm /etc/nginx/conf.d/default.conf

RUN rm /etc/nginx/conf.d/examplessl.conf

COPY content /usr/share/nginx/html

COPY conf /etc/nginx
```


docker build -t mynginximage1 .

##nginx-content

```Dockerfile
FROM nginx

 COPY content /usr/share/nginx/html

 COPY conf /etc/nginx

 VOLUME /usr/share/nginx/html

 VOLUME /etc/nginx
```

 docker build -t mynginximage2 .