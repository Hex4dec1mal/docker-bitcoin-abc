FROM 4ops/alpine-glibc:3.9 AS build

ARG BITCOIN_VERSION
ARG BITCOIN_CHECKSUM

ENV BITCOIN_VERSION=${BITCOIN_VERSION:-0.19.10}
ENV BITCOIN_CHECKSUM=${BITCOIN_CHECKSUM:-e9997d9122b7524f9eb522856b9ec54d9e07b63d9852b3e5a0646fc0df2a5efb}
ENV BITCOIN_URL="https://download.bitcoinabc.org/${BITCOIN_VERSION}/linux"
ENV BITCOIN_PACKAGE="bitcoin-abc-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz"

RUN wget "${BITCOIN_URL}/${BITCOIN_PACKAGE}" -O $BITCOIN_PACKAGE
RUN echo "${BITCOIN_CHECKSUM}  ${BITCOIN_PACKAGE}" | sha256sum -c -
RUN tar -xvzf $BITCOIN_PACKAGE
RUN mkdir -p /install/bin
RUN mv "bitcoin-abc-${BITCOIN_VERSION}/bin/bitcoind" /install/bin
RUN mv "bitcoin-abc-${BITCOIN_VERSION}/bin/bitcoin-cli" /install/bin
RUN mv "bitcoin-abc-${BITCOIN_VERSION}/bin/bitcoin-tx" /install/bin

COPY docker-entrypoint.sh /install/entrypoint.sh

FROM 4ops/alpine-glibc:3.9 AS release

ENV BITCOIN_DATA=/home/bitcoin/.bitcoin

COPY --from=build /install .

RUN adduser -S bitcoin && apk --no-cache add su-exec

VOLUME ["/home/bitcoin/.bitcoin"]

EXPOSE 8332 8333 18332 18333 18444

ENTRYPOINT ["/entrypoint.sh"]

CMD ["bitcoind"]
