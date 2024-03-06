locals {
  name               = "sonarproxy"
  docker_image_name  = "tel-${var.env}-${local.name}"
  container_name     = "container-${var.env}-${local.name}"
  web_context        = "/sonarqube"
  sonarqube_fqdn     = "sonarqube.docker.${var.env}.acme.corp"
  sonarqube_address  = "http://${local.sonarqube_fqdn}:9000/${local.web_context}"
  sonarproxy_fqdn    = "sonarproxy.docker.${var.env}.acme.corp"
  sonarproxy_address = "https://${local.sonarproxy_fqdn}/${local.web_context}"
}

resource "docker_image" "sonarproxy" {
  name         = local.docker_image_name
  keep_locally = false
  build {
    context = path.module
    build_args = {
      _SERVER_KEY_PASSPHRASE = module.bw_sonarqube_pk_passphrase.data.password
      _SONARQUBE_ADDRESS     = local.sonarqube_address
      _SONARPROXY_CONTEXT    = local.web_context
    }
  }
  triggers = {
    dir_sha1 = sha1(join("", [
      filesha1("${path.module}/Dockerfile")
    ]))
  }
}

resource "docker_container" "sonarproxy" {
  name     = local.container_name
  image    = docker_image.sonarproxy.image_id
  restart  = "unless-stopped"
  hostname = local.container_name

  networks_advanced {
    name         = "${var.env}-docker"
    ipv4_address = "10.10.0.126"
  }

  healthcheck {
    test         = ["CMD", "curl", "--insecure", "--fail", "https://localhost:443"]
    interval     = "20s"
    timeout      = "5s"
    start_period = "10s"
    retries      = 3
  }
}
