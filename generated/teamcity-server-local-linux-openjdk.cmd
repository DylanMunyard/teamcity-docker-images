cd ..
docker pull ubuntu:20.04
echo TeamCity/buildAgent > context/.dockerignore
echo TeamCity/temp >> context/.dockerignore
docker build -f "generated/linux/Server/Ubuntu/20.04-openjdk/Dockerfile" -t teamcity-server:local-linux-openjdk "context"
