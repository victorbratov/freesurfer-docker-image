FROM quay.io/modh/odh-minimal-notebook-container:v2-20241205-dc88d57

LABEL name="cuda-jupyter-tensorflow-ubi9-python-3.11-freesufer"      

USER 0
# shell settings
WORKDIR /opt/app-root/src
COPY centos9.repo /etc/yum.repos.d/centos9.repo
COPY RPM-GPG-KEY-CentOS-9 /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-9

# install utils
#COPY qt5-qtbase-5.15.9-10.el9.i686.rpm /usr/local/qt5-qtbase-5.15.9-10.el9.i686.rpm
#COPY qt5-qtbase-gui-5.15.9-10.el9.x86_64.rpm /usr/local/qt5-qtbase-gui-5.15.9-10.el9.x86_64.rpm
#RUN yum install -y /usr/local/qt5-qtbase-5.15.9-10.el9.i686.rpm && \ yum install -y /usr/local/qt5-qtbase-gui-5.15.9-10.el9.x86_64.rpm
RUN INSTALL_PKGS="bc libgomp perl tar wget vim-common mesa-libGL libXext tcsh libSM libXrender libXmu libglvnd-glx mesa-libGLU libxkbcommon qt5-qtbase qt5-qtbase-gui dbus-x11 libncurses5 libxext6 libxmu6 libxpm-dev default-jre libxt6 unzip" && \
    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
    yum -y clean all --enablerepo='*'

# install fs
COPY fs1.tar.gz /usr/local/fs1.tar.gz
RUN tar --no-same-owner -xvf /usr/local/fs1.tar.gz -C /usr/local/
RUN ls -l /usr/local/freesurfer
RUN  rm -rf /usr/local/fs1.tar.gz

RUN chgrp -R 0 /usr/local/freesurfer && \
    chmod -R g=u /usr/local/freesurfer

# setup fs env
ENV OS Linux
ENV PATH /usr/local/freesurfer/bin:/usr/local/freesurfer/fsfast/bin:/usr/local/freesurfer/tktools:/usr/local/freesurfer/mni/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/app-root/bin/

ENV FREESURFER_HOME /usr/local/freesurfer
COPY license.txt $FREESURFER_HOME/.license

ENV FREESURFER /usr/local/freesurfer
ENV SUBJECTS_DIR /usr/local/freesurfer/subjects
ENV LOCAL_DIR /usr/local/freesurfer/local
ENV FSFAST_HOME /usr/local/freesurfer/fsfast
ENV FMRI_ANALYSIS_DIR /usr/local/freesurfer/fsfast
ENV FUNCTIONALS_DIR /usr/local/freesurfer/sessions

# set default fs options
ENV FS_OVERRIDE 0
ENV FIX_VERTEX_AREA ""
ENV FSF_OUTPUT_FORMAT nii.gz

# mni env requirements
ENV MINC_BIN_DIR /usr/local/freesurfer/mni/bin
ENV MINC_LIB_DIR /usr/local/freesurfer/mni/lib
ENV MNI_DIR /usr/local/freesurfer/mni
ENV MNI_DATAPATH /usr/local/freesurfer/mni/data
ENV MNI_PERL5LIB /usr/local/freesurfer/mni/share/perl5
ENV PERL5LIB /mni/share/perl5

# python path for freesurfer
RUN mkdir $FREESURFER_HOME/python/bin/ \
    ln -s $(which python3) $FREESURFER_HOME/python/bin/python

# install matlab runtime
COPY mcr.zip /usr/local/mcr.zip
RUN unzip -q /usr/local/mcr.zip -d /usr/local/mcrtmp \
    && /usr/local/mcrtmp/install -destinationFolder /opt/MCRv84 -mode silent -agreeToLicense yes \
    && rm -rf /usr/local/mcrtmp \
    && rm -rf /usr/local/mcr.zip \
    && ln -s /opt/MCRv84/v84 $FREESURFER_HOME/MCRv84

ENV MATLABCMD /opt/MCRv84/2014b/toolbox/matlab
ENV XAPPLRESDIR /opt//opt/MCRv84/v84/x11/app-defaults
ENV MCRROOT /opt/MCRv84/2014b


ENV SHELL /bin/bash

WORKDIR /opt/app-root/src

USER 1001
