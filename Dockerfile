FROM nimlang/nim:1.6.20-alpine-regular AS build

RUN apk add --no-cache musl-dev

ADD . /somalier

RUN cd /somalier && \
    nimble install -d -y && \
    nim c -d:strip -d:danger --gcc.exe=musl-gcc --gcc.linkerexe=musl-gcc -d:release \
        -d:openmp -d:blas=openblas -d:lapack=openblas -o:/usr/bin/somalier src/somalier

FROM alpine:3.21

# for nextflow
RUN apk add --no-cache bash procps

COPY --from=build /somalier/scripts/ancestry-labels-1kg.tsv /ancestry_labels-1kg.tsv

COPY --from=build /usr/bin/somalier /usr/bin/somalier

ENV somalier_ancestry_labels=/ancestry_labels-1kg.tsv

CMD ["/usr/bin/somalier"]
