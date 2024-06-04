# Use Nvidia CUDA base image
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04 as base

# Prevents prompts from packages asking for user input during installation
ENV DEBIAN_FRONTEND=noninteractive
# Prefer binary wheels over source distributions for faster pip installations
ENV PIP_PREFER_BINARY=1
# Ensures output from python is printed immediately to the terminal without buffering
ENV PYTHONUNBUFFERED=1 

# Install Python, git and other necessary tools
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3-pip \
    git \
    wget

# Clean up to reduce image size
RUN apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Clone ComfyUI repository
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /comfyui

# Change working directory to ComfyUI
WORKDIR /comfyui

# Install ComfyUI dependencies
RUN pip3 install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 \
    && pip3 install --no-cache-dir xformers==0.0.21 \
    && pip3 install -r requirements.txt

# Install runpod
RUN pip3 install runpod requests


# Download checkpoints
RUN wget -O models/checkpoints/dreamshaperXL_sfwLightningDPMSDE.safetensors https://eventstationai.sharepoint.com/:u:/s/Eventstation.ai2/EQozqPH84cJBqQHMFxkT9-YBRIW3-lp46iQd0h7lxspcJg?download=1
# Download controlnet
RUN mkdir -p models/controlnet
RUN wget -O models/controlnet/control-lora-openposeXL2-rank256.safetensors https://eventstationai.sharepoint.com/:u:/s/Eventstation.ai2/EfDcRbCjosBLkVXyt2uUgxkBGgeAEmfPgOJrrGNr0i6kIw?download=1
# Download VAE
RUN wget -O models/vae/sdxl_vae.safetensors https://huggingface.co/stabilityai/sdxl-vae/resolve/main/sdxl_vae.safetensors
RUN wget -O models/vae/sdxl-vae-fp16-fix.safetensors https://huggingface.co/madebyollin/sdxl-vae-fp16-fix/resolve/main/sdxl_vae.safetensors

# Custom Nodes
WORKDIR /comfyui/custom_nodes
# # ComfyUI-Manager
RUN git clone --quiet https://github.com/ltdrdata/ComfyUI-Manager
# # ComfyUI-Impact-Pack
RUN git clone --quiet https://github.com/ltdrdata/ComfyUI-Impact-Pack
WORKDIR /comfyui/custom_nodes/ComfyUI-Impact-Pack
RUN pip3 install -r requirements.txt
WORKDIR /comfyui/custom_nodes
# # comfyui_controlnet_aux
RUN git clone --quiet https://github.com/Fannovel16/comfyui_controlnet_aux
# ## efficiency-nodes-comfyui
# RUN git clone --quiet https://github.com/jags111/efficiency-nodes-comfyui
# # # Derfuu_ComfyUI_ModdedNodes
# RUN git clone --quiet https://github.com/Derfuu/Derfuu_ComfyUI_ModdedNodes
# # was-node-suite-comfyui
RUN git clone --quiet https://github.com/WASasquatch/was-node-suite-comfyui
# # ComfyUI-Vextra-Nodes
# RUN git clone --quiet https://github.com/diontimmer/ComfyUI-Vextra-Nodes
# # masquerade-nodes-comfyui
RUN git clone --quiet https://github.com/BadCafeCode/masquerade-nodes-comfyui
# # ComfyUI-Custom-Scripts
RUN git clone --quiet https://github.com/pythongosssss/ComfyUI-Custom-Scripts
# # ComfyUI-Allor
RUN git clone --quiet https://github.com/Nourepide/ComfyUI-Allor
# # ComfyUI_Comfyroll_CustomNodes
RUN git clone --quiet https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes
# # ComfyUI_IPAdapter_plus
RUN git clone --quiet https://github.com/cubiq/ComfyUI_IPAdapter_plus
# # # add ip adapter models
# # # # CLIPVISION
WORKDIR /comfyui/models/clip_vision
RUN wget -q -O CLIP-ViT-H-14-laion2B-s32B-b79K.safetensors https://huggingface.co/h94/IP-Adapter/resolve/main/models/image_encoder/model.safetensors
RUN wget -q -O CLIP-ViT-bigG-14-laion2B-39B-b160k.safetensors https://huggingface.co/h94/IP-Adapter/resolve/main/sdxl_models/image_encoder/model.safetensors
# # # # ipadapter
WORKDIR /comfyui/models/ipadapter
RUN wget -q https://huggingface.co/h94/IP-Adapter/resolve/main/sdxl_models/ip-adapter_sdxl_vit-h.safetensors
RUN wget -q https://huggingface.co/h94/IP-Adapter/resolve/main/sdxl_models/ip-adapter-plus_sdxl_vit-h.safetensors
RUN wget -q https://huggingface.co/h94/IP-Adapter/resolve/main/sdxl_models/ip-adapter-plus-face_sdxl_vit-h.safetensors
RUN wget -q https://huggingface.co/h94/IP-Adapter/resolve/main/sdxl_models/ip-adapter_sdxl.safetensors

WORKDIR /comfyui/custom_nodes
# # # comfyui-reactor-node
# RUN git clone --quiet https://github.com/Gourieff/comfyui-reactor-node
# WORKDIR /comfyui/custom_nodes/comfyui-reactor-node
# RUN pip3 install -r requirements.txt
# WORKDIR /comfyui/custom_nodes
# # ComfyUI_Ib_CustomNodes
# RUN git clone --quiet https://github.com/Chaoses-Ib/ComfyUI_Ib_CustomNodes
# # # rgthree-comfy
# RUN git clone --quiet https://github.com/rgthree/rgthree-comfy
# # # ComfyUI-SDXL-EmptyLatentImage
# RUN git clone --quiet https://github.com/shingo1228/ComfyUI-SDXL-EmptyLatentImage
# # # comfyui-tooling-nodes
# RUN git clone --quiet https://github.com/Acly/comfyui-tooling-nodes
# # # comfyui-job-iterator
# RUN git clone --quiet https://github.com/ali1234/comfyui-job-iterator
# # # comfyui_segment_anything
# RUN git clone --quiet https://github.com/storyicon/comfyui_segment_anything
# WORKDIR /comfyui/custom_nodes/comfyui_segment_anything
# RUN pip3 install -r requirements.txt
# WORKDIR /comfyui/custom_nodes
# # # ComfyUI-Text_Image-Composite
# RUN git clone --quiet https://github.com/ZHO-ZHO-ZHO/ComfyUI-Text_Image-Composite
# # # TheLastBens Multimasker
# RUN wget -q https://eventstationai.sharepoint.com/:u:/s/Eventstation.ai2/EWaDzKVb19RMvGQZR5XDaGMBgZ4nmFoDxabLCpL7ZVDILg?download=1


# Go back to the root
WORKDIR /

# Add the start and the handler
ADD src/start.sh src/rp_handler.py test_input.json ./
RUN chmod +x /start.sh

# Start the container
CMD /start.sh
