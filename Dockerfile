# docker build -t efficientps-semantic-segmentation -f Dockerfile .
# NVIDIA Pytorch Image
FROM nvcr.io/nvidia/pytorch:19.10-py3

# https://stackoverflow.com/questions/55313610/importerror-libgl-so-1-cannot-open-shared-object-file-no-such-file-or-directo
# needed for opencv
RUN apt-get update
RUN apt-get install ffmpeg libsm6 libxext6  -y

WORKDIR .
# https://pythonspeed.com/articles/activate-conda-dockerfile/
COPY environment.yml .
RUN conda env create -f environment.yml

# Make RUN commands use the new environment:
SHELL ["conda", "run", "-n", "efficientPS_env", "/bin/bash", "-c"]

# These have to be installed after because of dependencies
# that get installed when the environment is created
RUN pip install --no-cache-dir pycocotools
RUN pip install --no-cache-dir git+git://github.com/waspinator/pycococreator.git@0.2.0
RUN pip uninstall -y numpy
RUN pip install --no-cache-dir numpy


# Instead of embedding the python command,
# start the container in bash and then we will pass the command
ENTRYPOINT ["conda", "run", "-n", "efficientPS_env", "/bin/bash", "-c"]

# The following install cannot be completed in the Dockerfile:
# git+https://github.com/mapillary/inplace_abn.git
#
# When running EfficientPS in the container the below command must be run first:
# pip3 install git+https://github.com/mapillary/inplace_abn.git && cd ./efficientNet && python setup.py develop && cd .. && python setup.py develop

# python tools/cityscapes_save_predictions.py configs/efficientPS_singlegpu_sample.py checkpoints/efficientPS_cityscapes/model/model.pth ./test_imgs ./test_imgs_output
