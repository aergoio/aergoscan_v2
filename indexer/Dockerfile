FROM aergo/indexer2
ENV ES_URL ${ES_URL:-http://localhost:9200}
ENV AERGO_NODE ${AERGO_NODE:-localhost:7845}
CMD [indexer -A ${AERGO_NODE} -E ${ES_URL}]