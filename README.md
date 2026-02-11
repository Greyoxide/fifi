# Fifi

Fifi is a tiny CLI to download or install Google Fonts. It pulls font files from
the Google Fonts GitHub repository via the GitHub API.

## Usage

```
fifi install nunito
fifi install nunito, inter, open sans
fifi download nunito -o assets/fonts
fifi download nunito
```

## Options

- `-o, --output DIR`: Download destination for `download`.
- `-s, --static`: Prefer static fonts instead of variable.

## Notes

- The GitHub API is rate-limited. If you hit limits, set `FIFI_GITHUB_TOKEN`
  or `GITHUB_TOKEN` to a personal access token.

## Install

Build and install the gem locally:

```
gem build fifi.gemspec
gem install ./fifi-0.1.0.gem
```
