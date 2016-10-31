# Dockerfile based on lamp container
FROM tutum/lamp:latest

MAINTAINER Kevin REMY <kevanescence@hotmail.fr>

# TODO : watch tutum/lamp ubuntu based version. Remove lines when not necessary
# Update php, ugly but tutum/lamp:latest is stuck to php5.5.9 (ubuntu trusty, 14.04)
RUN apt-get -y update && \
    apt-get -y install software-properties-common python-software-properties && \
    LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php5-5.6 && apt-get -y update  && \    
    apt-get -y install php5 curl php5-dev php5-curl php5-intl npm && \
    npm install -g bower && \
    service apache2 restart && \
    pecl install xdebug && \
    echo "zend_extension=$(find /usr/lib/php5/ -name xdebug.so)" >> /etc/php5/cli/php.ini 

ENV TESTED_CODE="/tested_code" CI_SERVER=1 CI_FROM_DOCKER=1

RUN mkdir /image /tested_code

###
EXPOSE 80

COPY . /image/

RUN chmod -R uo+x /image

CMD ["/image/launch.sh"]