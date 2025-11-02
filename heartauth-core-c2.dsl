workspace "Model Evaluation Orchestration System" "C4 Container Diagram" {

    model {
        user_admin = person "Admin User" "Manages and monitors the system"
        user_auth = person "Authenticated User" "Signs in to tenant apps via HeartAuth and manages their account."

        tenant_system = softwareSystem "HeartAuth Tenant Systems" "External tenant apps/services that delegate 2FA with ECG to HeartAuth Core."

        fcm_system = softwareSystem "Firebase Cloud Messaging" "External notification service for sending push notifications"

        model_eval_system = softwareSystem "HeartAuth Core" "Handles model evaluation requests and device pairing flows" {

            orchestrator = container "Orchestrator Service" "Orchestrates workflows, and manages inter-service communication and exposes external interfaces" "Java / Spring Boot"
            postgres = container "PostgreSQL Database" "Stores persistent system data" "PostgreSQL"
            redis = container "Redis" "Caches temporal data (Flow records)" "Redis"
            kafka = container "Kafka Broker" "Handles asynchronous communication between components" "Apache Kafka"
            model_api = container "Model API Service" "Performs model inference and sends responses back" "Python / FastAPI"
        }

        user_admin -> orchestrator "Administers tenants & settings"
        user_auth -> orchestrator "Uses Mobile APIs to complete flows"
        tenant_system -> orchestrator "Delegates 2FA to HeartAuth Core"

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
            include user_auth
            autolayout lr
            title "Container Diagram for Heartauth Core"
            description "Shows main containers, external systems, and user interactions."
        }

        theme default
    }
}
