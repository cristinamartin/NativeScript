#!/usr/bin/env bash
set -e

ENV="${ENV:-dev}"
DIST_DIR="bin/dist"
TARGET_DIR="$DIST_DIR/snippets"
PACKAGE_VERSION="${PACKAGE_VERSION:-0.0.0}"

archive_dist_dir() {
    DIR="$1"
    (cd "$DIST_DIR" && tar zcvf "nativescript-$DIR-$ENV-$PACKAGE_VERSION.tar.gz" $DIR)
}

npm_install() {
    # Don't install modules twice.

    MARKER_FILE="./node_modules/installed"
    if [ ! -f "$MARKER_FILE" ] ; then
        npm install
        touch "$MARKER_FILE"
    fi
}

extract_snippets() {
    BIN="./node_modules/markdown-snippet-injector/extract.js"

    npm install markdown-snippet-injector

    for SNIPPET_DIR in {tests,apps,tns-core-modules} ; do
        echo "Extracting snippets from: $SNIPPET_DIR"
        node "$BIN" --root="$SNIPPET_DIR" --target="$TARGET_DIR" \
            --sourceext=".js|.ts|.xml|.html|.css"
    done

    archive_dist_dir "snippets"
}

extract_cookbook() {
    COOKBOOK_DIR="$DIST_DIR/cookbook"
    rm -rf "$COOKBOOK_DIR"
    
    npm_install
    grunt articles
    mv "$DIST_DIR/articles" "$COOKBOOK_DIR"
    archive_dist_dir "cookbook"
}

extract_apiref() {
    APIREF_DIR="$DIST_DIR/api-reference"
    rm -rf "$APIREF_DIR"

    npm_install
    npm run typedoc

    mv "$DIST_DIR/apiref" "$APIREF_DIR"
    archive_dist_dir "api-reference"
}

rm -rf "$TARGET_DIR"
mkdir -p "$TARGET_DIR"

if [ "${BASH_SOURCE[0]}" == "$0" ] ; then
    extract_snippets
    extract_cookbook
    extract_apiref
fi
