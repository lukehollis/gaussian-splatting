FROM nvidia/cuda:11.8.0-devel-ubuntu20.04

# Set the working directory
WORKDIR /app

# Set DEBIAN_FRONTEND to noninteractive to prevent prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    ninja-build \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh
ENV PATH /opt/conda/bin:$PATH

# Copy the project files
COPY . .

# Accept Conda Terms of Service 
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

# Set the CUDA architecture list for PyTorch
ENV TORCH_CUDA_ARCH_LIST="7.0 7.5 8.0 8.6"

# Create the conda environment
RUN conda env create -f environment.yml

# Replace standard OpenCV with opencv-python-headless 
RUN conda run -n gaussian_splatting /bin/bash -c "pip uninstall opencv-python -y && pip install opencv-python-headless"

# Activate the conda environment
SHELL ["conda", "run", "-n", "gaussian_splatting", "/bin/bash", "-c"]

# Expose the port for the viewer
EXPOSE 6009

# Set the default command to keep the container running
CMD ["/bin/bash"]
