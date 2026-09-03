## Build + install

Here for CPU engine, but you get the idea:
```shell
make build
./dev/install.sh --clean --engine=cpu
```

## Sanity checks


Check the service is actually up, not crash-looping. If you have mmproj files, check that they are picked up fine. E.g. for `glm-ocr`:
```shell
snap services glm-ocr
sudo snap logs glm-ocr.server -n 100 -f
```

## Testing when you hit OOM issues

Extract llama from the snap:

```shell
cd /tmp && rm -rf llamacpp-inspect && unsquashfs -d /tmp/llamacpp-inspect -f /path/to/snap-repo/glm-ocr+llamacpp.comp >/dev/null 2>&1
```

Run the server with a cgroup limit. E.g. :

```shell
sudo systemd-run --scope -p MemoryMax=4G \
  env LD_LIBRARY_PATH="$PWD/lib" \
  ./bin/llama-server \
    --model /path/to/model.gguf \
    --mmproj /path/to/mmproj.gguf \
    --fit-ctx 4096 --no-warmup --port 18344
```

## Verify config
```
glm-ocr status --format=json | jq .
```

Check .model.name is proper and note .entrypoints.openai.url — you'll need it below.


## Actual run

Make a POST request. E.g. for GLM-OCR you could do:

```shell
base_url=$(glm-ocr status --format=json | jq -r .entrypoints.openai.url)
img_b64=$(base64 -w0 /path/to/some/document-or-text-image.png)

curl -s -X POST "$base_url/chat/completions" \
  -H "Content-Type: application/json" \
  -d @- <<EOF | jq .
{
  "model": "glm-ocr-q8-0",
  "messages": [{
    "role": "user",
    "content": [
      {"type": "text", "text": "Extract all text from this image."},
      {"type": "image_url", "image_url": {"url": "data:image/png;base64,${img_b64}"}}
    ]
  }]
}
EOF
```