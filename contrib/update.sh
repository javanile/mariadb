#!/usr/bin/env bash

versions=(
  "10.6.12"
)

template=versions/Dockerfile.template
release=0.$(date +%y.%W).$(printf "%02d" $(($(grep 'LABEL release=' $template | sed -r 's/.*\.0*([0-9]*)"/\1/')+1)))

if [[ $@ = *'--release'* ]]; then
    git add .
    git commit -am "Release ${release}" && true
    git push
    echo "Docker login"
    docker login -u javanile
fi

for version in "${versions[@]}"; do
  echo "====[ $version ]===="
  mkdir -p "versions/${version}"
  sed -e 's!%{version}!'"${version}"'!' $template > "versions/${version}/Dockerfile"

  cp versions/dataset "versions/${version}/dataset"
  chmod +x "versions/${version}/dataset"

  cp versions/execute "versions/${version}/execute"
  chmod +x "versions/${version}/execute"

  cp versions/docker-entrypoint.sh "versions/${version}/docker-entrypoint.sh"
  chmod +x "versions/${version}/docker-entrypoint.sh"

  if [[ $@ = *'--release'* ]]; then
    docker build -t "javanile/mariadb:${version}" "versions/${version}"
    docker push "javanile/mariadb:${version}"
  fi
done
