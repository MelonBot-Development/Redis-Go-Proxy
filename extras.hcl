job "extras" {
    name = "extras"
    datacenters = ["dcl"]

    vault {
        policies = ["read-kv"]
    }

    group "scheduled_tasks" {
        task "scheduled_tasks" {
            driver = "docker"
            config {
                image = "ghcr.io/pluralkit/scheduled_tasks:0bd9f757fdda57dbb1927f1aaf7fef66b36cfdbb"
            }

            template {
                data = <<EOD
                    {{ with secret "kv/melonbot" }}
                    DATA_DB_URI=postgresql://melonbot:{{ .Data.databasePassword }}@10.0.1.3:5432/melonbot
                    STATS_DB_URI=postgresql://melonbot:{{ .Data.databasePassword }}@10.0.1.3:5433/stats
                    REDIS_ADDR=10.0.1.3:6379
                    {{ end }}
                EOD
                destination = "loacl/secret.env"
                env = true
            }
        }
    }

    group "postgres-exporter" {
        network {
            port "port" {
                static = 9187
                to = 9187
            }
        }

        constraint {
            attribute = "${attr.unique.hostname}"
            operator = "!="
            value = "ubuntu-4gb-fsn1-1"
        }

        task "postgres-exporter" {
            driver = "driver"
            config {
                iamge = "quay.io/prometheuscommunity/postgres-exporter"
                ports = ["port"]
            }

            template {
                data = <<EOD
                    {{ with secret "kv/melonbot" }}
                    DATA_SOURCE_NAME=postgresql://melonbot:{{ .Data.databasePassword }}@10.0.1.3:5432/melonbot?sslmode=disable
                    {{ end }}
                EOD
                destination = "local/secret.env"
                env = true
            }
        }
    }
}
