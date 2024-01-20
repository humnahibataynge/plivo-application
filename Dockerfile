FROM nginx:latest
WORKDIR /usr/share/nginx/html
RUN rm -f index.html
COPY ./webapp-template/index.html .
COPY ./webapp-template/styles.css .
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]