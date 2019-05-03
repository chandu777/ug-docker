FROM yep1/usergrid-java

RUN \
  cd /etc && \
  wget https://www.apache.org/dist/cassandra/2.1.21/apache-cassandra-2.1.21-bin.tar.gz && \
  tar xvzf apache-cassandra-2.1.21-bin.tar.gz && \
  rm -f apache-cassandra-2.1.21-bin.tar.gz && \
  mv /etc/apache-cassandra-2.1.21 /etc/cassandra

RUN sed -i'' 's/archive\.ubuntu\.com/\old-releases\.ubuntu\.com/' /etc/apt/sources.list
RUN \
  echo "+++ install python" && \
  apt-get update && \
  apt-get install -y python

ENV CASSANDRA_CONFIG /etc/cassandra

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh /docker-entrypoint.sh # backwards compat
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

RUN mkdir -p /var/lib/cassandra "$CASSANDRA_CONFIG" /var/log/cassandra
   # && chown -R cassandra:cassandra /var/lib/cassandra /var/log/cassandra "$CASSANDRA_CONFIG" \
   # && chmod 777 /var/lib/cassandra /var/log/cassandra "$CASSANDRA_CONFIG"

VOLUME /var/lib/cassandra

# 7000: intra-node communication
# 7001: TLS intra-node communication
# 7199: JMX
# 9042: CQL
# 9160: thrift service
EXPOSE 7000 7001 7199 9042 9160
CMD ["/etc/cassandra/bin/cassandra", "-f"]
