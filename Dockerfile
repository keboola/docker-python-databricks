FROM python:3.8
ENV PYTHONIOENCODING utf-8

WORKDIR /home

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y --no-install-recommends \
        apt-transport-https ca-certificates wget dirmngr gnupg software-properties-common \
        ipython python-numpy python-matplotlib python-pandas python-scipy \
        msodbcsql17 mssql-tools unixodbc-dev \
    && rm -rf /var/lib/apt/lists/*

# Install OpenJDK 8
RUN wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add - \
    && add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/ \
    && apt update \
    && apt install -y adoptopenjdk-8-hotspot
ENV JAVA_HOME /usr/lib/jvm/adoptopenjdk-8-hotspot-amd64/
RUN export JAVA_HOME


ENV PATH $PATH:/opt/mssql-tools/bin

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
