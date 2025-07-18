FROM nvidia/cuda:12.2.2-devel-ubuntu22.04

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc-11 g++-11 \
    vim wget cmake git libeigen3-dev libjpeg-dev libpng-dev

# Install Miniforge
RUN wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -O Miniforge3.sh && \
    bash Miniforge3.sh -b -p /opt/miniforge3 && \
    rm Miniforge3.sh

# Set environment variables
ENV PATH="/opt/miniforge3/bin:$PATH"
ENV PATH="/usr/local/cuda-12.2/bin:$PATH"
ENV LD_LIBRARY_PATH="/usr/local/cuda-12.2/lib64:$LD_LIBRARY_PATH"
ENV CC=/usr/bin/gcc-11
ENV CXX=/usr/bin/g++-11
ENV CONDA_PREFIX=/opt/miniforge3

# Install Python environment and MoSDeF stack
RUN /opt/miniforge3/bin/conda install -n base -c conda-forge -c omnia \
      cmake=3.28 python=3.8.19 signac=1.7.0 signac-flow=0.21.0 py3Dmol \
      nglview openbabel=3.1.1 mbuild=0.10.5 jupyter mdanalysis=2.4.3 \
      mdtraj=1.9.7 numpy=1.24.4 pandas=1.4.4 scikit-learn=1.3.2 \
      scipy=1.10.1 unyt=2.9.5 -y && \
    /opt/miniforge3/bin/pip install foyer==0.7.6 pyyaml panedr==0.7.2

# Build GROMACS 2023.2
RUN git clone https://github.com/gromacs/gromacs.git && \
    cd gromacs && \
    git checkout v2023.2 && \
    git reset --hard HEAD && \
    git clean -fdx && \
    sed -i 's/^#define STRLEN 4096/#define STRLEN 131072/' src/gromacs/utility/include/gromacs/utility/cstringutil.h && \
    mkdir build && cd build && \
    cmake .. \
      -DGMX_BUILD_OWN_FFTW=ON \
      -DGMX_GPU=CUDA \
      -DCUDA_ARCHITECTURES="80;90" \
      -DGMX_DOUBLE=OFF \
      -DGMX_MPI=OFF \
      -DCMAKE_INSTALL_PREFIX=$CONDA_PREFIX \
      -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc) && \
    make install

# Activate bash + conda and set default shell
SHELL ["/bin/bash", "--login", "-c"]

# Set CMD for interactive use
CMD [ "/bin/bash" ]
