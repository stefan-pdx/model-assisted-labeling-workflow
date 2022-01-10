import io
import os

from urllib.request import urlopen
from zipfile import ZipFile

import boto3

def import_training_dataset_to_efs(event, context):
    if not os.listdir("/mnt/training_dataset"):
        with urlopen("https://www.cis.upenn.edu/~jshi/ped_html/PennFudanPed.zip") as response:
            with ZipFile(io.BytesIO(response.read())) as zip:
                zip.extractall("/mnt/training_dataset")

def import_source_dataset_to_efs(event, context):
    if not os.listdir("/mnt/source_dataset"):
        s3 = boto3.resource('s3')

        bucket = s3.Bucket(event['source_dataset_bucket_name'])

        for s3_object in bucket.objects.all():
            path, filename = os.path.split(s3_object.key)
            bucket.download_file(s3_object.key, os.path.join("/mnt/source_dataset", filename))

def import_source_datset_to_labelbox(event, context):
    # TODO: create a Labelbox dataset, add source dataset images in /mnt/source_dataset to S3 bucket, and add DataRows to dataset
    pass

def import_source_dataset_segmentation_masks_to_labelbox(event, context):
    # TODO: add segmentation masks in /mnt/segmentation_masks to corresponding DataRows for dataset
    pass