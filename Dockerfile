FROM nginx:latest
WORKDIR /usr/share/nginx/html
RUN rm -f index.html
COPY ./template/index.html .
COPY ./template/styles.css .
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]