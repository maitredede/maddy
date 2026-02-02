group "default" {
    targets = [
    "maddy",
  ]
}

target "_common" {
    context = "."
    dockerfile = "Dockerfile"
    tags = ["homelab.local/foxcpp/maddy:dev"]
    platforms = ["linux/amd64", "linux/arm64"]
    pull = true
    extra_hosts = [
        "homelab.local:192.168.1.2"
    ]
    args = {
        "ADDITIONAL_BUILD_TAGS" = "libdns_cloudflare"
    }
}

target "maddy" {
    inherits = ["_common"]
    target = "maddy"
    tags = ["homelab.local/foxcpp/maddy:dev"]
}
