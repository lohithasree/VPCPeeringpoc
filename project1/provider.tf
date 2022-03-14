provider "google"{
    credentials="${file("${var.path}/project1.json")}"
    project="gcp-ngt-training"
    region="us-central1"
}