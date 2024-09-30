## Initial setup

```
echo -n "$(cat private-key.pem)" | gcloud secrets create tesla-private-key --data-file=-
gcloud secrets add-iam-policy-binding tesla-private-key \
    --member="serviceAccount:218297886362-compute@developer.gserviceaccount.com" \
    --role="roles/secretmanager.secretAccessor"

gcloud projects add-iam-policy-binding electric-sidecar-backend --member='serviceAccount:service-218297886362@gcp-sa-artifactregistry.iam.gserviceaccount.com' --role='roles/storage.objectViewer'
```

## To deploy

```
# Explicit platform flag is required when building from macOS
docker build --platform linux/amd64 -t gcr.io/electric-sidecar-backend/tesla-http-proxy . \
&& docker push gcr.io/electric-sidecar-backend/tesla-http-proxy \
&& gcloud run deploy tesla-http-proxy \
    --image gcr.io/electric-sidecar-backend/tesla-http-proxy \
    --platform managed \
    --region us-east1 \
    --allow-unauthenticated
```
