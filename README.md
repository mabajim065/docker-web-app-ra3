\### Services



| Service | Technology | Role |

|---|---|---|

| nginx | Nginx Alpine | Reverse proxy, single entry point |

| frontend | React + Nginx Alpine | User interface |

| backend | Spring Boot + JRE Alpine | Business logic and API |

| db | MySQL 8.0 | Persistent data storage |



\### Networks



| Network | Services |

|---|---|

| frontend-network | nginx, frontend, backend |

| backend-network | backend, db |



The database is isolated in its own network and is \*\*never directly accessible\*\* from the frontend or nginx.



\---



\## Deployment Manual



\### Requirements

\- Docker Desktop installed and running

\- Git



\### Steps to deploy



\*\*1. Clone the repository\*\*

```bash

git clone https://github.com/mabajim065/docker-web-app-ra3.git

cd docker-web-app-ra3

```



\*\*2. Create the .env file\*\*

```bash

cp .env.example .env

```

Edit `.env` with your own values.



\*\*3. Start all services\*\*

```bash

docker compose up -d --build

```



\*\*4. Access the application\*\*



Open your browser at: \[http://localhost](http://localhost)



\*\*5. Stop all services\*\*

```bash

docker compose down

```



\*\*6. Stop and remove volumes\*\*

```bash

docker compose down -v

```



\*\*7. Update a service\*\*

```bash

docker compose build backend

docker compose up -d backend

```



\### Configuration Files



| File | Description |

|---|---|

| `docker-compose.yml` | Orchestrates all services |

| `.env` | Environment variables (not committed) |

| `nginx/nginx.conf` | Reverse proxy routing rules |

| `frontend/Dockerfile` | Multi-stage build for React app |

| `backend/Dockerfile` | Multi-stage build for Spring Boot app |

| `frontend/nginx.conf` | Internal nginx config for React routing |



\---



\## Multi-Stage Builds



Both the frontend and backend use multi-stage builds to produce optimized production images.



\*\*Frontend:\*\*

\- Stage 1 (`builder`): Uses `node:18-alpine` to install dependencies and build the React app.

\- Stage 2 (`production`): Uses `nginx:alpine` to serve only the compiled static files.

\- The final image does \*\*not\*\* contain Node.js, npm, or the source code.



\*\*Backend:\*\*

\- Stage 1 (`builder`): Uses `maven:3.9-eclipse-temurin-17-alpine` to compile and package the Spring Boot app.

\- Stage 2 (`production`): Uses `eclipse-temurin:17-jre-alpine` to run only the compiled `.jar` file.

\- The final image does \*\*not\*\* contain Maven, source code, or build tools.



This reduces image size significantly and improves security by minimizing the attack surface.



\---



\## Healthcheck and Startup Order



The MySQL container includes a healthcheck:



```yaml

healthcheck:

&#x20; test: \["CMD", "mysqladmin", "ping", "-h", "localhost"]

&#x20; interval: 10s

&#x20; timeout: 5s

&#x20; retries: 5

&#x20; start\_period: 30s

```



The backend service uses `depends\_on` with `condition: service\_healthy`:



```yaml

depends\_on:

&#x20; db:

&#x20;   condition: service\_healthy

```



This ensures the backend \*\*strictly waits\*\* for MySQL to be fully initialized before starting, preventing connection errors during the initial deployment sequence.



\---



\## Administration Manual



\### Managing Services



```bash

\# View running containers

docker compose ps



\# View logs of a specific service

docker compose logs backend

docker compose logs db



\# Restart a service

docker compose restart backend



\# Scale a service

docker compose up -d --scale backend=2

```



\### Security Measures



| Measure | Implementation |

|---|---|

| Minimal exposed ports | Only port 80 (nginx) is exposed to the host |

| Environment variables | All sensitive data stored in `.env` file |

| Non-root users | Frontend and backend containers run as `appuser` |

| Isolated networks | DB only accessible from backend via `backend-network` |

| Controlled image versions | All images use pinned versions (e.g. `mysql:8.0`) |

| Resource limits | Memory and CPU limits set for backend and db |



\### Resource Limits



```yaml

deploy:

&#x20; resources:

&#x20;   limits:

&#x20;     memory: 512m

&#x20;     cpus: "0.5"

```



Applied to both `backend` and `db` services to prevent memory leaks from exhausting host resources.



\### Database Backup



Run the backup script from the project root:



```bash

bash db\_backup.sh

```



The script will:

1\. Connect to the running `db` container using `docker exec`

2\. Run `mysqldump` inside the container

3\. Save the `.sql` file in the `./backups` folder with a timestamp



Example output: `./backups/backup\_20250520\_143022.sql`



\### Maintenance and Scalability Recommendations



\- Regularly back up the database using `db\_backup.sh`

\- Monitor container resource usage with `docker stats`

\- Update base images periodically to get security patches

\- For production environments, consider using Docker Swarm or Kubernetes for orchestration

\- Use a `.env.production` file with strong passwords for production deployments



\---



\## Testing



\### Functional Tests



| Test | Method | Expected Result |

|---|---|---|

| Frontend accessible | Browser → http://localhost | React app loads correctly |

| Backend API accessible | Browser → http://localhost/api | API responds with JSON |

| Frontend-Backend communication | Use the app UI | Data loads from backend |

| Backend-Database communication | Check backend logs | No connection errors |



\### Log Validation



```bash

\# Check nginx logs

docker compose logs nginx



\# Check backend logs

docker compose logs backend



\# Check database logs

docker compose logs db

```



\### Performance Test



```bash

\# Install Apache Bench (comes with Apache)

ab -n 100 -c 10 http://localhost/

```



This sends 100 requests with 10 concurrent users to test basic load handling.

