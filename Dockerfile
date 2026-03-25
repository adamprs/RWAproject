FROM node:18

WORKDIR /app

COPY . .

RUN apt-get update && \
    apt-get install -y python3 python3-pip python3-venv git curl && \
    pip install pipx --break-system-packages && \
    pipx ensurepath && \
    apt-get install -y graphviz && \
    chmod +x shell/foundryup.sh && bash shell/foundryup.sh

ENV PATH="/root/.cargo/bin:${PATH}"
    
CMD ["bash"]