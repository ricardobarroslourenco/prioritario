FROM rapidsai/base:26.02-cuda13-py3.13-amd64
LABEL authors="Ricardo Barros Lourenco"

# --- 1. Dependências do Sistema (apt-get) ---
USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    nano \
    && rm -rf /var/lib/apt/lists/*

# --- 2. Dependências Conda/Mamba (Recomendado) ---
# Mudamos para o usuário 'rapids' para usar o ambiente Conda corretamente
USER rapids

# Usamos 'mamba' (mais rápido que conda) para instalar pacotes do canal conda-forge ou nvidia
# Exemplo: instalando scikit-learn e matplotlib via conda
RUN mamba install -y -n base \
    scikit-learn \
    matplotlib \
    jupyterlab \
    && mamba clean -ya

# --- 3. Dependências Python (pip) ---
# Use pip apenas para pacotes que não estão disponíveis no Conda ou se preferir
RUN pip install --upgrade pip && \
    pip install --no-cache-dir \
    torch \
    torchvision \
    --index-url https://download.pytorch.org/whl/cu130

# --- Configuração de Execução ---
WORKDIR /app

# O ENTRYPOINT da imagem base já carrega o ambiente Conda.
# CMD define o comando padrão. Para batch, você sobrescreve isso ao rodar o container.
# Ex: docker run minha-imagem python meu_script.py
CMD ["/bin/bash"]