workspace "HeartAuth Core" "C2 & C3 Diagram System" {

    model {
        user_admin = person "Admin User" "Zarządza i monitoruje system."
        user_auth = person "User" "Loguje się do aplikacji najemców poprzez HeartAuth i zarządza swoim kontem."

        tenant_system = softwareSystem "HeartAuth Tenant Systems" "Zewnętrzne aplikacje/usługi najemców, które delegują uwierzytelnianie 2FA z EKG do HeartAuth Core."
        fcm_system = softwareSystem "Firebase Cloud Messaging" "Zewnętrzna usługa do wysyłania powiadomień push."
   
        mobile = softwareSystem "HeartAuth Mobile" "Mobilna aplikacja uwierzytelniająca."
        watch = softwareSystem "HeartAuth Wear OS" "Aplikacja Wear OS do próbkowania EKG."

        model_eval_system = softwareSystem "HeartAuth Core" "Obsługuje żądania ewaluacji modelu oraz przepływy parowania urządzeń." {

            postgres = container "PostgreSQL Database" "Przechowuje trwałe dane systemowe." "PostgreSQL"
            redis = container "Redis" "Buforuje dane tymczasowe (rekordy przepływu)." "Redis"
            kafka = container "Kafka Broker" "Obsługuje asynchroniczną komunikację między komponentami." "Apache Kafka"
            
            orchestrator = container "Orchestrator Service" "Koordynuje przepływy pracy i zarządza komunikacją między usługami." "Java / Spring Boot"

            # --- POZIOM C3: Zaktualizowane wnętrze Model API Service ---
            model_api = container "Model API Service" "Wykonuje przetwarzanie sygnałów i wnioskowanie modelu." "Python / FastAPI" {
    
                # --- Komponenty ---

                app = component "Run" "Inicjalizuje aplikację FastAPI oraz oprogramowanie pośredniczące (middleware)." "Python / FastAPI"
                
                config = component "Config" "Zarządza logiką biznesową, zmiennymi środowiskowymi, sekretami i ustawieniami logowania."
                
                middleware = component "Middleware" "Obsługuje zagadnienia przekrojowe: logowanie żądań, Correlation-ID, CORS." "Starlette Middleware"
                

                schemas = component "Schemas" "Definiuje struktury danych dla żądań, odpowiedzi i wiadomości wewnętrznych." "Pydantic Models"
                
                services = component "Services" "Implementuje logikę biznesową: przetwarzanie sygnałów EKG, koordynację wnioskowania, obsługę Kafki." "Python Modules"
                
                infrastructure = component "Infrastructure" "Wrappery klienta Kafka." "Python / AI Libraries"

                # --- Relacje Wewnętrzne ---

                app -> middleware "Konfiguruje"
                app -> infrastructure "Uruchamia Kafkę"
                
                
                services -> schemas "Używa do transferu danych"
                infrastructure -> services "Uruchamia przetwarzanie danych za pomocą modelu ML"
                services -> config "Odczytuje ustawienia operacyjne"
                
                infrastructure -> config "Odczytuje szczegóły połączenia"
            }
        }

        # --- Relacje C2 (Systemowe) ---
        user_admin -> orchestrator "Administruje najemcami i ustawieniami"
        tenant_system -> orchestrator "Deleguje 2FA do HeartAuth Core"

        user_auth -> watch "Używa zegarka do zbierania danych EKG"
        user_auth -> mobile "Używa telefonu do skanowania QR"
        user_auth -> tenant_system "Wyzwala 2FA"
        mobile -> orchestrator "Korzysta z Mobile API"
        mobile -> watch "Żąda odczytu danych EKG"

        orchestrator -> postgres "Odczytuje/zapisuje dane"
        orchestrator -> redis "Odczytuje/zapisuje rekordy przepływu"
        orchestrator -> kafka "Publikuje żądanie ewaluacji"
        
        # Integracja C2 z C3:
        # Kafka komunikuje się z warstwą serwisową (Consumer loop)
        kafka -> app "Dostarcza żądanie ewaluacji (Consumer)"
        app -> kafka "Publikuje odpowiedź ewaluacji (Producer)"

        # Opcjonalnie: Orchestrator -> HTTP
        # orchestrator -> api "Wysyła synchroniczne żądania ewaluacji (HTTP)"
    }

    views {
        # Widok C2 - Kontenery
        container model_eval_system "container-view" {
            include *
            include tenant_system
            include fcm_system
            include user_admin
            include mobile
            autolayout lr
            title "C2 HeartAuth Core - Container View"
        }

        # Widok C3 - Komponenty (Szczegóły Model API)
        component model_api "component-view" {
            include *
            include kafka
            include orchestrator
            autolayout tb
            title "C3 Model API - Component Diagram"
            description "Szczegółowy widok architektury usługi predykcji (FastAPI + Kafka)."
        }

        theme default

        styles {
            element "Component" {
                background #85bbf0
                color #000000
                shape Component
            }
            element "Container" {
                background #1168bd
                color #ffffff
            }
            element "Software System" {
                background #1168bd
                color #ffffff
            }
            element "Person" {
                shape Person
                background #08427b
                color #ffffff
            }
            element "Database" {
                shape Cylinder
            }
        }
    }
}
