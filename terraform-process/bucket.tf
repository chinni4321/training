resource "google_storage_bucket" "example_bucket" {
  name     = "bucket979706"
  location = "US"  # Specify the location

  # Add any additional bucket configurations as needed
  # For example:
  # storage_class = "STANDARD"
  # versioning    = true
}
