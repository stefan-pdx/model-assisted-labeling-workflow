FROM 763104351884.dkr.ecr.us-west-2.amazonaws.com/pytorch-training:1.10.0-cpu-py38-ubuntu20.04-e3

RUN conda install -c pytorch pytorch torchvision=0.11.2 cpuonly

RUN conda install -c conda-forge pycocotools

RUN wget -O vision.zip https://github.com/stefan-pdx/vision/archive/refs/heads/main.zip

RUN unzip vision.zip

WORKDIR vision-main/references/detection

COPY tasks.py .

ENTRYPOINT ["python3", "tasks.py"]