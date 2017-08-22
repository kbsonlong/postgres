FROM centos:7
RUN rpm -ivh https://download.postgresql.org/pub/repos/yum/9.4/redhat/rhel-6-x86_64/pgdg-centos94-9.4-3.noarch.rpm

RUN yum install -y net-tools postgresql94 postgresql94-server wget gcc-c++ libpqxx-devel libpqxx postgresql-devel  make

RUN su - postgres -c '/usr/pgsql-9.4/bin/initdb'

RUN echo "listen_addresses='0.0.0.0'" >> /var/lib/pgsql/9.4/data/postgresql.conf

##安装pgpool
RUN wget -O /tmp/pgpool-II-3.3.4.tar.gz http://www.pgpool.net/download.php?f=pgpool-II-3.3.4.tar.gz
RUN cd /tmp && tar zxvf pgpool-II-3.3.4.tar.gz
RUN cd  /tmp/pgpool-II-3.3.4/ && mkdir -p /opt/pgpool && ./configure --prefix=/opt/pgpool/ --with-pgsql=/usr/pgsql-9.4/
RUN cd  /tmp/pgpool-II-3.3.4/ && make && make install


##安装pgpool函数
#RUN cd /tmp/pgpool-II-3.3.4/sql/pgpool-regclass/ && make && make install
#RUN cd /tmp/pgpool-II-3.3.4/sql/pgpool-recovery/ && make && make install
#RUN  su - postgres -c " nohup  /usr/pgsql-9.4/bin/postmaster -D '/var/lib/pgsql/9.4/data' &"  && su - postgres -c ' psql -c " create extension pgpool_regclass;create extension pgpool_recovery; " '

##安装supervisor
RUN yum install python-setuptools -y && easy_install  pip && pip install supervisor  -i http://mirrors.aliyun.com/pypi/simple  --trusted-host mirrors.aliyun.com

COPY supervisord.conf /etc/supervisord.conf

RUN mkdir /var/log/pgsql && chown postgres.postgres /var/log/pgsql -R

EXPOSE 5432

CMD ["supervisord", "-c", "/etc/supervisord.conf", "-n"]