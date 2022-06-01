# gke-nginx-ingress


GCP_PROJECT=YOUR_PROJECT_ID
REGION=europe-west2
MY_IP=$(dig @resolver4.opendns.com myip.opendns.com +short -4)

export GCP_PROJECT REGION

gsutil mb -p $GCP_PROJECT -l $REGION gs://${GCP_PROJECT}-tfstate-bucket
gsutil versioning set on gs://${GCP_PROJECT}-tfstate-bucket

terraform -chdir=terraform/kubernetes init -backend-config=bucket=${GCP_PROJECT}-tfstate-bucket

terraform -chdir=terraform/kubernetes apply -var=gcp_project=$GCP_PROJECT -var=region=$REGION -var=authorized_cidr_block=${MY_IP}/32