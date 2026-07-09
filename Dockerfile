# Use a lightweight web server to serve the static index.html file
FROM nginx:alpine

# Copy the sample HTML file to the default Nginx public directory
COPY index.html /usr/share/nginx/html/index.html

# Expose port 80 for the container
EXPOSE 80

# Start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
