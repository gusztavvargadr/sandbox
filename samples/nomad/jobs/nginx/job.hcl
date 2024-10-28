job "nginx" {
  group "nginx" {
    count = 1

    network {
      port "http" {
        static = 80
      }
    }

    service {
      name = "nginx-http"
      port = "http"
    }

    task "nginx" {
      driver = "docker"

      config {
        image = "nginx"

        ports = ["http"]

        volumes = [
          "local:/etc/nginx/conf.d",
        ]
      }

      template {
        data = <<EOF
upstream consul {
{{ range service "consul" }}
  server {{ .Address }}:8500;
{{ else }}server 127.0.0.1:65535; # force a 502
{{ end }}
}

server {
  listen 80;
  server_name consul-nomad-cluster-vm.gusztavvargadr.me;

  location / {
    proxy_pass http://consul/;
  }
}

upstream nomad {
{{ range service "http.nomad" }}
  server {{ .Address }}:{{ .Port }};
{{ else }}server 127.0.0.1:65535; # force a 502
{{ end }}
}

server {
  listen 80;
  server_name nomad-nomad-cluster-vm.gusztavvargadr.me;

  location / {
    proxy_pass http://nomad/;
  }
}

upstream echo {
{{ range service "echo-server" }}
  server {{ .Address }}:{{ .Port }};
{{ else }}server 127.0.0.1:65535; # force a 502
{{ end }}
}

server {
  listen 80;
  server_name echo-nomad-cluster-vm.gusztavvargadr.me;

  location / {
    proxy_pass http://echo/;
  }
}

upstream dotnet {
{{ range service "dotnet-api" }}
  server {{ .Address }}:{{ .Port }};
{{ else }}server 127.0.0.1:65535; # force a 502
{{ end }}
}

server {
  listen 80;
  server_name dotnet-nomad-cluster-vm.gusztavvargadr.me;

  location / {
    proxy_pass http://dotnet/;
  }
}
EOF

        destination   = "local/load-balancer.conf"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }
    }
  }
}
