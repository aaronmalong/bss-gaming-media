# BSS Gaming media

Public image host for BSS Gaming social posts.

Images live in `images/` and are served over `raw.githubusercontent.com`, which is what
Zapier and the Instagram Content Publishing API need: a public https URL they can fetch
themselves. Neither can read a file from Aaron's Mac.

This repo is deliberately public. Only finished post artwork belongs here, nothing
private, no customer photos without consent, and no credentials.

Publish an image with `publish.sh <path-to-image>`; it prints the raw URL to use.
