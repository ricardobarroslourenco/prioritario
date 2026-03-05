# ==============================================================================
# 1. IMAGEM BASE
# ==============================================================================
# Utilizamos a imagem oficial da Hugging Face com suporte a PyTorch e GPU.
# Esta imagem já contém drivers CUDA e bibliotecas de Deep Learning pré-instaladas.
FROM huggingface/transformers-pytorch-gpu:latest
# Nota - Para build a partir de MacOS (Apple Silicon), use a flag --platform=linux/amd64
# pois as imagens de GPU geralmente são x86_64.

# ==============================================================================
# 2. CONFIGURAÇÃO DO AMBIENTE
# ==============================================================================
# Define o Bash como shell padrão para os comandos RUN subsequentes.
ENV SHELL=/bin/bash

# Evita que o apt-get faça perguntas interativas durante a instalação (ex: fuso horário).
ENV DEBIAN_FRONTEND noninteractive

# ==============================================================================
# 3. DEPENDÊNCIAS DO SISTEMA (APT-GET)
# ==============================================================================
# Atualiza os repositórios e instala pacotes essenciais do sistema operacional.
# - 'apt-utils': Utilitários para configuração de pacotes.
# - 'vim/nano': Editores de texto para debug dentro do container.
# - 'git/cmake/build-essential': Ferramentas para compilar pacotes Python que requerem C/C++.
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-utils \
    vim \
    nano \
    git \
    cmake \
    build-essential \
    && rm -rf /var/lib/apt/lists/*  # Limpa o cache do apt para reduzir o tamanho da imagem

# ==============================================================================
# 4. GERENCIAMENTO DE PACOTES PYTHON
# ==============================================================================
# Atualiza o pip para a versão mais recente.
RUN pip install --upgrade pip

# Instala o 'uv', um instalador de pacotes Python extremamente rápido (substituto do pip).
RUN pip install uv

# Copia o arquivo de requisitos do host para dentro da imagem.
COPY requirements.txt .

# Instala as dependências listadas no requirements.txt usando o 'uv'.
# - '--system': Instala no ambiente Python do sistema (não cria venv), o que é comum em Docker.
RUN uv pip install --system -r requirements.txt

# Instala monitoracao de GPU (pacote NVIDIA)
RUN uv pip install --extra-index-url https://pypi.anaconda.org/rapidsai-wheels-nightly/simple --pre jupyterlab_nvdashboard

# ==============================================================================
# 5. RASTREABILIDADE E VERSIONAMENTO
# ==============================================================================
# Gera arquivos de texto com a lista exata de pacotes instalados (Python e Sistema).
# Isso é crucial para reproduzir o ambiente exato no futuro caso a imagem base mude.
# O comando usa a data atual no nome do arquivo.
RUN pip freeze > $(date +%Y-%m-%d)_requirements_instalado.txt
RUN apt list --installed > $(date +%Y-%m-%d)_ambiente_apt_instalado.txt

# ==============================================================================
# 6. EXPOSIÇÃO DE PORTAS E EXECUÇÃO
# ==============================================================================
# Documenta as portas que o container escutará.
# - 8888: Jupyter Lab
# - 8787, 8686: Dashboards do Dask (computação distribuída)
EXPOSE 8888 8787 8686

# Define o comando padrão ao iniciar o container.
# Por padrão, inicia o Jupyter Lab para desenvolvimento interativo.
#
# PARA EXECUÇÃO EM BATCH (PRODUÇÃO):
# Sobrescreva este comando ao rodar o container, ou altere aqui para:
# CMD ["python", "seu_script.py"] ou CMD ["/bin/bash"]
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--allow-root", "--no-browser"]