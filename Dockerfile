# Dockerfile based on lamp container
FROM tutum/lamp:latest

MAINTAINER Kevin REMY <kevanescence@hotmail.fr>

# TODO : watch tutum/lamp ubuntu based version. Remove lines when not necessary
# Update php, ugly but tutum/lamp:latest is stuck to php5.5.9 (ubuntu trusty, 14.04)
RUN apt-get -y update && \
    apt-get -y install software-properties-common python-software-properties && \
    LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php && apt-get -y update  && \    
    apt-get -y install php5.6 curl php5.6-dev php5.6-curl php5.6-intl php5.6-mysql && \
    curl -sL https://deb.nodesource.com/setup_7.x | bash - && \
    apt-get install nodejs && \
    npm install -g bower && \
    service apache2 restart && \
    apt-get -y install php5.6-xml && \
    pecl install xdebug && \
    echo "zend_extension=$(find /usr/lib/php/ -name xdebug.so)" >> /etc/php/5.6/cli/php.ini 

ENV TESTED_CODE="/tested_code" CI_SERVER=1 CI_FROM_DOCKER=1

RUN mkdir /image /tested_code

###
EXPOSE 80

COPY . /image/

RUN chmod -R uo+x /image

CMD ["/image/launch.sh"]
