# Diagram Sekwencji dla flow logowania

* Komunikacja **REST API** z ```internal-orchestrator``` odbywa się zgodnie z [kontraktem wewnętrznym](https://github.com/KN-Emognition/orchestrator/blob/master/contract/internal.yml)
* Komunikacja **REST API** z ```external-orchestrator``` odbywa się zgodnie z [kontraktem zewnętrznym](https://github.com/KN-Emognition/orchestrator/blob/master/contract/external.yml)
* Komunikacja z ```Redis``` odbywa się zgodnie z kontraktem Redis
* Komunikacja **DataLayer API** między ```Flutter app``` oraz ```WearOS app``` odbywa się zgodnie z kontraktem DataLayer
* Komunikacja **Firebase Cloud Messaging** między ```internal-orchestrator```, ```FCM (push)``` oraz ```Flutter app``` odbywa się zgodnie z kontraktem FCM
* Komunikacja z ```Kafka``` odbywa się zgodnie z [kontraktem Kafka](https://github.com/KN-Emognition/orchestrator/blob/master/contract/model-api-kafka.yml)
* Nazwy wywoływanych operacji REST API odpowiadają **id** operacji zdefiniowanych w ww. kontraktach

```mermaid
sequenceDiagram
    autonumber
    actor U as User
    participant KC as Keycloak
    participant IO as internal-orchestrator
    participant PG as Postgres
    participant RD as Redis
    participant FCM as FCM (push)
    participant M as Flutter app
    participant W as WearOS app
    participant EO as external-orchestrator
    participant KF as Kafka
    participant MA as model-api

    U->>KC: REST: {GET} Open login page
    KC->>IO: REST: {POST} createChallenge(userId)

    IO-)PG: JDBC: SELECT user_device(userId)
    alt no deviceCredential 
        PG--)IO: JDBC: Response
        IO-->>KC: REST: Error: no registered device
        KC-->>U: Login failed (no device)
    else user device credentials exist
        PG--)IO: JDBC: Response
        IO->>RD: Create challenge(challengeId, status="PENDING")
        IO->>FCM: FIREBASE: Send push notification(challengeId, userId)
        FCM-->>M: FIREBASE: Notification delivered(challengeId)
            M->>W: DATALAYER: Request ECG measurement(challengeId)
        W->>U: Prompt: "Place finger/start ECG measurement"
        U-->>W: User performs ECG measurement
        W-->>M: DATALAYER: ECG data
        M->>EO: REST: {POST} completeChallenge(challengeId, payload)
        EO-)RD: REDIS: Verify challenge exists(challengeId)
        alt challenge present
            RD--)EO: REDIS: OK (PENDING)
            EO-)PG: JDBC: SELECT ecg_ref_data(userId)
            alt ecg reference data exist
                PG--)EO: JDBC: Response
                EO->>KF: KAFKA: PredictRequest(payload)
                KF->>MA: KAFKA: PredictRequest(payload)
                MA->>KF: KAFKA: PredictResponse(TRUE/FALSE)
                KF->>IO: KAFKA: PredictResponse(TRUE/FALSE)
                IO->>RD: REDIS: Update status(challengeId=APPROVED/DENIED)
                loop Poll until timeout or status != PENDING
                    EO->>RD: REDIS: Read status(challengeId)
                    RD-->>EO: REDIS: status (PENDING/APPROVED/DENIED)
                end
                EO->>M: REST: status(APPROVED/DENIED)
            else
                PG--)EO: JDBC: Response
                EO-->>M: REST: Error: ecg reference data not found
            end
        else missing/expired
            RD-->>EO: REDIS: NOT FOUND/EXPIRED
            EO-->>M: REST: Error: invalid challenge
        end 

        loop Poll until timeout or status != PENDING
                KC->>IO: REST: {GET} getChallengeStatus(id)
                IO->>RD: REDIS: Read status(challengeId)
                RD-->>IO: REDIS: status (PENDING/APPROVED/DENIED)
                IO-->>KC: REST: StatusResponse
        end

        alt status == APPROVED
            KC-->>U: REST: Login success
        else timeout or status == DENIED
            KC-->>U: REST: Login failed
        end
    end
    
    
```
