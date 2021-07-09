FROM python:3.8
ENV PYTHONIOENCODING utf-8

WORKDIR /home

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update && ACCEPT_EULA=Y apt-get install -y --no-install-recommends \
        python-numpy \
        python-scipy \
        python-matplotlib \
        ipython \
        msodbcsql17 \
        mssql-tools \
        python-pandas \
        unixodbc-dev \
    && rm -rf /var/lib/apt/lists/*

ENV PATH $PATH:/opt/mssql-tools/bin

# Databricks needs Java 8
RUN echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" > /etc/apt/sources.list.d/webupd8team-java-trusty.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes --no-install-recommends oracle-java8-installer && apt-get clean all

RUN /usr/local/bin/python -m pip install --upgrade pip

# Install some commonly used packages and the Python application
RUN pip3 install --no-cache-dir --upgrade --force-reinstall \
        avro \
        azure-storage-blob==12.7.* \
        boto3 \
        fastavro \
        ipython \
        matplotlib \
        mlflow \
        numpy \
        pandas \
        pyodbc \
        scipy \
        scikit-learn \
        SQLAlchemy \
        git+git://github.com/keboola/sapi-python-client.git@0.1.3 \
    && pip3 install --no-cache-dir --upgrade --force-reinstall git+git://github.com/keboola/python-docker-application.git@2.1.1

# Import matplotlib the first time to build the font cache.
ENV XDG_CACHE_HOME /home/$NB_USER/.cache/
ENV MPLCONFIGDIR /home/$NB_USER/.cache/matplotlib
RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot"
