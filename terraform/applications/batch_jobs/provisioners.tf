locals {
  rates_batch_jobs_tag_timestamp = formatdate("YYYYMMDDhhmm", timestamp())
  rates_batch_jobs_tag_sha = sha1(join("", [for f in fileset("${path.module}/files/rates/", "**"): filesha1("${path.module}/files/rates/${f}")]))
}
# Build the Docker image , tag it and push it to ECR using terraform provisioner
resource "null_resource" "rates_batch_jobs_provisioner" {
  triggers = {
    github_runner_dockerfile_sha1 = sha1(join("", [for f in fileset("${path.module}/files/rates/", "**"): filesha1("${path.module}/files/rates/${f}")]))
  }
  provisioner "local-exec" {
    command     = <<EOT
      cd "${path.module}/files/rates/"
      aws ecr get-login-password --region us-east-1 | sudo docker login --username AWS --password-stdin ${module.ecr_rates_batch_jobs.repository_url}
      sudo docker build -t ${module.ecr_rates_batch_jobs.repository_url}:${local.rates_batch_jobs_tag_sha} -t ${module.ecr_rates_batch_jobs.repository_url}:LATEST -t ${module.ecr_rates_batch_jobs.repository_url}:${local.rates_batch_jobs_tag_timestamp} .
      sudo docker push ${module.ecr_rates_batch_jobs.repository_url}:LATEST
      sudo docker push ${module.ecr_rates_batch_jobs.repository_url}:${local.rates_batch_jobs_tag_timestamp}
      sudo docker push ${module.ecr_rates_batch_jobs.repository_url}:${local.rates_batch_jobs_tag_sha}
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [module.ecr_rates_batch_jobs]
}

output "rates_batch_jobs_image_tag" {
  value = concat([local.rates_batch_jobs_tag_sha],["LATEST"])
}