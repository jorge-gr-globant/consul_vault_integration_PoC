FROM redis:6.0-rc1
ADD rejson.so /usr/rejson.so
RUN chmod +x /usr/rejson.so
COPY redis.conf /usr/local/etc/redis/redis.conf
COPY commands.txt /usr/commands.txt
CMD [ "redis-server", "/usr/local/etc/redis/redis.conf" ]
