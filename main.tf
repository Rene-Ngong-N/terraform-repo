terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    #   version = "4.38.0"
      version = "~> 2.5"
    }
  }
}

provider "google" {
  # Configuration options
  project = "test-env-360218"
  region = "us-central1"
  zone   = "us-central1-a"
}

# resource "google_compute_firewall" "default" {
#   name    = "rene-firewall"
#   network = google_compute_network.default.name

#   allow {
#     protocol = "icmp"
#   }

#   allow {
#     protocol = "tcp"
#     ports    = ["80", "8080", "1000-2000", "22"]
#   }

#   source_tags = ["web"]
#   source_ranges = ["0.0.0.0/0"]
# }

resource "google_compute_firewall" "default" {
  name    = "test-firewall"
  network = google_compute_network.default.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["8080", "1000-2000"]
  }

  source_tags = ["web"]
}

# resource "google_compute_network" "default" {
#   name = "test-network"
# }

resource "google_compute_network" "default" {
  name = "test-network"
}

resource "google_service_account" "default" {
  account_id   = "service-account-id"
  display_name = "Service Account"
}

resource "google_compute_firewall" "allow-http" {
  name = "default-allow-http"
  network = google_compute_network.default.name

  allow{
    protocol = "tcp"
    ports = ["80"]
  }
}

resource "google_compute_instance" "default" {
  name         = "apache-server"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

#   tags = ["foo", "bar"]

  #tags = ["web", "http-server", "https-server"]
  tags = ["http-server", "https-server"]

  

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }
  network_interface {
    network = google_compute_network.default.name

    access_config {
      // Ephemeral public IP
    }
  }
   metadata = {
    enable-oslogin = "TRUE"
  }

#   metadata = {
#     foo = "bar"
#   }

  metadata_startup_script = file("./apache2.sh")
#   metadata_startup_script = "echo hi > /test.txt"
  scheduling {
    preemptible = true
    automatic_restart = false
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
}
