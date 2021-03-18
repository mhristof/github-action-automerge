# Automerge github action

This action will automatically merge an open Pull request if all the
tests have passed and the label `automerge` is set in the PR.

## Inputs

| Name | Description | Default | Required |
| ---- | ----------- | ------- | -------- |
| GITHUB_TOKEN | Github token for contacting the API |  | true|
| label | Label of the PR to check for automerge. If label is not set, no action will be taken | automerge | false|
| merge_method | Merge method. Valid options are Possible values are "merge", "squash" or "rebase". More details at https://docs.github.com/en/rest/reference/pulls#merge-a-pull-request | squash | false|

# Example usage


```yaml
- name: automerge
  uses: mhristof/github-action-automerge@v1.0
  with:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```
