# BSS Gaming media

Public image host for BSS Gaming social posts.

Images live in `images/` and are served over `raw.githubusercontent.com`, which is what
Zapier and the Instagram Content Publishing API need: a public https URL they can fetch
themselves. Neither can read a file from Aaron's Mac.

This repo is deliberately public. Only finished post content belongs here, nothing
private and no credentials.

Customer photos are fine. Aaron takes consent from every customer before photographing
them, as standing practice. If a photo ever needs taking down after the fact, deleting it
here does not affect the live post, because Meta keeps its own copy from publish time.

Publish an image with `publish.sh <path-to-image>`; it prints the raw URL to use.
