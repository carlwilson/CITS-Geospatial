#!/usr/bin/env bash
echo "Generating GitHub pages site from markdown"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR" || exit

echo " - Cleaning up site directory and copying spec-publisher site..."
git clean -f site/ specification/ doc/ 
cp -rf spec-publisher/site/* site/
cp -rf spec-publisher/res/md/figs site/

echo " - Generating main site specification and PDF markdown..."

mvn clean package -f spec-publisher/pom.xml
java -jar ./spec-publisher/target/mets-profile-processor-0.2.0-SNAPSHOT.jar -f ./specification.yaml -o doc/site  profile/E-ARK-GEOSPATIAL-ROOT-v3-0-0.xml profile/E-ARK-GEOSPATIAL-REPRESENTATION-v3-0-0.xml

echo " - MARKDOWN-PP: generating site page with TOC..."
cd doc/site || exit
bash "$SCRIPT_DIR/spec-publisher/scripts/create-venv.sh"
command -v markdown-pp >/dev/null 2>&1 || {
  tmpdir=$(dirname "$(mktemp -u)")
  source "$tmpdir/.venv-markdown/bin/activate"
}
markdown-pp body.md -o body_toc.md

echo " - MARKDOWN-PP: generating site index.md..."
markdown-pp SITE.md -o "$SCRIPT_DIR"/site/index.md

cd "$SCRIPT_DIR" || exit

echo " - copying files to site directory..."
# Copy remaining collaterel
cp -rf profile archive guideline specification/media site/

if [ -d _site ]
then
  echo " - Removing old site directory collatoral"
  rm -rf _site/*
fi
