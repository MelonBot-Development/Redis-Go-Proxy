job "melonbot" {
    name = "melonbot"
    datacenters = ["dcl"]

    update {
        max_parallel = 1
        min_healthy_time = "10s"
        healthy_deadline = "1m"

        progress_deadline = "10m"

        auto_revert = false

        auto_revert = false
    }

    migrate {
        max_parallel = 1
        health_check = "task_states"
        min_healthy_time = "10s"
        healthy_deadline = "1m"
    }

    vault {
        policies =["read-kv"]
    }

    constraint {
        attribute = "${attr.unique.hostname}"
        operator = "!="
        value = "ubuntu-4gb-fsn1-1"
    }

    group "bot" {
        driver = "docker"
        
        config {
            image = "ghcr.io/pluralkit/pluralkit:65e2bb02346cc7e36a350af31aa9ed24b472ef39"
        }

        template {
            data = <<EOD
                {{ with secret "kv/melonbot" }}
                MelonBot__Bot__Token = "{{ .Data.discordToken }}"
                MelonBot__DatabasePassword = "{{ .Data.databasePassword }}"
                MelonBot__SentryUrl = "{{ .Data.sentryUrl }}"
                {{ end }}
            EOD
            destination = "local/secret.env"
            env = true
        }

        env {
            MelonBot__Bot__ClientId = 808706062013825036
            MelonBot__Bot__AdminRole = 763522431151112265
            MelonBot__Bot__DiscordBaseUrl = "http://10.0.0.2:8001/api/v10"

            MelonBot__Bot__MaxShardConcurrency = 1
            MelonBot__Bot__UseRedisRatelimiter = true

            MelonBot__Bot__Cluster__TotalShards = 0
            MelonBot__Bot__Cluster__TotalNodes = 0
        
            MelonBot__Database = "Host=10.0.1.3;Port=5432;Username=melonbot;Database=melonbot;Maximum Pool Size=50;Minimum Pool Size = 50;Max Auto Prepare=50"
            MelonBot__RedisAddr = "10.0.1.3:6379"
            MelonBot__ElasticUrl = "http://10.0.1.3:9200"
            MelonBot__InfluxUrl = "http://10.0.1.3:8086"
            MelonBot__InfluxDb = "melonbot"
            MelonBot__UseRedisMetrics = true

            MelonBot__ConsoleLogLevel = 2
            MelonBot__ElasticLogLevel = 2

            MelonBot__FileLogLevel = 5
        }

        resources {
            cpu = 500
            memory = 1200
        }
    }
}
