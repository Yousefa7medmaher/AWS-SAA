FROM nginx:1.29-alpine

RUN rm -rf /usr/share/nginx/html/*

COPY ./index.html /usr/share/nginx/html/

COPY nginx.conf /etc/nginx/nginx.conf

RUN addgroup -S nginxgroup && \
    adduser -S nginxuser -G nginxgroup && \
    chown -R nginxuser:nginxgroup \
        /usr/share/nginx/html \
        /var/cache/nginx \
        /tmp

USER nginxuser

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s \
CMD wget --spider http://localhost:8080 || exit 1

CMD ["nginx", "-g", "daemon off;"]