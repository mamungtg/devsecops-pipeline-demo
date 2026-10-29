module "artifacts" {
  source      = "../../modules/secure-s3-bucket"
  bucket_name = "example-build-artifacts"
  tags        = { project = "devsecops-demo" }
}
