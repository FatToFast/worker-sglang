FROM lmsysorg/sglang:v0.5.9-cu129-amd64

WORKDIR /sgl-workspace

RUN pip install --no-cache-dir git+https://github.com/huggingface/transformers.git

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# copy source files
COPY handler.py engine.py utils.py download_model.py test_input.json ./
COPY public/ ./public/

# Setup for Option 2: Building the Image with the Model included
ARG MODEL_NAME=""
ARG TOKENIZER_NAME=""
ARG BASE_PATH="/runpod-volume"
ARG QUANTIZATION=""
ARG MODEL_REVISION=""
ARG TOKENIZER_REVISION=""

ENV MODEL_NAME=$MODEL_NAME \
    MODEL_REVISION=$MODEL_REVISION \
    TOKENIZER_NAME=$TOKENIZER_NAME \
    TOKENIZER_REVISION=$TOKENIZER_REVISION \
    BASE_PATH=$BASE_PATH \
    QUANTIZATION=$QUANTIZATION \
    HF_DATASETS_CACHE="${BASE_PATH}/huggingface-cache/datasets" \
    HUGGINGFACE_HUB_CACHE="${BASE_PATH}/huggingface-cache/hub" \
    HF_HOME="${BASE_PATH}/huggingface-cache/hub" \
    HF_HUB_ENABLE_HF_TRANSFER=1

RUN if [ -n "$MODEL_NAME" ]; then python3 download_model.py; fi

CMD ["python3", "handler.py"]
