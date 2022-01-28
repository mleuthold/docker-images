FROM jupyter/pyspark-notebook:spark-3.2.0

# precaution against CVE-2021-44228 and CVE-2021-45046
ENV _JAVA_OPTIONS='-Dlog4j2.formatMsgNoLookups=true' JAVA_TOOLS_OPTIONS='-Dlog4j2.formatMsgNoLookups=true'

USER root

RUN echo "Installing handy tools" && \
    sudo apt update && sudo apt install -y vim curl \
    && rm -rf /var/lib/apt/lists/*

# ZSH installed
RUN sudo apt-get update && sudo apt-get install -y zsh \
    && rm -rf /var/lib/apt/lists/* \
    && usermod --shell /bin/zsh jovyan

ENV SHELL=/bin/zsh

# TASKFILE installed
RUN wget https://taskfile.dev/install.sh && bash install.sh -b /usr/local/bin

# Apache Spark dependencies
RUN wget https://repo1.maven.org/maven2/com/google/cloud/bigdataoss/gcs-connector/hadoop3-2.2.2/gcs-connector-hadoop3-2.2.2-shaded.jar --output-document=gcs-connector-hadoop3-2.2.2-shaded.jar && \
    mv gcs-connector-hadoop3-2.2.2-shaded.jar /usr/local/spark/jars/

RUN mkdir -p /opt/postgres/ && \
    wget https://repo1.maven.org/maven2/org/postgresql/postgresql/42.2.23/postgresql-42.2.23.jar --output-document=postgresql-42.2.23.jar && \
    mv postgresql-42.2.23.jar /opt/postgres/

USER $NB_UID

# ZSH configured
RUN sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)" "" --unattended \
    && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
    && sed -i.bak 's/^plugins=.*/plugins=(zsh-autosuggestions zsh-syntax-highlighting git task)/' $HOME/.zshrc \
    && THEME="ys"; sed -i s/^ZSH_THEME=".\+"$/ZSH_THEME=\"$THEME\"/g ~/.zshrc \
    && rm install.sh

# TASKFILE configured
RUN echo 'autoload -U compinit && compinit' >> ~/.zshrc \
    && git clone https://github.com/sawadashota/go-task-completions.git ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/task

# POETRY configured
ENV PATH="/home/jovyan/.local/bin:$PATH"
RUN curl -sSL https://install.python-poetry.org | python3 - \
    && mkdir -p ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/poetry \
    && poetry completions zsh >${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/poetry/_poetry

# Python dependencies
# COPY requirements.txt requirements.txt
# RUN pip install --no-cache-dir -r requirements.txt \
#     && rm requirements.txt

COPY poetry.toml $HOME/poetry.toml
COPY pyproject.toml $HOME/pyproject.toml
COPY poetry.lock $HOME/poetry.lock
RUN poetry install --no-root && rm $HOME/poetry.toml $HOME/pyproject.toml $HOME/poetry.lock

# configure Apache Spark
RUN echo :quit | spark-shell --conf spark.jars.packages=com.amazonaws:aws-java-sdk-bundle:1.12.31,org.apache.hadoop:hadoop-aws:3.2.2,com.google.cloud.spark:spark-bigquery-with-dependencies_2.12:0.22.0
COPY usr/local/spark/conf/spark-defaults.conf /usr/local/spark/conf/spark-defaults.conf
COPY usr/local/spark/conf/log4j.properties /usr/local/spark/conf/log4j.properties

# configure Jupyter lab
COPY --chown=jovyan:users .jupyter/jupyter_notebook_config.py $HOME/.jupyter/jupyter_notebook_config.py
COPY --chown=jovyan:users .config/jupytext/.jupytext $HOME/.config/jupytext/.jupytext
COPY --chown=jovyan:users opt/conda/share/jupyter/lab/settings/overrides.json /opt/conda/share/jupyter/lab/settings/overrides.json

# How to display more than just the last result in Jupyter cell?
# https://stackoverflow.com/questions/36786722/how-to-display-full-output-in-jupyter-not-only-last-result
COPY --chown=jovyan:users .ipython/profile_default/ipython_config.py $HOME/.ipython/profile_default/ipython_config.py
COPY --chown=jovyan:users .ipython/profile_default/ipython_kernel_config.py $HOME/.ipython/profile_default/ipython_kernel_config.py
