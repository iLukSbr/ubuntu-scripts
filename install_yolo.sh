#!/usr/bin/env bash
set -euo pipefail

python3 -m pip install --upgrade pip
pip3 install -U \
    testresources \
    numpy \
    pyzbar \
    pyzxing \
    opencv-contrib-python \
    matplotlib \
    pandas \
    scipy \
    scikit-image \
    pillow \
    pycolornames \
    openvino \
    tensorflow \
    gradio-imageslider \
    gradio \
    tqdm \
    albumentations \
    flake8 \
    py-cpuinfo \
    timm \
    huggingface-hub \
    pytest \
    easyocr \
    pytesseract \
    transformers \
    ultralytics[export]

# Check for NVIDIA GPU
if ! command -v nvidia-smi &> /dev/null || ! nvidia-smi &> /dev/null; then
    echo "NVIDIA GPU not detected. Skipping GPU-specific installations."
    exit 0
fi

pip3 uninstall -y torch torchvision tensorflow
pip3 install -U nvidia-cuda-runtime nvidia-mathdx onnxruntime-gpu
pip3 install --pre torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/nightly/cu130
pip3 install -U tensorrt --no-deps
