# gke-nginx-ingress

## install [helmfile](https://github.com/helmfile/helmfile) if needed (to install helm releases)
```
if [[ ! $(which helmfile) ]] ; then
case "$(uname -s)" in
   Darwin) PLATFORM_BASE="darwin" ;;
   Linux) PLATFORM_BASE="linux" ;;
   *) echo 'Other OS' ; exit 1 ;;
esac
HELMFILE_LOCATION=/usr/local/bin/helmfile
HELMFILE_VERSION=v0.143.0
sudo curl -L -o $HELMFILE_LOCATION "https://github.com/roboll/helmfile/releases/download/${HELMFILE_VERSION}/helmfile_${PLATFORM_BASE}_amd64" \
    && sudo chmod +x $HELMFILE_LOCATION
fi
```
expected apps present: terrafrom, helm, gcloud

## set variables
```
GCP_PROJECT=YOUR_PROJECT_ID
REGION=europe-west1
DNS_HOST_NAME=example.com # change to your own
MY_IP=$(dig @resolver4.opendns.com myip.opendns.com +short -4)

export DNS_HOST_NAME
```
## optional - setup new project
```
## https://cloud.google.com/sdk/gcloud/reference/auth
gcloud auth login
gcloud config set project $GCP_PROJECT
gcloud config set compute/region $REGION

## setup application-default credentials for terraform
## https://cloud.google.com/sdk/gcloud/reference/auth/application-default
gcloud auth application-default login
export GOOGLE_APPLICATION_CREDENTIALS=~/.config/gcloud/application_default_credentials.json
```

## install vpc and kubernetes
```
## enable needed services in gcp project
## https://cloud.google.com/endpoints/docs/openapi/enable-api#gcloud
gcloud --project $GCP_PROJECT services enable compute.googleapis.com container.googleapis.com

gsutil mb -p $GCP_PROJECT -l $REGION gs://${GCP_PROJECT}-tfstate-bucket
gsutil versioning set on gs://${GCP_PROJECT}-tfstate-bucket

## VPC
terraform -chdir=terraform/vpc init -backend-config=bucket=${GCP_PROJECT}-tfstate-bucket
terraform -chdir=terraform/vpc apply -var=gcp_project=$GCP_PROJECT -var=region=$REGION

## kubernetes
terraform -chdir=terraform/kubernetes init -backend-config=bucket=${GCP_PROJECT}-tfstate-bucket
terraform -chdir=terraform/kubernetes apply -var=gcp_project=$GCP_PROJECT -var=region=$REGION -var=authorized_cidr_block=${MY_IP}/32

## auth cluster
gcloud container clusters get-credentials cluster-test-1 --region $REGION --project $GCP_PROJECT

NGINX_IP_ADDRESS=$(gcloud compute addresses describe --project $GCP_PROJECT --region $REGION nginx-ingress-test-1 --format='value(address)')
echo "nginx ingress IP addres: $NGINX_IP_ADDRESS"
export NGINX_IP_ADDRESS

## install all helm deployments
helmfile --file=helmfile/helmfile.yaml sync --concurrency=1
# helmfile --selector=name=ingress-test --file=helmfile/helmfile.yaml sync --skip-deps
```
add IP address to your DNS host

## clean up
```
terraform -chdir=terraform/kubernetes destroy -var=gcp_project=$GCP_PROJECT -var=region=$REGION -var=authorized_cidr_block=${MY_IP}/32 -auto-approve
terraform -chdir=terraform/vpc destroy -var=gcp_project=$GCP_PROJECT -var=region=$REGION -auto-approve
gsutil rm -r gs://${GCP_PROJECT}-tfstate-bucket
```