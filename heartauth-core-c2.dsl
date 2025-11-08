workspace "HeartAuth Core" "C2 Container Diagram" {

    model {
        user_admin = person "Admin User" "Manages and monitors the system"
        user_auth = person "User" "Signs in to tenant apps via HeartAuth and manages their account."

        tenant_system = softwareSystem "HeartAuth Tenant Systems" "External tenant apps/services that delegate 2FA with ECG to HeartAuth Core."
        fcm_system = softwareSystem "Firebase Cloud Messaging" "External notification service for sending push notifications"
  
        mobile = softwareSystem "HeartAuth Mobile" "Mobile authenticator application"
        watch = softwareSystem "HeartAuth Wear OS" "Wear Os ECG Sampler application"

        model_eval_system = softwareSystem "HeartAuth Core" "Handles model evaluation requests and device pairing flows" {

            orchestrator = container "Orchestrator Service" "Orchestrates workflows, and manages inter-service communication and exposes external interfaces" "Java / Spring Boot"
            postgres = container "PostgreSQL Database" "Stores persistent system data" "PostgreSQL"
            redis = container "Redis" "Caches temporal data (Flow records)" "Redis"
            kafka = container "Kafka Broker" "Handles asynchronous communication between components" "Apache Kafka"
            model_api = container "Model API Service" "Performs model inference and sends responses back" "Python / FastAPI"
        }

        user_admin -> orchestrator "Administers tenants & settings"
        tenant_system -> orchestrator "Delegates 2FA to HeartAuth Core"

        user_auth -> watch "Uses watch to collect ECG data"
        user_auth -> mobile "Uses mobile to scan QR, to orchestrate watch application"
        user_auth -> tenant_system "Uses system to insert login credentials and trigger 2FA"
        mobile -> orchestrator "uses Mobile API"
        mobile -> watch "requests ECG Data read"

        orchestrator -> postgres "Reads/writes data"
        orchestrator -> redis "Reads/writes flow records"
        orchestrator -> kafka "Publishes model-evaluation-request"
        kafka -> model_api "Delivers model-evaluation-request"
        model_api -> kafka "Publishes model-evaluation-response"
        kafka -> orchestrator "Delivers model-evaluation-response"

        orchestrator -> fcm_system "Sends push notification requests"
        fcm_system -> user_auth "Delivers notifications to mobile device"
    }

    views {
        container model_eval_system "container-view" {
            include *
            include tenant_system
            include fcm_system
            include user_admin
            // include user_auth
            // include watch
            include mobile
            autolayout lr
            title "C2 HeartAuth Core"
        }

        theme default
    }
}
