# Frontend
The Frontend is written in React and served by AWS Cloudfront. Whenever you push changes to the frontend 
the js bundle is built and the cache is invalidated.

## How to run

Go to the root folder and run

```
docker compose -f docker-compose.dev.yml up
```

then visit http://localhost:3002/.
