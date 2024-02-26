fqdn=${1:-$FQDN}
ISS=${2:-${OAUTH2_PROXY_ISS-"https://gigya.cdc.pyzlo.com/oidc/op/v1.0/4_vVpnJOQIK0hSmXhNgODHow"}}
OAUTH2_PROXY_CLIENT_ID=${3:-${OAUTH2_PROXY_CLIENT_ID-"Wch1smZqnsqtO63iefNygzrq"}}
OAUTH2_PROXY_CLIENT_SECRET=${4:-${OAUTH2_PROXY_CLIENT_SECRET-"7uH3B9wcnw8SWJ6THG1LbJXHFgXQwKHB64JbMCTC3EZySTihTVF4YgI4NjSaivxuJaCzvQ7_ofVJU0cAgvR97g"}}
OAUTH2_PROXY_COOKIE_SECRET=`/usr/bin/python3 -c 'import os,base64; print(base64.b64encode(os.urandom(16)).decode("ascii"))'`

echo configure redirect_uri in your IDP to https://www.${fqdn}/oauth2/callback

cat <<EOF  >oauth2-proxy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    k8s-app: oauth2-proxy
  name: oauth2-proxy
spec:
  replicas: 1
  selector:
    matchLabels:
      k8s-app: oauth2-proxy
  template:
    metadata:
      labels:
        k8s-app: oauth2-proxy
    spec:
      containers:
        - args:
            - --provider=oidc
            - --oidc-issuer-url=${ISS}
            - --email-domain=*
            - --upstream=file:///dev/null
            - --http-address=0.0.0.0:4180
            - --scope=openid email profile groups
            - --set-xauthrequest=true
            - --pass-access-token=true
            - --cookie-domain=${fqdn}
            - --whitelist-domain=${fqdn}
            - --skip-provider-button=true
            - --cookie-secure=true
            - --set-authorization-header=true
          env:
            - name: OAUTH2_PROXY_CLIENT_ID
              value: ${OAUTH2_PROXY_CLIENT_ID}
            - name: OAUTH2_PROXY_CLIENT_SECRET
              value: "${OAUTH2_PROXY_CLIENT_SECRET}"
            - name: OAUTH2_PROXY_COOKIE_SECRET
              value: ${OAUTH2_PROXY_COOKIE_SECRET}
          image: quay.io/oauth2-proxy/oauth2-proxy:latest
          imagePullPolicy: Always
          name: oauth2-proxy
          ports:
            - containerPort: 4180
              protocol: TCP

---
apiVersion: v1
kind: Service
metadata:
  labels:
    k8s-app: oauth2-proxy
  name: oauth2-proxy
spec:
  ports:
  - name: http
    port: 4180
    protocol: TCP
    targetPort: 4180
  selector:
    k8s-app: oauth2-proxy
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: oauth2-proxy  
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - www.${fqdn}
  rules: 
  - host: www.${fqdn}
    http:
      paths:
      - backend:
          service:
            name: oauth2-proxy
            port:
              number: 4180
        path: /oauth2
        pathType: Prefix
EOF
kubectl apply -f oauth2-proxy.yaml

# wait for oauth2-proxy to be ready
kubectl wait --for=condition=ready pod -l k8s-app=oauth2-proxy --timeout=600s