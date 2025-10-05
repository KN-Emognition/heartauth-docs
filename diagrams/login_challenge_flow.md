# Login Challenge Flow Overview

This section provides an overview of the login challenge flow, detailing the steps involved in authenticating users and handling various challenges that may arise during the login process.

```mermaid
sequenceDiagram
    autonumber
    actor U as User
    participant KC as Keycloak
    participant IO as internal-orchestrator
    participant PG as Postgres
    participant RD as Redis
    participant FCM as FCM (push)
    participant M as Mobile App
    participant W as Wearable
    participant EO as external-orchestrator
    participant MA as model-api

    U->>KC: Open login page
    KC->>IO: REST: trigger challengeCreate (userId)

    IO->>PG: Check deviceCredential(userId)
    alt deviceCredential exists
        PG-->>IO: Found
        IO->>RD: Create challenge(challengeId, status="PENDING")
        IO->>FCM: Send push notification(challengeId, userId)
        FCM-->>M: Notification delivered(challengeId)
    else no deviceCredential
        PG-->>IO: Not found
        IO-->>KC: Error: no registered device
        KC-->>U: Login failed (no device)
        rect rgb(255,240,240)
        note over KC,IO: Flow ends in this branch
        end
    end

    par Mobile collects ECG
        M->>W: Request ECG measurement(challengeId)
        W->>U: Prompt: "Place finger/start ECG measurement"
        U-->>W: User performs ECG measurement
        W-->>M: ECG data
    and Keycloak polls status
        loop Poll until timeout
            KC->>IO: REST: get challenge status(challengeId)
            IO->>RD: Read status(challengeId)
            RD-->>IO: status (PENDING/APPROVED/DENIED)
            IO-->>KC: status
        end
    end

    M->>EO: Submit ECG data(challengeId, payload)
    EO->>RD: Verify challenge exists(challengeId)
    alt challenge present
        RD-->>EO: OK (PENDING)
        EO->>MA: Validate ECG(payload)
        MA-->>EO: Result: TRUE or FALSE
        EO->>RD: Update status(challengeId=APPROVED/DENIED)
    else missing/expired
        RD-->>EO: NOT FOUND/EXPIRED
        EO-->>M: Error: invalid challenge
    end

    alt status becomes APPROVED
        KC-->>U: Login success
    else status becomes DENIED or timeout
        KC-->>U: Login failed
    end
```
