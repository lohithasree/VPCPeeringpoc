#creating vpcnetwork
resource "google_compute_network" "vpc_network" {
  name                    = var.vpc_network
  auto_create_subnetworks ="false"
}
#creating custom subnetwork with enable vpc flow logs in specifies ip ranges
resource "google_compute_subnetwork" "vpc_subnetwork" {
  name          = var.vpc_subnetwork
  network       = var.vpc_network
  region = "us-central1"
  ip_cidr_range = "10.8.0.0/16"
  
  
 depends_on = [
    google_compute_network.vpc_network
  ]
}
#creating firewall rules 
resource "google_compute_firewall" "allow_http_ssh" {
  name    = "firewall-2"
  network       = var.vpc_network
  target_tags = ["http-server"]
  source_ranges = ["0.0.0.0/0"]
#allowing tcp protocol with required ports
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  allow {
    protocol = "icmp"
  }
   depends_on = [
    google_compute_network.vpc_network
  ]
}
#creating instance
resource "google_compute_instance" "default1" {
  name         = "peer-vm2"
  zone         = "us-central1-a"
  machine_type = "f1-micro"
  boot_disk {
    initialize_params {
     image = "debian-cloud/debian-9"
    }
  }
  network_interface {
    network = var.vpc_network
    subnetwork = var.vpc_subnetwork
    access_config {
      # Allocate a one-to-one NAT IP to the instance
    }
  }
  
   depends_on = [
    google_compute_subnetwork.vpc_subnetwork
  ]
    tags = ["http-server"]
}
//custom routes
resource "google_compute_route" "route2" {
  name        = "vpc-net-2-route"
  dest_range  = "10.20.0.0/23"
  network     = var.vpc_network
  tags = ["vm2"]
  next_hop_instance="peer-vm2"
  next_hop_instance_zone="us-central1-a"
  priority    = 0
  depends_on = [
      google_compute_instance.default1
    ]
}
//network peering
resource "google_compute_network_peering" "peer-btoa" {
  name         = "peer-btoa"
  network      = "https://www.googleapis.com/compute/v1/projects/projectvpcpoc-2/global/networks/vpc-net-2"
  peer_network= "https://www.googleapis.com/compute/v1/projects/gcp-ngt-training/global/networks/vpc-net-1"
  depends_on = [
    google_compute_network.vpc_network
  ]
}