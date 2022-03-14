provider "google"{
    credentials="${file("${var.path}/project2.json")}"
    project="projectvpcpoc-2"
    region="us-central1"
}