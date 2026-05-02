provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_storage_bucket" "man-index-site" {
  name          = var.bucket_name
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "notfound.html"
  }
}

# Make bucket public
resource "google_storage_bucket_iam_binding" "public_read" {
  bucket = google_storage_bucket.man-index-site.name
  role   = "roles/storage.objectViewer"

  members = [
    "allUsers",
  ]
}

# Upload static assets
resource "google_storage_bucket_object" "assets" {
  for_each = fileset("${path.module}/assets", "**")

  name   = each.value
  bucket = google_storage_bucket.man-index-site.name
  source = "${path.module}/assets/${each.value}"

  content_type = lookup(
    {
      html = "text/html"
      css  = "text/css"
      js   = "application/javascript"
    },
    split(".", each.value)[length(split(".", each.value)) - 1],
    "application/octet-stream"
  )
}
