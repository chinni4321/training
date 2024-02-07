# main.tf

provider "google" {
  credentials = file("terra.json")
  project     = "citric-yen-411615"
  region      = "us-central1"
}

resource "google_compute_instance" "example_instance" {
  name         = "terrform-instance"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"  # Specify the zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network = "default"
  }
}
