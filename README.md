# Model-Assisted Labeling Workflow

This project explores how a computer vision machine learning (CVML) model can be used
to assist in labeling image datasets. The workflow is as follows:

1. An S3 bucket containing images of pedestrians is provided as a "source dataset".
 
2. Run `make` to execute a series of tasks to deploy cloud infrastructure and execute the model-assisted labeling pipeline.

3. Open your project in Labelbox and start labeling! You should see the new unlabeled dataset with model-assisted annotations.

The PyTorch model is trained by fine-tuning a pre-trained model from the
[COCO 2017 dataset](https://cocodataset.org/#detection-2017). The [Penn-Fudan Database for Pedestrian Detection and Segmentation](https://www.cis.upenn.edu/~jshi/ped_html/)
is used for training the new model to detect pedestrians. See the [TorchVision tutorial](https://pytorch.org/tutorials/intermediate/torchvision_tutorial.html)
for more information.


![architecture](./docs/architecture.png)

## Deployment Process

The following tools are required for deploying the stack:

- [Terraform](https://www.terraform.io/downloads) (version 1.0.11)
- [AWS CLI](https://aws.amazon.com/cli/) (version 2.3.7)
- [Docker Desktop](https://www.docker.com/get-started) (version 20.10.10)

Ensure you have valid AWS credentials loaded in your environment, such as
[environment variables](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#environment-variables) 
or [shared credential file](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#shared-credentials-file).

Please review the contents of `Makefile` before executing any commands!

Run `make` to create cloud resources, build Docker images, and run the pipeline.

## Progress

- [x] Create `vpc` module for virtual cloud configuration.
- [x] Create `networking` module for subnets, gateways, and route tables.
- [x] Create `storage` module containing EFS filesystem access points for training dataset,
  source dataset, model, and segmentation masks. IAM is used to control file system
  data access as described [here](https://docs.aws.amazon.com/efs/latest/ug/iam-access-control-nfs-efs.html).
- [x] Create `compute_cluster` module containing an auto-scaling EC2 cluster with support for GPU instances.
- [ ] Create a `pipeline` module for loading model-assisted annotations into Labelbox.
  - [x] Create `pipeline` Step Function for importing datasets, training models, and exporting predictions as annotations.
  - [x] Create `import_source_dataset_to_efs` Lambda function to import the source dataset.
  - [x] Create `import_training_dataset_to_efs` Lambda function to import the training dataset.
  - [x] Create a `train_model` ECS task to build a PyTorch model and save it to the shared file system.
  - [ ] Create a `compute_segmentation_masks_for_source_dataset` ECS task to use the model to generate segmentation mask files.
  - [ ] Import source dataset and segmentation masks into Labelbox so that they can assist the labeling workflow.

## Frequently Asked Questions

#### How could this type of architecture scale?
* As more datasets are added to the single EFS filesystem, the increased file system data access may gobble up your
  [EFS burst credits](https://aws.amazon.com/premiumsupport/knowledge-center/efs-burst-credits/). I would investigate how
  having separate file systems for each dataset would allow performance to scale.
 
* For a highly-available system, the network configuration could be reconfigured to span its subnets across availability
  zones. Each AZ would contain their own ECS cluster to provide maximum uptime. Auto-scaling will keep up with the
  demand of growing teams.

* Since EFS is used for storing datasets, models, and predictions, those filesystems can be shared with
  [CI/CD pipelines](https://aws.amazon.com/blogs/storage/deploying-jenkins-on-amazon-eks-with-amazon-efs/) and
  [Jupyter Notebook](https://zero-to-jupyterhub.readthedocs.io/en/latest/kubernetes/amazon/efs_storage.html) environments
  to support the workflow of large teams.
 
#### What does the output of `terraform graph` look like?
![terraform-graph](./docs/terraform-graph.png)

#### How can I contribute?
Open an issue or send an [e-mail](mailto:stefan.louis.novak@gmail.com)!