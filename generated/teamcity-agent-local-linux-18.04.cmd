cd ..
docker pull ubuntu:18.04
echo TeamCity/webapps > context/.dockerignore
echo TeamCity/devPackage >> context/.dockerignore
echo TeamCity/lib >> context/.dockerignore
docker build -f "generated/linux/MinimalAgent/Ubuntu/18.04/Dockerfile" -t teamcity-minimal-agent:local-linux-18.04 "context"
echo 2> context/.dockerignore
echo TeamCity >> context/.dockerignore
docker build -f "generated/linux/Agent/Ubuntu/18.04/Dockerfile" -t teamcity-agent:local-linux-18.04 "context"
