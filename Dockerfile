# build stage 
FROM python:3.9-slim AS builder
WORKDIR /django
# copy requirement files and install dependecies
COPY ecommerce/requirements.txt /django/

# install requirements 
RUN pip install --user -r requirements.txt 

# copy the code

COPY . .

# Application run stage 
 FROM gcr.io/distroless/python3-debian12 
WORKDIR /django
# copy only the installed dependecies and app from builder stage 
COPY --from=builder /root/.local /root/.local
COPY --from=builder /django /django
ENV PATH=/root/.local/bin:$PATH
EXPOSE 8000
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
