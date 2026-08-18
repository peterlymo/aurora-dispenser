# Aurora Dispenser

## Description

A nodeJS service that dispenses authBundles used by AuroraStore for anonymous logins


## Installation

1. Clone the project 
```
git clone https://gitlab.com/AuroraOSS/aurora-dispenser.git AuroraDispenser
cd AuroraDispenser
```

2. Install node modules
```
npm install
```

3. Add accounts
```
Create a txt file as accounts.txt in resources directory

Add you accounts in following format:
email1 aas_token
email2 aas_token
```

4. Build the project
```
sh build.sh
```

5. Run!!
```
npm start dist/src.app.js

# Alternatively you can also use pm2 to run the service
pm2 start dist/src/app.js --name my-dispenser
```

## Docker

Prebuilt multi-arch images (amd64/arm64) are published to GitHub Container Registry: `ghcr.io/peterlymo/aurora-dispenser`

Secrets are **not** baked into the image — mount `accounts.txt` (required) and `blocked_ips.txt` (optional) at runtime.

### Run with docker

```bash
# If the package is private, log in first with a PAT that has read:packages
docker login ghcr.io -u <github-username>

docker run -d --name aurora-dispenser --restart unless-stopped \
  -p 127.0.0.1:3000:3000 \
  -v ./accounts.txt:/app/resources/accounts.txt:ro \
  ghcr.io/peterlymo/aurora-dispenser:latest
```

### Run with docker compose

Place `accounts.txt` next to the bundled `docker-compose.yml` and run:

```bash
docker compose up -d
```

The service binds to `127.0.0.1:3000` on the host — put your own reverse proxy (nginx, Caddy, etc.) in front of it to expose `/api`.

### Environment variables

| Variable | Default   | Description                                  |
| -------- | --------- | -------------------------------------------- |
| `HOST`   | `0.0.0.0` (in Docker) | Address to bind. Defaults to `localhost` outside Docker. |
| `PORT`   | `3000`    | Port to listen on.                            |

### Volumes

| Path in container                | Purpose                          |
| -------------------------------- | -------------------------------- |
| `/app/resources/accounts.txt`    | Google accounts (required)       |
| `/app/resources/blocked_ips.txt` | Blocked IPs, one per line (optional) |
| `/app/dist/logs`                 | Access/blocked logs (optional)   |

### Build locally

```bash
docker build -t aurora-dispenser .
```

Images are also built and pushed automatically by GitHub Actions on every push to `main` (see `.github/workflows/docker.yml`).

## Usage

Aurora Dispenser provided you following APIs:

1. `GET /api/auth`
   - Returns you an authBundle* generated on Dispenser with default device config.
2. `POST /api/auth`
   - Returns you an authBundle* generated on Dispenser with config** provided in body.
   

* See AuthBundle [here](https://gitlab.com/AuroraOSS/aurora-dispenser/-/blob/main/src/types.ts?ref_type=heads#L1-L19)
**See Config Format [here](https://gitlab.com/AuroraOSS/aurora-dispenser/-/raw/main/resources/arm64_xxhdpi.properties)


## AAS Token
AAS Token is a sort of AccessToken, that can be used to generate Auth/Bearer token with certain granted scope (PlayStore, Youtube, Gmail, etc)

- AAS Token do not expire, unless you change the account password.
- In limited scope, it can be used as your Google account password.

### How to generate AAS Token?
Use Authenticator app to generate AAS Token for your Google Account, download Authenticator from [here](https://github.com/whyorean/Authenticator/releases)

## Nginx Server Config
Add following to your config to route all API requests to the new Aurora Dispenser service
```
server{
  ...
  location /api {
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Client-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $host;
    proxy_set_header X-NginX-Proxy true;
    proxy_pass http://localhost:3000/api;
  }
}
```        

Adapt to a version of above config if using Apache, Caddy or alikes.

## Contact

For any questions, feedback, or other inquiries, reach out to rahul@auroraoss.com
