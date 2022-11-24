resource "aws_s3_bucket" "artifacts_bucket_name" {
  bucket = "ecspipartificat"  
  acl    = "private"

  tags = {
    Name        = "Myterraformbucket"
  }  
}
  