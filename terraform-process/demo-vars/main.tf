# main.tf

provider "google" {
  credentials = file("terra.json")
  project     = var.project
  region      = var.region
}

resource "google_compute_instance" "example_instance" {
  name         = var.instance_name
  machine_type = "n1-standard-1"
  zone         = "${var.region}-a"  # Specify the zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network = "default"
  }
}

resource "google_storage_bucket" "example_bucket" {
  name     = var.bucket_name
  location = "US"  # Specify the location

  # Add any additional bucket configurations as needed
  # For example:
  # storage_class = "STANDARD"
  # versioning    = true
}
