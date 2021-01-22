FROM gcr.io/google.com/cloudsdktool/cloud-sdk:alpine
RUN gcloud components install docker-credential-gcr

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]