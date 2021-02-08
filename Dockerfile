FROM neurodebian:stretch

ARG DEBIAN_FRONTEND="noninteractive"

RUN   apt-get update
#%post
#sed -i 's/main/main restricted universe/g' /etc/apt/sources.list
RUN  apt-get update
# Install 
RUN apt-get install -y  libopenblas-dev  libcurl4-openssl-dev libopenmpi-dev openmpi-bin openmpi-common openmpi-doc openssh-client openssh-server libssh-dev wget  git vim nano gfortran g++ curl autoconf bzip2 libtool libtool-bin   libxml2 libxml2-dev bzip2 libtool libtool-bin python python-pip python-dev fort77 libreadline-dev build-essential  libc6-dev zip unzip


RUN apt-get update

RUN apt-get clean
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

#install main R 3.2.5
RUN bash -c 'wget https://cran.rstudio.com/src/base/R-3/R-3.2.5.tar.gz'
RUN bash -c 'tar xvf R-3.2.5.tar.gz'
RUN bash -c 'cd R-3.2.5 && bash configure --with-x=no  && make && make install'



RUN bash -c 'cd /'

RUN apt-get update

RUN apt-get clean

RUN  bash -c 'wget https://cran.r-project.org/src/contrib/RhpcBLASctl_0.18-205.tar.gz && tar xvf RhpcBLASctl_0.18-205.tar.gz && R CMD INSTALL RhpcBLASctl'

RUN   R --slave -e 'install.packages(c("codetools", "foreach", "doMC", "getopt", "optparse","knitr","biganalytics", "bigmemory.sri", "testthat"), repos="http://cran.us.r-project.org")'
RUN   R --slave -e 'install.packages(c("plyr", "Rcpp","inline","devtools"), dependencies=TRUE, repos="http://cran.us.r-project.org")'
RUN  apt-get update

RUN   apt-get clean
RUN  bash -c 'git clone https://github.com/czarrar/bigmemory.git && R CMD INSTALL bigmemory' 
RUN  bash -c 'wget https://cran.r-project.org/src/contrib/Archive/RcppArmadillo/RcppArmadillo_0.5.600.2.0.tar.gz && tar xvf RcppArmadillo_0.5.600.2.0.tar.gz && R CMD INSTALL RcppArmadillo'
RUN  bash -c 'git clone https://github.com/czarrar/bigalgebra.git && R CMD INSTALL bigalgebra'
RUN  bash -c 'git clone https://github.com/czarrar/bigextensions.git && R CMD INSTALL bigextensions'
RUN  bash -c 'wget https://www.dropbox.com/s/tq386h378qls3ch/niftir.zip && unzip niftir.zip && R CMD INSTALL niftir'
RUN bash -c 'git clone https://github.com/czarrar/connectir.git && R CMD INSTALL connectir' 


ENV  bidnr=/usr/local/bin

RUN   bash -c 'cp connectir/inst/scripts/*.R  $bidnr/ && rm -f $bidnr/*_worker.R && chmod +x $bidnr/*.R'

RUN  bash -c 'rm -rf connectir RcppArmadillo* RhpcBLASctl* R-3.2.5* bigmemory bigextensions bigalgebra'

RUN  bash -c 'wget https://www.dropbox.com/s/uer0tgjrz79r01m/cluste.zip && unzip cluste.zip && mv cluste/* $bidnr/ && chmod +x $bidnr/*R ' 




ENV FSLDIR="/opt/fsl-5.0.10" \
    PATH="/opt/fsl-5.0.10/bin:$PATH"
RUN apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           bc \
           git \
           wget \
           dc \
           file \
           libfontconfig1 \
           libfreetype6 \
           libgl1-mesa-dev \
           libglu1-mesa-dev \
           libgomp1 \
           libice6 \
           libmng1 \
           libxcursor1 \
           libxft2 \
           libxinerama1 \
           libxrandr2 \
           libxrender1 \
           libxt6 \
           wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && echo "Downloading FSL ..." \
    && mkdir -p /opt/fsl-5.0.10 \
    && curl -fsSL --retry 5 https://fsl.fmrib.ox.ac.uk/fsldownloads/fsl-5.0.10-centos6_64.tar.gz \
    | tar -xz -C /opt/fsl-5.0.10 --strip-components 1 \
    && sed -i '$iecho Some packages in this Docker container are non-free' $ND_ENTRYPOINT \
    && sed -i '$iecho If you are considering commercial use of this container, please consult the relevant license:' $ND_ENTRYPOINT \
    && sed -i '$iecho https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/Licence' $ND_ENTRYPOINT \
    && sed -i '$isource $FSLDIR/etc/fslconf/fsl.sh' $ND_ENTRYPOINT \
    && echo "Installing FSL conda environment ..." \
    && bash /opt/fsl-5.0.10/etc/fslconf/fslpython_install.sh -f /opt/fsl-5.0.10


RUN bash -c "FSLDIR=/opt/fsl-5.0.10"

ENV PATH="/opt/afni-latest:$PATH" \
    AFNI_PLUGINPATH="/opt/afni-latest"
RUN apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
    ed \
    gsl-bin \
    libglib2.0-0 \
    libglu1-mesa-dev \
    libglw1-mesa \
    libgomp1 \
    libjpeg62 \
    libnlopt-dev \
    libxm4 \
    netpbm \
    r-base \
    r-base-dev \
    tcsh \
    xfonts-base \
    xvfb \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && curl -sSL --retry 5 -o /tmp/libxp6_1.0.2-2_amd64.deb http://mirrors.kernel.org/debian/pool/main/libx/libxp/libxp6_1.0.2-2_amd64.deb \
    && dpkg -i /tmp/libxp6_1.0.2-2_amd64.deb \
    && rm /tmp/libxp6_1.0.2-2_amd64.deb \
    && apt-get clean && apt-get update && apt-get -f install &&  dpkg --configure -a && apt-get update \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && curl -o /tmp/libpng12-0_1.2.50-2+deb8u3_amd64.deb -sSL http://mirrors.kernel.org/debian/pool/main/libp/libpng/libpng12-0_1.2.50-2+deb8u3_amd64.deb \
    && dpkg -i /tmp/libpng12-0_1.2.50-2+deb8u3_amd64.deb \
    && rm /tmp/libpng12-0_1.2.50-2+deb8u3_amd64.deb \
    && apt-get install -f \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && gsl2_path="$(find / -name 'libgsl.so.19' || printf '')" \
    && if [ -n "$gsl2_path" ]; then \
    ln -sfv "$gsl2_path" "$(dirname $gsl2_path)/libgsl.so.0"; \
    fi \
    && ldconfig \
    && echo "Downloading AFNI ..." \
    && mkdir -p /opt/afni-latest \
    && curl -fsSL --retry 5 https://afni.nimh.nih.gov/pub/dist/tgz/linux_openmp_64.tgz \
    | tar -xz -C /opt/afni-latest --strip-components 1 \
    && PATH=$PATH:/opt/afni-latest rPkgsInstall -pkgs ALL


RUN   apt-get update

RUN   apt-get clean

#runscript
#ENTRYPOINT ["/usr/bin/R "]
CMD ["R"]
