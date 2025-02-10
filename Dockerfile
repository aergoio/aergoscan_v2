FROM node:20-alpine3.19 as builder
LABEL description="nginx"

ARG ARG_AERGO_NODE_HOST
ARG ARG_API_URL
ENV AERGO_NODE ${ARG_AERGO_NODE_HOST}
ENV API_URL ${ARG_API_URL}

WORKDIR /aergoscan_frontend
COPY ./aergoscan_v2_frontend/package* ./
RUN yarn
COPY ./aergoscan_v2_frontend/. .

RUN AERGO_NODE=${AERGO_NODE} API_URL=${API_URL} yarn build


FROM nginx:1.27.1-alpine
COPY --from=builder /aergoscan_frontend/build /usr/share/nginx/html
RUN mkdir /etc/nginx/ssl
COPY ./nginx/rootca_frontend.crt /etc/nginx/ssl/rootca_frontend.crt
COPY ./nginx/rootca_frontend.key /etc/nginx/ssl/rootca_frontend.key
COPY ./nginx/rootca_api.crt /etc/nginx/ssl/rootca_api.crt
COPY ./nginx/rootca_api.key /etc/nginx/ssl/rootca_api.key
COPY ./nginx/rootca_node.crt /etc/nginx/ssl/rootca_node.crt
COPY ./nginx/rootca_node.key /etc/nginx/ssl/rootca_node.key
COPY ./nginx/nginx_https.conf /etc/nginx/conf.d/default_https.back
COPY ./nginx/nginx_http.conf /etc/nginx/conf.d/default_http.back

ARG ARG_USE_DNS
RUN if [ "${ARG_USE_DNS}" = "true" ] ; then \
        mv /etc/nginx/conf.d/default_https.back /etc/nginx/conf.d/default.conf ; \
    else \
        mv /etc/nginx/conf.d/default_http.back /etc/nginx/conf.d/default.conf ; \
    fi

ARG ARG_AERGO_NODE
ENV AERGO_NODE ${ARG_AERGO_NODE}
ARG ARG_AERGO_NODE_HOST
ENV AERGO_NODE_HOST ${ARG_AERGO_NODE_HOST}
ARG ARG_SCAN_EXPLORER_HOST
ENV SCAN_EXPLORER_HOST ${ARG_SCAN_EXPLORER_HOST}
ARG ARG_SCAN_API_HOST
ENV SCAN_API_HOST ${ARG_SCAN_API_HOST}

RUN sed -i "s#AERGO_NODE_HOST#${AERGO_NODE_HOST}#" /etc/nginx/conf.d/default.conf
RUN sed -i "s#AERGO_NODE#${AERGO_NODE}#" /etc/nginx/conf.d/default.conf
RUN sed -i "s#SCAN_EXPLORER_HOST#${SCAN_EXPLORER_HOST}#" /etc/nginx/conf.d/default.conf
RUN sed -i "s#SCAN_API_HOST#${SCAN_API_HOST}#" /etc/nginx/conf.d/default.conf
RUN sed -i 's#server_name https:\/\/#server_name #' /etc/nginx/conf.d/default.conf
RUN sed -i 's#server_name http:\/\/#server_name #' /etc/nginx/conf.d/default.conf

EXPOSE 80
EXPOSE 443
CMD ["nginx", "-g", "daemon off;"]