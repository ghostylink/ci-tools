# Dockerfile based on lamp container
FROM tutum/lamp:latest

MAINTAINER Kevin REMY <kevanescence@hotmail.fr>

# TODO : watch tutum/lamp ubuntu based version. Remove lines when not necessary
# Update php, ugly but tutum/lamp:latest is stuck to php5.5.9 (ubuntu trusty, 14.04)
RUN apt-get -y update && \
    apt-get -y install software-properties-common python-software-properties && \
    LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php5-5.6 && \
    apt-get -y update && \
    apt-get -y install php5 

RUN apt-get update && apt-get -y install curl php5-curl php5-intl && service apache2 restart

ENV TESTED_CODE="/tested_code"

RUN mkdir /image /tested_code

# Installing composer globally
RUN mkdir /etc/composer/ && cd /etc/composer/ \
      && curl -s https://getcomposer.org/installer | php \
      && echo "#!/bin/bash\n/etc/composer/composer.phar \$@\n" >> /bin/composer \
      && chmod 755 /bin/composer

# Installing a global ant command targeting the testing code
RUN echo "#!/bin/bash -e\n(cd $TESTED_CODE; ./vendor/bin/phing \$@)" >> /bin/ant \
    && chmod 755 /bin/ant

### PUT additional requirement here

###

COPY . /image/

RUN chmod -R u+x /image

EXPOSE 80
CMD ["/image/launch.sh"]