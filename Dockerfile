FROM huggingface/transformers-pytorch-gpu:latest
# Nota - Para build a partir de MacOS : FROM --platform=linux/amd64 huggingface/transformers-pytorch-gpu:latest

# Bash como shell padrão
ENV SHELL=/bin/bash

ENV DEBIAN_FRONTEND noninteractive

# Dependências SO
RUN  apt-get update && apt-get install -y --no-install-recommends apt-utils \
    vim \
    nano \
    git \
    cmake \
    build-essential

RUN pip install --upgrade pip
RUN pip install uv

# Dependências python, via requirements
COPY requirements.txt .
RUN uv pip install --system -r requirements.txt

# Congela versionamento de ambiente para reprodutibilidade
RUN pip freeze > $(date +%Y-%m-%d)_requirements_instalado.txt
RUN apt list --installed > $(date +%Y-%m-%d)_ambiente_apt_instalado.txt

# Expõe portas do Jupyter (8888) e Dask (8787, 8686)
EXPOSE 8888 8787 8686

# Inicia o Jupyter Lab como processo principal - caso não rodando jupyter (ex. batch jobs), usar CMD ["/bin/bash"]
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--allow-root", "--no-browser"]